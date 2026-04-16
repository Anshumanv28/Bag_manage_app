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

  Future<void> _confirmDeleteBooking(
    BuildContext context, {
    required AppDb db,
    required Booking booking,
  }) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete local record?'),
        content: Text(
          'This will delete this booking and related local rows (activities/flags) from this device only.\n\n'
          'Roll: ${booking.candidateId}\n'
          'Rack: ${booking.rackId}\n'
          'ID: ${booking.id}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await db.deleteBookingCascade(booking.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Deleted local booking')));
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
                        trailing: IconButton(
                          tooltip: 'Delete local',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _confirmDeleteBooking(
                            context,
                            db: db,
                            booking: b,
                          ),
                        ),
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
                        leading: const Icon(
                          Icons.check_circle,
                          color: AppPalette.success,
                        ),
                        title: Text('Roll: ${b.candidateId}'),
                        subtitle: Text(
                          'Rack: ${b.rackId} • Retrieved'
                          '${b.endedAt == null ? '' : ' • ${b.endedAt!.toLocal()}'}',
                        ),
                        trailing: IconButton(
                          tooltip: 'Delete local',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _confirmDeleteBooking(
                            context,
                            db: db,
                            booking: b,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ],
              );
            },
          ),

          const SizedBox(height: 16),
          Text('Flagged', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          StreamBuilder<List<Booking>>(
            stream: db.watchBookingsByStatuses(const ['flagged']),
            builder: (context, snap) {
              final bookings = snap.data ?? const <Booking>[];
              if (bookings.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text('No flagged bookings.'),
                );
              }

              return Column(
                children: [
                  for (final b in bookings) ...[
                    Card(
                      child: ListTile(
                        leading: const Icon(
                          Icons.flag_outlined,
                          color: AppPalette.amber,
                        ),
                        title: Text('Roll: ${b.candidateId}'),
                        subtitle: Text('Rack: ${b.rackId} • Flagged'),
                        trailing: IconButton(
                          tooltip: 'Delete local',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _confirmDeleteBooking(
                            context,
                            db: db,
                            booking: b,
                          ),
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
