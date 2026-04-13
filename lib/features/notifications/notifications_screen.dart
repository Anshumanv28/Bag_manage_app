import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/alerts.dart';
import '../../app/theme.dart';
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
            Padding(
              padding: const EdgeInsets.only(top: 36),
              child: Column(
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 56,
                    color: AppPalette.secondary.withValues(alpha: 0.65),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'No notifications yet.',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Sync, warnings, and errors will show up here.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppPalette.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
          for (final n in state.items) ...[
            const SizedBox(height: 10),
            Card(
              child: ListTile(
                leading: Icon(_iconFor(n.level), color: _colorFor(context, n.level)),
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

  Color _colorFor(BuildContext context, AppAlertLevel level) {
    return switch (level) {
      AppAlertLevel.info => AppPalette.secondary,
      AppAlertLevel.warning => AppPalette.amber,
      AppAlertLevel.error => Theme.of(context).colorScheme.error,
      AppAlertLevel.success => AppPalette.success,
    };
  }
}

