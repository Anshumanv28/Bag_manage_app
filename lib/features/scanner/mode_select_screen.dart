import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/app_db.dart';
import '../auth/auth_controller.dart';
import '../scanner/scan_screen.dart';

class ModeSelectScreen extends ConsumerWidget {
  const ModeSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDbProvider);
    final session = ref.watch(authControllerProvider).maybeWhen(
          data: (s) => s,
          orElse: () => null,
        );
    final depositOk = session?.operator.depositEnabled ?? true;
    final retrieveOk = session?.operator.retrieveEnabled ?? true;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Bag_view', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Scan Candidate ID first. One bag per rack. Push to DB when online.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          _ModeCard(
            title: 'Deposit',
            subtitle: depositOk
                ? 'Candidate ID → Rack ID → Confirm deposit'
                : 'Disabled for your account. Contact an admin.',
            icon: Icons.add_box_outlined,
            badgeText: null,
            enabled: depositOk,
            onDisabledTap: () => _showModeLocked(context, deposit: true),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ScanScreen(operation: SopOperation.deposit),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          StreamBuilder<List<Booking>>(
            stream: db.watchBookings(status: 'active'),
            builder: (context, snap) {
              final pendingRetrievals = (snap.data ?? const <Booking>[]).length;
              final badgeText =
                  pendingRetrievals > 0 ? '$pendingRetrievals pending' : null;
              return _ModeCard(
                title: 'Retrieve',
                subtitle: retrieveOk
                    ? 'Candidate ID → Confirm return'
                    : 'Disabled for your account. Contact an admin.',
                icon: Icons.inventory_2_outlined,
                badgeText: badgeText,
                enabled: retrieveOk,
                onDisabledTap: () => _showModeLocked(context, deposit: false),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ScanScreen(operation: SopOperation.retrieve),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

Future<void> _showModeLocked(BuildContext context, {required bool deposit}) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(deposit ? 'Deposit locked' : 'Retrieve locked'),
      content: Text(
        deposit
            ? 'Deposit is turned off for your operator account. Ask an admin to enable it in the dashboard.'
            : 'Retrieve is turned off for your operator account. Ask an admin to enable it in the dashboard.',
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
      ],
    ),
  );
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.badgeText,
    required this.onTap,
    this.enabled = true,
    this.onDisabledTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String? badgeText;
  final VoidCallback onTap;
  final bool enabled;
  final VoidCallback? onDisabledTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: enabled ? onTap : () => onDisabledTap?.call(),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: enabled
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                foregroundColor: enabled
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                child: Icon(icon),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
                        ),
                        if (badgeText != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              badgeText!,
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

