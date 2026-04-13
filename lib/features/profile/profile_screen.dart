import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../auth/auth_controller.dart';

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
            const Spacer(),
            SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await ref.read(authControllerProvider.notifier).logout();
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
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

