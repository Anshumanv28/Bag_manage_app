import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/alerts.dart';

enum AppNotificationKind { general, sync }

class AppNotification {
  const AppNotification({
    required this.id,
    this.title,
    required this.message,
    required this.level,
    required this.createdAt,
    required this.read,
    this.kind = AppNotificationKind.general,
    this.details,
  });

  final int id;
  final String? title;
  final String message;
  final AppAlertLevel level;
  final DateTime createdAt;
  final bool read;
  final AppNotificationKind kind;
  final Map<String, Object?>? details;

  AppNotification copyWith({bool? read}) => AppNotification(
        id: id,
        title: title,
        message: message,
        level: level,
        createdAt: createdAt,
        read: read ?? this.read,
        kind: kind,
        details: details,
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

  void add({
    String? title,
    required String message,
    required AppAlertLevel level,
    AppNotificationKind kind = AppNotificationKind.general,
    Map<String, Object?>? details,
  }) {
    final n = AppNotification(
      id: state.nextId,
      title: title,
      message: message,
      level: level,
      createdAt: DateTime.now(),
      read: false,
      kind: kind,
      details: details,
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

