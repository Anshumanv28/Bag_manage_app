import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/config.dart';
import 'health_api.dart';

@immutable
class BackendHealthState {
  const BackendHealthState({
    required this.backendOrigin,
    required this.connected,
    required this.lastCheckedAt,
    required this.lastOkAt,
    required this.lastError,
  });

  final String backendOrigin;
  final bool connected;
  final DateTime? lastCheckedAt;
  final DateTime? lastOkAt;
  final String? lastError;

  BackendHealthState copyWith({
    String? backendOrigin,
    bool? connected,
    DateTime? lastCheckedAt,
    DateTime? lastOkAt,
    String? lastError,
  }) {
    return BackendHealthState(
      backendOrigin: backendOrigin ?? this.backendOrigin,
      connected: connected ?? this.connected,
      lastCheckedAt: lastCheckedAt ?? this.lastCheckedAt,
      lastOkAt: lastOkAt ?? this.lastOkAt,
      lastError: lastError,
    );
  }
}

final backendHealthProvider =
    NotifierProvider<BackendHealthController, BackendHealthState>(
  BackendHealthController.new,
);

class BackendHealthController extends Notifier<BackendHealthState> {
  Timer? _timer;

  @override
  BackendHealthState build() {
    ref.onDispose(() => _timer?.cancel());

    state = BackendHealthState(
      backendOrigin: AppConfig.backendOrigin,
      connected: false,
      lastCheckedAt: null,
      lastOkAt: null,
      lastError: null,
    );

    // Kick off immediately, then poll occasionally.
    unawaited(checkNow());
    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      unawaited(checkNow());
    });

    return state;
  }

  Future<void> checkNow() async {
    final results = await Connectivity().checkConnectivity();
    if (results.every((r) => r == ConnectivityResult.none)) {
      state = state.copyWith(
        backendOrigin: AppConfig.backendOrigin,
        connected: false,
        lastCheckedAt: DateTime.now(),
        lastOkAt: state.lastOkAt,
        lastError: 'offline',
      );
      return;
    }

    final api = ref.read(healthApiProvider);
    final startedAt = DateTime.now();

    try {
      final ok = await api.isHealthy();
      final now = DateTime.now();
      state = state.copyWith(
        backendOrigin: AppConfig.backendOrigin,
        connected: ok,
        lastCheckedAt: now,
        lastOkAt: ok ? now : state.lastOkAt,
        lastError: ok ? null : 'Unhealthy response',
      );
    } catch (e) {
      state = state.copyWith(
        backendOrigin: AppConfig.backendOrigin,
        connected: false,
        lastCheckedAt: DateTime.now(),
        lastOkAt: state.lastOkAt,
        lastError:
            'Health check failed after ${DateTime.now().difference(startedAt).inMilliseconds}ms: $e',
      );
    }
  }
}

