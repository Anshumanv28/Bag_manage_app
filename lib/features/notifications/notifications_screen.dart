import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/alerts.dart';
import 'notifications_controller.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationsControllerProvider);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Notifications', style: Theme.of(context).textTheme.titleLarge),
              ),
              TextButton(
                onPressed: state.items.isEmpty
                    ? null
                    : () => ref.read(notificationsControllerProvider.notifier).markAllRead(),
                child: const Text('Mark read'),
              ),
              TextButton(
                onPressed: state.items.isEmpty
                    ? null
                    : () => ref.read(notificationsControllerProvider.notifier).clear(),
                child: const Text('Clear'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (state.items.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 24),
              child: Text('No notifications yet.'),
            ),
          for (final n in state.items) ...[
            const SizedBox(height: 10),
            Card(
              child: ListTile(
                leading: Icon(_iconFor(n.level)),
                title: Text(n.message),
                subtitle: Text(n.createdAt.toLocal().toIso8601String()),
                trailing: n.read ? null : const Icon(Icons.circle, size: 10),
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _iconFor(AppAlertLevel level) {
    return switch (level) {
      AppAlertLevel.info => Icons.info_outline,
      AppAlertLevel.warning => Icons.warning_amber_rounded,
      AppAlertLevel.error => Icons.error_outline,
      AppAlertLevel.success => Icons.check_circle_outline,
    };
  }
}

