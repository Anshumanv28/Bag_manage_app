import 'package:flutter_riverpod/flutter_riverpod.dart';

class SyncState {
  const SyncState({
    required this.cursor,
    required this.pendingMutations,
    required this.lastPullAt,
    required this.lastPushAt,
    required this.lastError,
  });

  final String? cursor;
  final int pendingMutations;
  final DateTime? lastPullAt;
  final DateTime? lastPushAt;
  final String? lastError;

  SyncState copyWith({
    String? cursor,
    int? pendingMutations,
    DateTime? lastPullAt,
    DateTime? lastPushAt,
    String? lastError,
  }) {
    return SyncState(
      cursor: cursor ?? this.cursor,
      pendingMutations: pendingMutations ?? this.pendingMutations,
      lastPullAt: lastPullAt ?? this.lastPullAt,
      lastPushAt: lastPushAt ?? this.lastPushAt,
      lastError: lastError,
    );
  }
}

final syncStateProvider =
    NotifierProvider<SyncStateController, SyncState>(SyncStateController.new);

class SyncStateController extends Notifier<SyncState> {
  @override
  SyncState build() {
    return const SyncState(
      cursor: null,
      pendingMutations: 0,
      lastPullAt: null,
      lastPushAt: null,
      lastError: null,
    );
  }

  void setCursor(String? cursor) => state = state.copyWith(cursor: cursor);
  void setPending(int pending) => state = state.copyWith(pendingMutations: pending);
  void markPull() => state = state.copyWith(lastPullAt: DateTime.now());
  void markPush() => state = state.copyWith(lastPushAt: DateTime.now());
  void setError(String? error) => state = state.copyWith(lastError: error);
}

