import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../app/time_format.dart';
import '../../data/remote/sync_status_api.dart';
import '../auth/auth_controller.dart';

final operatorSyncLatestProvider =
    FutureProvider.autoDispose<OperatorSyncStatusResponse>((ref) async {
  final api = ref.read(syncStatusApiProvider);
  return api.latestByOperator();
});

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authControllerProvider).maybeWhen(
          data: (v) => v,
          orElse: () => null,
        );

    final phone = session?.operator.phone ?? '';
    final name = session?.operator.name ?? '';
    final initials = _initialsFor(name.isEmpty ? 'Operator' : name);
    final syncLatest = ref.watch(operatorSyncLatestProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppPalette.navSelectedPill,
                      foregroundColor: AppPalette.primary,
                      child: Text(
                        initials,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name.isEmpty ? 'Operator' : name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppPalette.textPrimary,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            phone.isEmpty ? '—' : phone,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppPalette.textSecondary,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Operator last sync',
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: AppPalette.textSecondary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Refresh',
                          onPressed: () => ref.invalidate(operatorSyncLatestProvider),
                          icon: const Icon(Icons.refresh),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    syncLatest.when(
                      data: (res) {
                        final rows = res.rows;
                        if (rows.isEmpty) {
                          return Text(
                            'No sync activity yet.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppPalette.textSecondary,
                                ),
                          );
                        }
                        final now = DateTime.now();
                        return Column(
                          children: rows.take(12).map((r) {
                            final rel = _relativeSyncTime(now, r.lastSyncAt);
                            final stale = _isStale(now, r.lastSyncAt);
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${r.name.isEmpty ? 'Operator' : r.name} · ${r.operatorId}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: AppPalette.textPrimary,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    rel,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: stale ? AppPalette.danger : AppPalette.textSecondary,
                                          fontWeight: stale ? FontWeight.w800 : FontWeight.w600,
                                        ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      },
                      loading: () => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: LinearProgressIndicator(minHeight: 2),
                      ),
                      error: (_, _) => Text(
                        'Failed to load operator sync status.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppPalette.danger,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Showing up to 12 operators. Refresh to update.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppPalette.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Session',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: AppPalette.textSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: () async {
                          await ref.read(authControllerProvider.notifier).logout();
                          if (!context.mounted) return;
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text('Logout'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _relativeSyncTime(DateTime now, DateTime? lastSyncAt) {
  if (lastSyncAt == null) return 'Never';
  final diff = toIst(now).difference(toIst(lastSyncAt));
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}

bool _isStale(DateTime now, DateTime? lastSyncAt) {
  if (lastSyncAt == null) return true;
  return toIst(now).difference(toIst(lastSyncAt)) > const Duration(minutes: 30);
}

String _initialsFor(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((p) => p.isNotEmpty)
      .toList(growable: false);
  if (parts.isEmpty) return 'OP';
  final first = parts.first.characters.first.toUpperCase();
  final second = parts.length > 1 ? parts[1].characters.first.toUpperCase() : '';
  final v = '$first$second';
  return v.isEmpty ? 'OP' : v;
}

