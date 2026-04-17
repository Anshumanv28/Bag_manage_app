import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../app/alerts.dart';
import '../app/nav.dart';
import '../data/local/app_db.dart';
import '../data/remote/auth_api.dart';
import '../data/remote/sync_api.dart';
import '../data/remote/tokens.dart';
import '../features/auth/auth_controller.dart';
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
  static const _lastPullAtKey = 'lastPullAt';

  bool _started = false;
  bool _syncInFlight = false;
  bool _connected = true;
  int _pending = 0;
  DateTime? _lastStartNoticeAt;
  StreamSubscription<int>? _pendingSub;
  StreamSubscription? _connectivitySub;
  Timer? _autoSyncTimer;
  DateTime? _lastMeAt;

  static const Duration _meRefreshInterval = Duration(seconds: 30);

  Future<void> _maybeRefreshMe() async {
    final now = DateTime.now();
    final last = _lastMeAt;
    if (last != null && now.difference(last) < _meRefreshInterval) return;

    final tokens = _ref.read(tokensProvider);
    if (tokens == null || tokens.accessToken.isEmpty) return;

    final authApi = _ref.read(authApiProvider);
    try {
      final me = await authApi.me(accessToken: tokens.accessToken);
      _ref.read(authControllerProvider.notifier).updateOperator(me);
      _lastMeAt = now;
    } on DioException catch (e) {
      if (e.response?.statusCode != 401) return;

      // Access token expired: try refresh once, then apply operator from refresh response.
      if (tokens.refreshToken.isEmpty) return;

      final refreshRes = await authApi.refresh(
        refreshToken: tokens.refreshToken,
      );
      final newTokens = Tokens(
        accessToken: refreshRes.accessToken,
        refreshToken: refreshRes.refreshToken,
      );
      _ref.read(tokensProvider.notifier).setTokens(newTokens);
      await _ref.read(tokenStoreProvider).save(newTokens);
      _ref
          .read(authControllerProvider.notifier)
          .updateOperator(refreshRes.operator);
      _lastMeAt = now;
    }
  }

  void _start() {
    if (_started) return;
    _started = true;

    final db = _ref.read(appDbProvider);
    _pendingSub = db.watchPendingPushCount().listen((pending) {
      _pending = pending;
      _ref.read(syncStateProvider.notifier).setPending(pending);
    });

    Connectivity().checkConnectivity().then((results) {
      _connected = results.any((r) => r != ConnectivityResult.none);
    });
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      final connected = results.any((r) => r != ConnectivityResult.none);
      final becameOnline = !_connected && connected;
      _connected = connected;
      if (becameOnline) {
        unawaited(syncOnce(trigger: SyncTrigger.autoOnline));
      }
    });

    final interval = kReleaseMode
        ? const Duration(minutes: 5)
        : const Duration(seconds: 10);
    _autoSyncTimer = Timer.periodic(interval, (_) {
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

  Future<DateTime?> lastPullAt() async {
    final raw = await _storage.read(key: _lastPullAtKey);
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  Future<void> syncOnce({SyncTrigger trigger = SyncTrigger.autoTimer}) async {
    if (_syncInFlight) return;

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

    final pendingBefore = _pending;

    _syncInFlight = true;
    final db = _ref.read(appDbProvider);

    _ref.read(syncStateProvider.notifier).setSyncing(true);
    // Keep operator lock flags reasonably fresh while syncing.
    await _maybeRefreshMe();
    if (pendingBefore > 0) {
      _maybeNotifySyncStarted(trigger: trigger, pending: pendingBefore);
    }
    try {
      await _pushAllPendingWithRetry(trigger: trigger);
      await pullAndMergeAndPrune();
      await _storage.write(
        key: _lastPullAtKey,
        value: DateTime.now().toUtc().toIso8601String(),
      );
      _ref.read(syncStateProvider.notifier).markPull();
      // Consider a successful sync cycle as a “push moment” even if there were 0 mutations.
      _ref.read(syncStateProvider.notifier).markPush();
      _ref.read(syncStateProvider.notifier).setError(null);

      final pendingAfter = await db.countPendingPush();
      final pushed = (pendingBefore - pendingAfter).clamp(0, pendingBefore);
      if (pushed > 0) {
        _ref
            .read(notificationsControllerProvider.notifier)
            .add(
              message: 'Sync completed. Uploaded $pushed record(s).',
              level: AppAlertLevel.success,
            );
      }
    } on DioException catch (e) {
      final msg =
          '${e.type} ${e.response?.statusCode ?? '—'} ${e.message ?? ''}'
              .trim();
      _ref.read(syncStateProvider.notifier).setError(msg);
      dev.log('[SYNC] failed: $msg', name: 'sync');
      _ref
          .read(notificationsControllerProvider.notifier)
          .add(message: 'Sync failed. $msg', level: AppAlertLevel.error);
    } catch (e) {
      _ref.read(syncStateProvider.notifier).setError(e.toString());
      dev.log('[SYNC] failed: $e', name: 'sync');
      _ref
          .read(notificationsControllerProvider.notifier)
          .add(message: 'Sync failed. $e', level: AppAlertLevel.error);
    } finally {
      _syncInFlight = false;
      _ref.read(syncStateProvider.notifier).setSyncing(false);
    }
  }

  Future<void> pullAndMerge() async {
    await pullAndMergeAndPrune();
  }

  Future<void> pullAndMergeAndPrune() async {
    final db = _ref.read(appDbProvider);
    final api = _ref.read(syncApiProvider);
    String? cursor;
    const maxPages = 50;
    final serverIds = <String>{};

    for (var page = 0; page < maxPages; page++) {
      final res = await api.pull(cursor: cursor, limit: 200);
      for (final raw in res.changes) {
        final ch = Map<String, Object?>.from(raw as Map);
        final type = ch['type'] as String?;
        if (type == 'booking_upsert') {
          final b = Map<String, Object?>.from(ch['booking'] as Map);
          final id = b['id'] as String? ?? '';
          if (id.isEmpty) continue;
          serverIds.add(id);
          final status = (b['status'] as String?) ?? 'active';
          final deletedAtRaw = b['deletedAt'] as String?;
          final isDeleted =
              status == 'deleted' ||
              (deletedAtRaw != null && deletedAtRaw.isNotEmpty);
          if (isDeleted) {
            await db.deleteBookingCascade(id);
            continue;
          }
          final localStatus = switch (status) {
            'complete' => 'complete',
            'flagged' => 'flagged',
            _ => 'active',
          };
          final createdAt =
              DateTime.tryParse(b['createdAt'] as String? ?? '') ??
              DateTime.now();
          final completedRaw = b['completedAt'] as String?;
          final endedAt = completedRaw != null && completedRaw.isNotEmpty
              ? DateTime.tryParse(completedRaw)
              : null;
          await db.upsertBooking(
            id: id,
            rackId: (b['rackId'] as String?) ?? '',
            candidateId: (b['candidateId'] as String?) ?? '',
            operatorId: (b['operatorId'] as String?) ?? '',
            status: localStatus,
            startedAt: createdAt,
            endedAt: endedAt,
            pushedStart: true,
            pushedFinish: status == 'complete',
            synced: true,
            lastError: null,
          );
        }
      }
      final next = res.nextCursor;
      if (next == null || next.isEmpty) break;
      cursor = next;
    }

    // Prune local bookings that were previously synced, have no pending pushes,
    // and no longer exist on the server (server-side deletion or empty DB).
    final localBookings = await (db.select(
      db.bookings,
    )..where((t) => t.synced.equals(true))).get();

    var removedForEmptyServer = 0;
    for (final b in localBookings) {
      final hasPending =
          !b.pushedStart || (b.status == 'complete' && !b.pushedFinish);
      if (hasPending) continue;
      if (!serverIds.contains(b.id)) {
        await db.deleteBookingCascade(b.id);
        if (serverIds.isEmpty) removedForEmptyServer += 1;
      }
    }

    if (serverIds.isEmpty && removedForEmptyServer > 0) {
      dev.log(
        '[SYNC] empty server pull: removed $removedForEmptyServer local synced booking(s)',
        name: 'sync',
      );
      _notifyServerWipe(removedCount: removedForEmptyServer);
    }
  }

  /// After a successful pull, the server reported zero bookings; we removed
  /// stale local copies. Pending (unsynced / not fully pushed) rows are kept.
  void _notifyServerWipe({required int removedCount}) {
    _ref
        .read(notificationsControllerProvider.notifier)
        .add(
          title: 'Server booking list empty',
          message:
              'The server has no bookings. Removed $removedCount synced '
              'booking(s) from this device. Pending uploads were kept. '
              'If the database was reset, sign out and sign in again.',
          level: AppAlertLevel.warning,
          kind: AppNotificationKind.sync,
        );

    final navCtx = appNavigatorKey.currentContext;
    if (navCtx == null || !navCtx.mounted) return;

    unawaited(
      showDialog<void>(
        context: navCtx,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Server data reset'),
            content: Text(
              'The server returned no bookings after sync. '
              'Removed $removedCount previously synced booking(s) from this device. '
              'Items still waiting to upload were kept.\n\n'
              'If your database was wiped or migrated, sign out and sign in again.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  unawaited(
                    _ref.read(authControllerProvider.notifier).logout(),
                  );
                },
                child: const Text('Sign out'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _pushAllPendingWithRetry({required SyncTrigger trigger}) async {
    const maxAttempts = 3;
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        await pushAllPending();
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

  Future<void> pushAllPending() async {
    // Push in batches so autosync drains the queue like manual sync.
    // Guardrails: cap iterations and total runtime.
    const maxLoops = 10;
    final started = DateTime.now();
    const budget = Duration(seconds: 45);

    final db = _ref.read(appDbProvider);
    for (var i = 0; i < maxLoops; i++) {
      if (!_connected) return;
      if (DateTime.now().difference(started) > budget) return;

      final before = await db.countPendingPush();
      if (before <= 0) return;

      await pushPending(limit: 200);

      final after = await db.countPendingPush();
      // No progress => stop to avoid tight loops if server rejects everything.
      if (after >= before) return;
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

  void _maybeNotifySyncStarted({
    required SyncTrigger trigger,
    required int pending,
  }) {
    final now = DateTime.now();
    final isManual = trigger == SyncTrigger.manual;
    final last = _lastStartNoticeAt;
    final allow =
        isManual ||
        last == null ||
        now.difference(last) >= const Duration(minutes: 10);
    if (!allow) return;

    _lastStartNoticeAt = now;
    final prefix = switch (trigger) {
      SyncTrigger.manual => 'Sync started',
      SyncTrigger.autoTimer => 'Auto sync started',
      SyncTrigger.autoOnline => 'Auto sync started (back online)',
    };
    _ref
        .read(notificationsControllerProvider.notifier)
        .add(message: '$prefix. Pending: $pending.', level: AppAlertLevel.info);
  }

  Future<void> pushPending({int limit = 200}) async {
    final db = _ref.read(appDbProvider);
    final api = _ref.read(syncApiProvider);

    final pendingScanEvents = await db.listScanEventsNeedingPush(limit: limit);
    final pendingBookings = await db.listBookingsForOutboxPush(limit: limit);
    if (pendingBookings.isEmpty && pendingScanEvents.isEmpty) return;

    final deviceId = await _deviceId();

    final mutationIndex =
        <({String type, String? bookingId, String? scanEventId})>[];
    final mutations = <Map<String, Object?>>[];
    final opLog = <Map<String, Object?>>[];

    for (final s in pendingScanEvents) {
      Map<String, Object?>? meta;
      if (s.metadataJson != null && s.metadataJson!.isNotEmpty) {
        try {
          final decoded = jsonDecode(s.metadataJson!);
          if (decoded is Map<String, Object?>) {
            meta = decoded;
          } else if (decoded is Map) {
            meta = decoded.cast<String, Object?>();
          }
        } catch (_) {
          meta = null;
        }
      }

      final map = <String, Object?>{
        'type': 'scan_event',
        'scanEventId': s.id,
        'operation': s.operation,
        'eventType': s.eventType,
        'occurredAt': s.occurredAt.toIso8601String(),
        if (s.candidateId != null) 'candidateId': s.candidateId,
        if (s.rackId != null) 'rackId': s.rackId,
      };
      if (meta != null) map['metadata'] = meta;
      mutations.add(map);
      mutationIndex.add((
        type: 'scan_event',
        bookingId: null,
        scanEventId: s.id,
      ));
      opLog.add({
        'type': 'scan_event',
        'scanEventId': s.id,
        'operation': s.operation,
        'eventType': s.eventType,
        'candidateId': s.candidateId,
        'rackId': s.rackId,
        'occurredAt': s.occurredAt.toIso8601String(),
      });
    }

    for (final b in pendingBookings) {
      if (!b.pushedStart) {
        mutations.add(<String, Object?>{
          'type': 'booking_start',
          'bookingId': b.id,
          'rackId': b.rackId,
          'candidateId': b.candidateId,
          'startedAt': b.startedAt.toIso8601String(),
        });
        mutationIndex.add((
          type: 'booking_start',
          bookingId: b.id,
          scanEventId: null,
        ));
        opLog.add({
          'type': 'booking_start',
          'bookingId': b.id,
          'candidateId': b.candidateId,
          'rackId': b.rackId,
          'startedAt': b.startedAt.toIso8601String(),
          'status': b.status,
        });
      }

      if (b.status == 'complete' && !b.pushedFinish) {
        mutations.add(<String, Object?>{
          'type': 'booking_finish',
          'bookingId': b.id,
          'endedAt': (b.endedAt ?? DateTime.now()).toIso8601String(),
        });
        mutationIndex.add((
          type: 'booking_finish',
          bookingId: b.id,
          scanEventId: null,
        ));
        opLog.add({
          'type': 'booking_finish',
          'bookingId': b.id,
          'endedAt': (b.endedAt ?? DateTime.now()).toIso8601String(),
        });
      }
    }

    if (mutations.isEmpty) return;

    final res = await api.push(deviceId: deviceId, mutations: mutations);
    var rejected = 0;
    String? firstErr;
    var okCount = 0;

    final count = mutationIndex.length < res.results.length
        ? mutationIndex.length
        : res.results.length;
    for (var i = 0; i < count; i++) {
      final idx = mutationIndex[i];
      final r = res.results[i];
      final ok = r['ok'] == true;
      if (ok) {
        okCount += 1;
        if (idx.type == 'booking_start') {
          await db.markBookingStartPushed(idx.bookingId!);
        } else if (idx.type == 'booking_finish') {
          await db.markBookingFinishPushed(idx.bookingId!);
        } else if (idx.type == 'scan_event' && idx.scanEventId != null) {
          await db.markScanEventPushed(idx.scanEventId!);
        }
      } else {
        final err = (r['error'] as String?) ?? 'REJECTED';
        rejected += 1;
        firstErr ??= err;
        final bid = idx.bookingId;
        if (bid != null) await db.markBookingPushFailed(bid, err);
      }
    }

    // Attach per-operation results for visibility in Notifications.
    final opsWithResults = <Map<String, Object?>>[];
    for (var i = 0; i < opLog.length; i++) {
      final r = i < res.results.length ? (res.results[i] as Map?) : null;
      opsWithResults.add({
        ...opLog[i],
        'ok': r?['ok'] == true,
        if (r?['ok'] != true) 'error': r?['error'],
      });
    }

    _ref
        .read(notificationsControllerProvider.notifier)
        .add(
          title: 'Sync push results',
          message:
              'Push results: OK $okCount, Errors $rejected (device $deviceId)',
          level: rejected > 0 ? AppAlertLevel.warning : AppAlertLevel.success,
          kind: AppNotificationKind.sync,
          details: <String, Object?>{
            'deviceId': deviceId,
            'ok': okCount,
            'errors': rejected,
            'mutations': opsWithResults,
          },
        );

    if (rejected > 0) {
      final msg =
          'server rejected $rejected mutation(s)${firstErr == null ? '' : ': $firstErr'}';
      _ref.read(syncStateProvider.notifier).setError(msg);
      _ref
          .read(notificationsControllerProvider.notifier)
          .add(message: 'Sync warning: $msg', level: AppAlertLevel.warning);
    }

    _ref.read(syncStateProvider.notifier).markPush();
  }

  void dispose() {
    _pendingSub?.cancel();
    _connectivitySub?.cancel();
    _autoSyncTimer?.cancel();
  }
}
