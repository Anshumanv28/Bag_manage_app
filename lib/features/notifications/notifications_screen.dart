import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/alerts.dart';
import '../../app/theme.dart';
import 'notifications_controller.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  void _openDetails(BuildContext context, AppNotification n) {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        final details = n.details;
        final muts = (details?['mutations'] is List) ? (details!['mutations'] as List) : const [];
        return AlertDialog(
          title: Text(n.title ?? 'Notification'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(n.message),
                  const SizedBox(height: 8),
                  Text(
                    'Created: ${n.createdAt.toLocal().toIso8601String()}',
                    style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                          color: AppPalette.textSecondary,
                        ),
                  ),
                  if (n.kind == AppNotificationKind.sync && details != null) ...[
                    const SizedBox(height: 12),
                    Text('Sync details', style: Theme.of(ctx).textTheme.titleSmall),
                    const SizedBox(height: 6),
                    Text(
                      'Device: ${details['deviceId'] ?? '—'} • OK: ${details['ok'] ?? 0} • Errors: ${details['errors'] ?? 0}',
                      style: Theme.of(ctx).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 10),
                    if (muts.isNotEmpty)
                      ...muts.map((raw) {
                        final m = raw is Map ? raw : const {};
                        final ok = m['ok'] == true;
                        final type = m['type']?.toString() ?? '—';
                        final id = (m['bookingId'] ??
                                m['activityId'] ??
                                m['scanEventId'] ??
                                m['id'])
                            ?.toString();
                        final err = m['error']?.toString();
                        final subtitleBits = <String>[
                          if (id != null && id.isNotEmpty) id,
                          if (m['candidateId'] != null) 'cand ${m['candidateId']}',
                          if (m['rackId'] != null) 'rack ${m['rackId']}',
                        ];
                        return ListTile(
                          dense: true,
                          leading: Icon(
                            ok ? Icons.check_circle_outline : Icons.error_outline,
                            color: ok ? AppPalette.success : Theme.of(ctx).colorScheme.error,
                          ),
                          title: Text(type),
                          subtitle: Text(
                            '${subtitleBits.join(' • ')}${err == null ? '' : '\n$err'}',
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                          isThreeLine: err != null,
                        );
                      }),
                    if (muts.isEmpty)
                      const Text('No operation details attached.'),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

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
                onTap: () => _openDetails(context, n),
                leading: Icon(_iconFor(n.level), color: _colorFor(context, n.level)),
                title: Text(
                  n.title ?? n.message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  n.createdAt.toLocal().toIso8601String(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
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

