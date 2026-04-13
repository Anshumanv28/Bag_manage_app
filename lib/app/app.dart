import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/auth_controller.dart';
import '../features/auth/login_screen.dart';
import '../features/home/home_screen.dart';
import '../sync/sync_service.dart';
import 'theme.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Start background sync loops (no-op until logged in).
    ref.watch(syncServiceProvider);

    final session = ref.watch(authControllerProvider);

    return MaterialApp(
      title: 'Baggage Management',
      theme: appTheme(),
      home: session.when(
        loading: () => const _Splash(),
        error: (e, _) => _ErrorScreen(error: e),
        data: (s) => s == null ? const LoginScreen() : const HomeScreen(),
      ),
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen({required this.error});
  final Object error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('App init error: $error'),
        ),
      ),
    );
  }
}

