import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/app_db.dart';
import '../../app/theme.dart';

class BookingsDoneScreen extends ConsumerStatefulWidget {
  const BookingsDoneScreen({super.key});

  @override
  ConsumerState<BookingsDoneScreen> createState() => _BookingsDoneScreenState();
}

class _BookingsDoneScreenState extends ConsumerState<BookingsDoneScreen>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  static const _scrollKey = PageStorageKey<String>('recordsScroll');

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    // Local-first: refresh just re-builds from Drift streams.
    await Future<void>.value();
  }

  bool _matches(Booking b) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return b.rackId.toLowerCase().contains(q) ||
        b.candidateId.toLowerCase().contains(q);
  }

  Widget _searchBar(BuildContext context) {
    return TextField(
      controller: _searchController,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search by Rack ID or Roll No.',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _query.trim().isEmpty
            ? null
            : IconButton(
                tooltip: 'Clear',
                onPressed: () {
                  _searchController.clear();
                  setState(() => _query = '');
                },
                icon: const Icon(Icons.clear),
              ),
      ),
      onChanged: (v) => setState(() => _query = v),
    );
  }

  Widget _bookingCard({
    required Booking b,
    required Icon leading,
    required String subtitle,
    required Key key,
  }) {
    return Card(
      key: key,
      child: ListTile(
        leading: leading,
        title: Text('Roll: ${b.candidateId}'),
        subtitle: Text(subtitle),
      ),
    );
  }

  SliverList _bookingSliver({
    required List<Booking> bookings,
    required String keyPrefix,
    required Widget Function(Booking b) buildCard,
  }) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, idx) {
          final b = bookings[idx];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: buildCard(b),
          );
        },
        childCount: bookings.length,
      ),
    );
  }

  // Future<void> _confirmDeleteBooking(
  //   BuildContext context, {
  //   required AppDb db,
  //   required Booking booking,
  // }) async {
  //   final ok = await showDialog<bool>(
  //     context: context,
  //     builder: (ctx) => AlertDialog(
  //       title: const Text('Delete local record?'),
  //       content: Text(
  //         'This will delete this booking and related local rows (activities/flags) from this device only.\n\n'
  //         'Roll: ${booking.candidateId}\n'
  //         'Rack: ${booking.rackId}\n'
  //         'ID: ${booking.id}',
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.of(ctx).pop(false),
  //           child: const Text('Cancel'),
  //         ),
  //         FilledButton(
  //           onPressed: () => Navigator.of(ctx).pop(true),
  //           child: const Text('Delete'),
  //         ),
  //       ],
  //     ),
  //   );
  //   if (ok != true) return;
  //   await db.deleteBookingCascade(booking.id);
  //   if (!context.mounted) return;
  //   ScaffoldMessenger.of(
  //     context,
  //   ).showSnackBar(const SnackBar(content: Text('Deleted local booking')));
  // }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final db = ref.watch(appDbProvider);

    return RefreshIndicator(
      onRefresh: _refresh,
      child: CustomScrollView(
        key: _scrollKey,
        controller: _scrollController,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate.fixed(
                [
                  Text('Records', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  _searchBar(context),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Deposited',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          const SliverPadding(
            padding: EdgeInsets.only(left: 16, right: 16, top: 8),
            sliver: SliverToBoxAdapter(child: SizedBox.shrink()),
          ),
          StreamBuilder<List<Booking>>(
            stream: db.watchBookings(status: 'active'),
            builder: (context, snap) {
              final all = snap.data ?? const <Booking>[];
              final bookings = all.where(_matches).toList(growable: false);
              if (bookings.isEmpty) {
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      _query.trim().isEmpty
                          ? 'No deposited bags.'
                          : 'No matches in Deposited.',
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                sliver: _bookingSliver(
                  bookings: bookings,
                  keyPrefix: 'active',
                  buildCard: (b) => _bookingCard(
                    key: ValueKey('active-${b.id}'),
                    b: b,
                    leading: const Icon(Icons.inventory_2_outlined),
                    subtitle: 'Rack: ${b.rackId}',
                  ),
                ),
              );
            },
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Retrieved',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          StreamBuilder<List<Booking>>(
            stream: db.watchBookingsByStatuses(const ['complete']),
            builder: (context, snap) {
              final all = snap.data ?? const <Booking>[];
              final bookings = all.where(_matches).toList(growable: false);
              if (bookings.isEmpty) {
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      _query.trim().isEmpty
                          ? 'No retrieved records yet.'
                          : 'No matches in Retrieved.',
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                sliver: _bookingSliver(
                  bookings: bookings,
                  keyPrefix: 'complete',
                  buildCard: (b) => _bookingCard(
                    key: ValueKey('complete-${b.id}'),
                    b: b,
                    leading: const Icon(
                      Icons.check_circle,
                      color: AppPalette.success,
                    ),
                    subtitle:
                        'Rack: ${b.rackId} • Retrieved${b.endedAt == null ? '' : ' • ${b.endedAt!.toLocal()}'}',
                  ),
                ),
              );
            },
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Flagged',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          StreamBuilder<List<Booking>>(
            stream: db.watchBookingsByStatuses(const ['flagged']),
            builder: (context, snap) {
              final all = snap.data ?? const <Booking>[];
              final bookings = all.where(_matches).toList(growable: false);
              if (bookings.isEmpty) {
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      _query.trim().isEmpty
                          ? 'No flagged bookings.'
                          : 'No matches in Flagged.',
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                sliver: _bookingSliver(
                  bookings: bookings,
                  keyPrefix: 'flagged',
                  buildCard: (b) => _bookingCard(
                    key: ValueKey('flagged-${b.id}'),
                    b: b,
                    leading: const Icon(
                      Icons.flag_outlined,
                      color: AppPalette.amber,
                    ),
                    subtitle: 'Rack: ${b.rackId} • Flagged',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
