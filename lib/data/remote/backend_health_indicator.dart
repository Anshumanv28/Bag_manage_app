import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'backend_health.dart';

class BackendHealthIndicator extends ConsumerWidget {
  const BackendHealthIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final health = ref.watch(backendHealthProvider);

    final color = health.connected ? Colors.green : Colors.red;
    final icon = health.connected ? Icons.cloud_done : Icons.cloud_off;

    final tooltip = [
      'Backend: ${health.connected ? 'connected' : 'disconnected'}',
      'Origin: ${health.backendOrigin}',
      if (health.lastCheckedAt != null)
        'Checked: ${health.lastCheckedAt!.toIso8601String()}',
      if (health.lastError != null) 'Error: ${health.lastError}',
      'Tap to re-check',
    ].join('\n');

    return IconButton(
      tooltip: tooltip,
      onPressed: () => ref.read(backendHealthProvider.notifier).checkNow(),
      icon: Icon(icon, color: color),
    );
  }
}

