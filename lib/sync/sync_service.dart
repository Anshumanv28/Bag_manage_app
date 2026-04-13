import 'dart:async';
import 'dart:developer' as dev;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../data/local/app_db.dart';
import '../data/remote/sync_api.dart';
import '../data/remote/tokens.dart';
import 'sync_state.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  final service = SyncService(ref);
  service._start();
  ref.onDispose(service.dispose);
  return service;
});

class SyncService {
  SyncService(this._ref);

  final Ref _ref;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const _deviceIdKey = 'deviceId';

  bool _started = false;
  bool _syncInFlight = false;
  bool _connected = true;
  StreamSubscription<int>? _pendingSub;
  StreamSubscription? _connectivitySub;

  void _start() {
    if (_started) return;
    _started = true;

    final db = _ref.read(appDbProvider);
    _pendingSub = db.watchPendingPushCount().listen((pending) {
      _ref.read(syncStateProvider.notifier).setPending(pending);
    });

    // Track connectivity so manual refresh doesn't hang on timeouts when offline.
    Connectivity().checkConnectivity().then((results) {
      _connected = results.any((r) => r != ConnectivityResult.none);
    });
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      final connected = results.any((r) => r != ConnectivityResult.none);
      _connected = connected;
    });
  }

  Future<String> _deviceId() async {
    final existing = await _storage.read(key: _deviceIdKey);
    if (existing != null && existing.isNotEmpty) return existing;
    final generated = DateTime.now().microsecondsSinceEpoch.toString();
    await _storage.write(key: _deviceIdKey, value: generated);
    return generated;
  }

  Future<void> syncOnce() async {
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

    _syncInFlight = true;
    try {
      await pushPending();
      _ref.read(syncStateProvider.notifier).setError(null);
    } on DioException catch (e) {
      final msg =
          '${e.type} ${e.response?.statusCode ?? '—'} ${e.message ?? ''}'.trim();
      _ref.read(syncStateProvider.notifier).setError(msg);
      dev.log('[SYNC] failed: $msg', name: 'sync');
    } catch (e) {
      _ref.read(syncStateProvider.notifier).setError(e.toString());
      dev.log('[SYNC] failed: $e', name: 'sync');
    } finally {
      _syncInFlight = false;
    }
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
  }
}

