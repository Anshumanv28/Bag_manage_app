import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'sync_state.dart';

class SyncStatusWidget extends ConsumerWidget {
  const SyncStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(syncStateProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Push to DB', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Pending: ${status.pendingMutations}'),
            Text('Syncing: ${status.syncing ? 'yes' : 'no'}'),
            Text('Last push: ${status.lastPushAt?.toIso8601String() ?? '—'}'),
            if (status.lastError != null) ...[
              const SizedBox(height: 8),
              Text(
                'Last error: ${status.lastError}',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

