import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/app_db.dart';
import '../../app/theme.dart';

class BookingsDoneScreen extends ConsumerWidget {
  const BookingsDoneScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    // Local-first: refresh just re-builds from Drift streams.
    await Future<void>.value();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDbProvider);

    return RefreshIndicator(
      onRefresh: () => _refresh(ref),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Records', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),

          Text('Deposited', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          StreamBuilder<List<Booking>>(
            stream: db.watchBookings(status: 'active'),
            builder: (context, snap) {
              final bookings = snap.data ?? const <Booking>[];
              if (bookings.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 24),
                  child: Text('No deposited bags.'),
                );
              }

              return Column(
                children: [
                  for (final b in bookings) ...[
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.inventory_2_outlined),
                        title: Text('Roll: ${b.candidateId}'),
                        subtitle: Text('Rack: ${b.rackId}'),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ],
              );
            },
          ),

          const SizedBox(height: 8),
          Text('Retrieved', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          StreamBuilder<List<Booking>>(
            stream: db.watchBookingsByStatuses(const ['complete']),
            builder: (context, snap) {
              final bookings = snap.data ?? const <Booking>[];
              if (bookings.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text('No retrieved records yet.'),
                );
              }

              return Column(
                children: [
                  for (final b in bookings) ...[
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.check_circle, color: AppPalette.success),
                        title: Text('Roll: ${b.candidateId}'),
                        subtitle: Text(
                          'Rack: ${b.rackId} • Retrieved'
                          '${b.endedAt == null ? '' : ' • ${b.endedAt!.toLocal()}'}',
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

