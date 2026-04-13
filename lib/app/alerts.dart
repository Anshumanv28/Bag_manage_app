import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/notifications/notifications_controller.dart';

enum AppAlertLevel { info, warning, error, success }

String _titleFor(AppAlertLevel level) {
  return switch (level) {
    AppAlertLevel.info => 'Info',
    AppAlertLevel.warning => 'Attention',
    AppAlertLevel.error => 'Error',
    AppAlertLevel.success => 'Success',
  };
}

IconData _iconFor(AppAlertLevel level) {
  return switch (level) {
    AppAlertLevel.info => Icons.info_outline,
    AppAlertLevel.warning => Icons.warning_amber_rounded,
    AppAlertLevel.error => Icons.error_outline,
    AppAlertLevel.success => Icons.check_circle_outline,
  };
}

Color _accentColor(ColorScheme cs, AppAlertLevel level) {
  return switch (level) {
    AppAlertLevel.info => cs.primary,
    AppAlertLevel.warning => cs.tertiary,
    AppAlertLevel.error => cs.error,
    AppAlertLevel.success => cs.secondary,
  };
}

Future<void> showAppAlert(
  BuildContext context, {
  required WidgetRef ref,
  required String message,
  AppAlertLevel level = AppAlertLevel.info,
}) async {
  ref.read(notificationsControllerProvider.notifier).add(
        message: message,
        level: level,
      );

  if (!context.mounted) return;
  final cs = Theme.of(context).colorScheme;
  final accent = _accentColor(cs, level);

  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Row(
        children: [
          Icon(_iconFor(level), color: accent),
          const SizedBox(width: 10),
          Expanded(child: Text(_titleFor(level))),
        ],
      ),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

