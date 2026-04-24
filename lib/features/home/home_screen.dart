import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_controller.dart';
import '../bookings/bookings_done_screen.dart';
import '../notifications/notifications_controller.dart';
import '../notifications/notifications_screen.dart';
import '../profile/profile_screen.dart';
import '../scanner/mode_select_screen.dart';
import '../../sync/sync_banner.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authControllerProvider).maybeWhen(
          data: (v) => v,
          orElse: () => null,
        );
    final operatorName = session?.operator.name ?? '';

    final unread = ref.watch(notificationsControllerProvider).unreadCount;

    final pages = const [
      ModeSelectScreen(),
      BookingsDoneScreen(),
      NotificationsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: Image.asset(
            'assets/bag_view_logo.png',
            fit: BoxFit.contain,
          ),
        ),
        title: Text(operatorName.isEmpty ? 'Bag_view' : 'Hi, $operatorName'),
        actions: [
          IconButton(
            tooltip: 'Profile',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
            icon: const Icon(Icons.support_agent),
          ),
        ],
      ),
      body: pages[_index],
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SyncBanner(),
          NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: [
              NavigationDestination(icon: Icon(Icons.qr_code_scanner), label: 'Scan'),
              NavigationDestination(icon: Icon(Icons.event_note), label: 'Records'),
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: unread > 0,
                  label: Text('$unread'),
                  child: Icon(Icons.notifications_none),
                ),
                label: 'Alerts',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

