import 'dart:async';
import 'dart:developer' as dev;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../app/alerts.dart';
import '../data/local/app_db.dart';
import '../data/remote/sync_api.dart';
import '../data/remote/tokens.dart';
import '../features/notifications/notifications_controller.dart';
import 'sync_state.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  final service = SyncService(ref);
  service._start();
  ref.onDispose(service.dispose);
  return service;
});

enum SyncTrigger { manual, autoTimer, autoOnline }

class SyncService {
  SyncService(this._ref);

  final Ref _ref;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const _deviceIdKey = 'deviceId';

  bool _started = false;
  bool _syncInFlight = false;
  bool _connected = true;
  int _pending = 0;
  DateTime? _lastStartNoticeAt;
  StreamSubscription<int>? _pendingSub;
  StreamSubscription? _connectivitySub;
  Timer? _autoSyncTimer;

  void _start() {
    if (_started) return;
    _started = true;

    final db = _ref.read(appDbProvider);
    _pendingSub = db.watchPendingPushCount().listen((pending) {
      _pending = pending;
      _ref.read(syncStateProvider.notifier).setPending(pending);
    });

    // Track connectivity so manual refresh doesn't hang on timeouts when offline.
    Connectivity().checkConnectivity().then((results) {
      _connected = results.any((r) => r != ConnectivityResult.none);
    });
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      final connected = results.any((r) => r != ConnectivityResult.none);
      final becameOnline = !_connected && connected;
      _connected = connected;
      if (becameOnline && _pending > 0) {
        // Kick a sync attempt as soon as we regain network.
        unawaited(syncOnce(trigger: SyncTrigger.autoOnline));
      }
    });

    // Periodic auto-sync:
    // - debug/profile: every 10s (testing)
    // - release: every 5 mins
    final interval =
        kReleaseMode ? const Duration(minutes: 5) : const Duration(seconds: 10);
    _autoSyncTimer = Timer.periodic(interval, (_) {
      if (_pending <= 0) return;
      unawaited(syncOnce(trigger: SyncTrigger.autoTimer));
    });
  }

  Future<String> _deviceId() async {
    final existing = await _storage.read(key: _deviceIdKey);
    if (existing != null && existing.isNotEmpty) return existing;
    final generated = DateTime.now().microsecondsSinceEpoch.toString();
    await _storage.write(key: _deviceIdKey, value: generated);
    return generated;
  }

  Future<void> syncOnce({SyncTrigger trigger = SyncTrigger.autoTimer}) async {
    if (_syncInFlight) return;

    // Sync endpoints require auth. Avoid throwing/crashing when logged out.
    final tokens = _ref.read(tokensProvider);
    if (tokens == null || tokens.accessToken.isEmpty) {
      dev.log('[SYNC] skipped (missing access token)', name: 'sync');
      return;
    }

    if (!_connected) {
      _ref.read(syncStateProvider.notifier).setError('offline');
      dev.log('[SYNC] skipped (offline)', name: 'sync');
      return;
    }

    // No-op quickly if nothing to push.
    if (_pending <= 0) return;

    _syncInFlight = true;
    final db = _ref.read(appDbProvider);
    final pendingBefore = _pending;

    _ref.read(syncStateProvider.notifier).setSyncing(true);
    _maybeNotifySyncStarted(trigger: trigger, pending: pendingBefore);
    try {
      await _pushWithRetry(trigger: trigger);
      _ref.read(syncStateProvider.notifier).setError(null);

      final pendingAfter = await db.countPendingPush();
      final pushed = (pendingBefore - pendingAfter).clamp(0, pendingBefore);
      if (pushed > 0) {
        _ref.read(notificationsControllerProvider.notifier).add(
              message: 'Sync completed. Uploaded $pushed record(s).',
              level: AppAlertLevel.success,
            );
      }
    } on DioException catch (e) {
      final msg =
          '${e.type} ${e.response?.statusCode ?? '—'} ${e.message ?? ''}'.trim();
      _ref.read(syncStateProvider.notifier).setError(msg);
      dev.log('[SYNC] failed: $msg', name: 'sync');
      _ref.read(notificationsControllerProvider.notifier).add(
            message: 'Sync failed. $msg',
            level: AppAlertLevel.error,
          );
    } catch (e) {
      _ref.read(syncStateProvider.notifier).setError(e.toString());
      dev.log('[SYNC] failed: $e', name: 'sync');
      _ref.read(notificationsControllerProvider.notifier).add(
            message: 'Sync failed. $e',
            level: AppAlertLevel.error,
          );
    } finally {
      _syncInFlight = false;
      _ref.read(syncStateProvider.notifier).setSyncing(false);
    }
  }

  Future<void> _pushWithRetry({required SyncTrigger trigger}) async {
    // "Transactional" behavior here means:
    // - only mark records pushed when backend confirms (already true)
    // - if we fail due to transient network issues, retry shortly instead of waiting 5 mins
    const maxAttempts = 3;
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        await pushPending();
        return;
      } on DioException catch (e) {
        if (!_isTransientNetworkError(e) || attempt == maxAttempts) rethrow;

        final delay = switch (attempt) {
          1 => const Duration(seconds: 2),
          2 => const Duration(seconds: 6),
          _ => const Duration(seconds: 12),
        };
        dev.log(
          '[SYNC] transient failure, retrying in ${delay.inSeconds}s (attempt $attempt/$maxAttempts)',
          name: 'sync',
        );
        await Future<void>.delayed(delay);
        if (!_connected) {
          _ref.read(syncStateProvider.notifier).setError('offline');
          throw DioException(
            requestOptions: RequestOptions(path: '/sync/push'),
            type: DioExceptionType.connectionError,
            error: 'offline',
          );
        }
      }
    }
  }

  bool _isTransientNetworkError(DioException e) {
    return switch (e.type) {
      DioExceptionType.connectionTimeout => true,
      DioExceptionType.sendTimeout => true,
      DioExceptionType.receiveTimeout => true,
      DioExceptionType.connectionError => true,
      DioExceptionType.unknown => true,
      DioExceptionType.badResponse =>
        (e.response?.statusCode != null && (e.response!.statusCode! >= 500)),
      _ => false,
    };
  }

  void _maybeNotifySyncStarted({required SyncTrigger trigger, required int pending}) {
    // Start notifications can be noisy for auto-sync, so we only emit it:
    // - always for manual sync
    // - for auto sync at most once per 10 minutes
    final now = DateTime.now();
    final isManual = trigger == SyncTrigger.manual;
    final last = _lastStartNoticeAt;
    final allow =
        isManual || last == null || now.difference(last) >= const Duration(minutes: 10);
    if (!allow) return;

    _lastStartNoticeAt = now;
    final prefix = switch (trigger) {
      SyncTrigger.manual => 'Sync started',
      SyncTrigger.autoTimer => 'Auto sync started',
      SyncTrigger.autoOnline => 'Auto sync started (back online)',
    };
    _ref.read(notificationsControllerProvider.notifier).add(
          message: '$prefix. Pending: $pending.',
          level: AppAlertLevel.info,
        );
  }

  /// Pushes locally-created/updated bookings to backend `/sync/push`.
  ///
  /// Single-table outbox rule:
  /// - `pushedStart=false` => emit `booking_start`
  /// - `status=complete && pushedFinish=false` => emit `booking_finish`
  Future<void> pushPending({int limit = 200}) async {
    final db = _ref.read(appDbProvider);
    final api = _ref.read(syncApiProvider);

    final pendingBookings = await db.listBookingsNeedingPush(limit: limit);
    if (pendingBookings.isEmpty) return;

    final deviceId = await _deviceId();

    final mutationIndex = <({String bookingId, String type})>[];
    final mutations = <Map<String, Object?>>[];

    for (final b in pendingBookings) {
      if (!b.pushedStart) {
        mutations.add(<String, Object?>{
          'type': 'booking_start',
          'bookingId': b.id,
          'rackId': b.rackId,
          'candidateId': b.candidateId,
          'startedAt': b.startedAt.toIso8601String(),
        });
        mutationIndex.add((bookingId: b.id, type: 'booking_start'));
      }

      if (b.status == 'complete' && !b.pushedFinish) {
        mutations.add(<String, Object?>{
          'type': 'booking_finish',
          'bookingId': b.id,
          'endedAt': (b.endedAt ?? DateTime.now()).toIso8601String(),
        });
        mutationIndex.add((bookingId: b.id, type: 'booking_finish'));
      }
    }

    if (mutations.isEmpty) return;

    final res = await api.push(deviceId: deviceId, mutations: mutations);

    final count =
        mutationIndex.length < res.results.length ? mutationIndex.length : res.results.length;
    for (var i = 0; i < count; i++) {
      final idx = mutationIndex[i];
      final r = res.results[i];
      final ok = r['ok'] == true;
      if (ok) {
        if (idx.type == 'booking_start') {
          await db.markBookingStartPushed(idx.bookingId);
        } else if (idx.type == 'booking_finish') {
          await db.markBookingFinishPushed(idx.bookingId);
        }
      } else {
        final err = (r['error'] as String?) ?? 'REJECTED';
        await db.markBookingPushFailed(idx.bookingId, err);
      }
    }

    _ref.read(syncStateProvider.notifier).markPush();
  }

  void dispose() {
    _pendingSub?.cancel();
    _connectivitySub?.cancel();
    _autoSyncTimer?.cancel();
  }
}

