import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/alerts.dart';

class AppNotification {
  const AppNotification({
    required this.id,
    required this.message,
    required this.level,
    required this.createdAt,
    required this.read,
  });

  final int id;
  final String message;
  final AppAlertLevel level;
  final DateTime createdAt;
  final bool read;

  AppNotification copyWith({bool? read}) => AppNotification(
        id: id,
        message: message,
        level: level,
        createdAt: createdAt,
        read: read ?? this.read,
      );
}

class NotificationsState {
  const NotificationsState({required this.items, required this.nextId});
  final List<AppNotification> items;
  final int nextId;

  int get unreadCount => items.where((n) => !n.read).length;
}

final notificationsControllerProvider =
    NotifierProvider<NotificationsController, NotificationsState>(NotificationsController.new);

class NotificationsController extends Notifier<NotificationsState> {
  @override
  NotificationsState build() => const NotificationsState(items: [], nextId: 1);

  void add({required String message, required AppAlertLevel level}) {
    final n = AppNotification(
      id: state.nextId,
      message: message,
      level: level,
      createdAt: DateTime.now(),
      read: false,
    );
    state = NotificationsState(items: [n, ...state.items], nextId: state.nextId + 1);
  }

  void markAllRead() {
    state = NotificationsState(
      items: [for (final n in state.items) n.read ? n : n.copyWith(read: true)],
      nextId: state.nextId,
    );
  }

  void clear() => state = NotificationsState(items: const [], nextId: state.nextId);
}

