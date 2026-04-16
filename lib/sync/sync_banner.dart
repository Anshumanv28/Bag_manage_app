import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/theme.dart';
import '../data/local/app_db.dart';
import '../data/remote/health_api.dart';
import 'sync_service.dart';
import 'sync_state.dart';

class SyncBanner extends ConsumerStatefulWidget {
  const SyncBanner({super.key});

  @override
  ConsumerState<SyncBanner> createState() => _SyncBannerState();
}

class _SyncBannerState extends ConsumerState<SyncBanner> {
  bool _syncing = false;

  Future<void> _openPendingSheet(BuildContext context) async {
    final db = ref.read(appDbProvider);

    // Snapshot the current pending sets for a simple viewer.
    final bookings = await db.listBookingsNeedingPush(limit: 200);
    final scanEvents = await db.listScanEventsNeedingPush(limit: 200);

    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SizedBox(
              height: MediaQuery.of(ctx).size.height * 0.75,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pending sync operations',
                    style: Theme.of(ctx).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bookings: ${bookings.length} • Scan events: ${scanEvents.length}',
                    style: Theme.of(ctx).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Note: scan events may auto-sync before you confirm a deposit/return, so the pending count can change during the flow.',
                    style: Theme.of(ctx).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView(
                      children: [
                        if (bookings.isNotEmpty) ...[
                          Text(
                            'Bookings',
                            style: Theme.of(ctx).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 6),
                          for (final b in bookings)
                            ListTile(
                              dense: true,
                              leading: const Icon(Icons.inventory_2_outlined),
                              title: Text(
                                'Roll ${b.candidateId} • Rack ${b.rackId}',
                              ),
                              subtitle: Text(
                                '${b.id}\nneeds: '
                                '${b.pushedStart ? '' : 'booking_start '}'
                                '${(b.status == 'complete' && !b.pushedFinish) ? 'booking_finish' : ''}',
                              ),
                              isThreeLine: true,
                            ),
                          const Divider(),
                        ],
                        if (scanEvents.isNotEmpty) ...[
                          Text(
                            'Scan events',
                            style: Theme.of(ctx).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 6),
                          for (final s in scanEvents)
                            ListTile(
                              dense: true,
                              leading: const Icon(Icons.qr_code_scanner),
                              title: Text('${s.operation} • ${s.eventType}'),
                              subtitle: Text(
                                '${s.id}\n'
                                '${s.candidateId ?? ''}${s.candidateId != null && s.rackId != null ? ' • ' : ''}${s.rackId ?? ''}',
                              ),
                              isThreeLine: true,
                            ),
                        ],
                        if (bookings.isEmpty && scanEvents.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 24),
                            child: Text('No pending operations.'),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () async {
                            Navigator.of(ctx).pop();
                            await _syncNow(context);
                          },
                          icon: const Icon(Icons.sync),
                          label: const Text('Sync now'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _syncNow(BuildContext context) async {
    if (_syncing) return;

    setState(() => _syncing = true);

    final stage = ValueNotifier<String>('Checking server…');

    // Lock UI: modal, non-dismissible progress dialog (health + upload).
    if (context.mounted) {
      // ignore: unawaited_futures
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return PopScope(
            canPop: false,
            child: AlertDialog(
              title: const Text('Syncing…'),
              content: ValueListenableBuilder<String>(
                valueListenable: stage,
                builder: (context, value, _) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Please do not close the app while data is pushed to the server and the latest bookings are pulled.',
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text(value)),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      );
    }

    final results = await Connectivity().checkConnectivity();
    final online = results.any((r) => r != ConnectivityResult.none);
    if (!online) {
      ref.read(syncStateProvider.notifier).setError('device offline');
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Device offline')));
      if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
      if (mounted) setState(() => _syncing = false);
      stage.dispose();
      return;
    }

    final health = await ref
        .read(healthApiProvider)
        .isHealthy()
        .catchError((_) => false);
    if (!health) {
      ref.read(syncStateProvider.notifier).setError('server unhealthy');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Server is unavailable. Try again shortly.'),
        ),
      );
      if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
      if (mounted) setState(() => _syncing = false);
      stage.dispose();
      return;
    }

    stage.value = 'Pushing local changes and pulling from server…';

    try {
      await ref.read(syncServiceProvider).syncOnce(trigger: SyncTrigger.manual);
    } finally {
      if (mounted) setState(() => _syncing = false);
      if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
      stage.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(syncStateProvider);
    final pending = status.pendingMutations;
    final syncing = status.syncing;
    final hasError = status.lastError != null && status.lastError!.isNotEmpty;
    final isOffline = (status.lastError ?? '').toLowerCase().contains(
      'offline',
    );

    final Color? bg = switch ((pending == 0, isOffline, hasError)) {
      (true, _, false) => AppPalette.successSoft,
      (_, true, _) => AppPalette.amberSoft,
      _ => null,
    };
    final Color? fg = switch ((pending == 0, isOffline, hasError)) {
      (true, _, false) => AppPalette.success,
      (_, true, _) => AppPalette.amber,
      _ => hasError ? Theme.of(context).colorScheme.error : null,
    };

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        child: Card(
          color: bg,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: syncing ? null : () => _openPendingSheet(context),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(
                    pending > 0
                        ? Icons.cloud_upload_outlined
                        : Icons.cloud_done_outlined,
                    color: fg,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          pending > 0
                              ? 'Pending sync (bookings + scans): $pending'
                              : 'All synced',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        if (syncing)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              'Syncing…',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          )
                        else if (hasError)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              status.lastError!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: fg),
                            ),
                          )
                        else
                          Text(
                            'Last push: ${status.lastPushAt?.toIso8601String() ?? '—'}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  FilledButton.icon(
                    onPressed: _syncing || syncing
                        ? null
                        : () => _syncNow(context),
                    icon: (_syncing || syncing)
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.sync),
                    label: Text(
                      (_syncing || syncing) ? 'Syncing…' : 'Sync now',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
