import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/alerts.dart';
import '../../shared/errors/user_facing_error.dart';
import 'auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;

    if (phone.isEmpty || password.isEmpty) {
      await showAppAlert(
        context,
        ref: ref,
        message: 'Enter phone and password.',
        level: AppAlertLevel.warning,
      );
      return;
    }

    try {
      await ref
          .read(authControllerProvider.notifier)
          .login(phone: phone, password: password);
    } catch (e) {
      if (!mounted) return;
      await showAppAlert(
        context,
        ref: ref,
        message: userFacingAuthError(e),
        level: AppAlertLevel.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authControllerProvider);
    final isLoading = session.isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Operator Login')),
      body: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Phone',
                hintText: '+1 555 123 4567',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: _obscure,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: isLoading ? null : _submit,
                child: isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Sign in'),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Offline-first: you can scan and queue actions when offline.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

