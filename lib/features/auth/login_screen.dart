import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

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
  String? _inlineError;
  bool _isOfflineError = false;
  bool _invalidCredentials = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _inlineError = null;
      _isOfflineError = false;
      _invalidCredentials = false;
      _isSubmitting = true;
    });

    if (phone.isEmpty || password.isEmpty) {
      setState(() => _isSubmitting = false);
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
      if (!mounted) return;
      setState(() => _isSubmitting = false);
    } catch (e) {
      if (!mounted) return;
      final offline = _isOffline(e);
      final invalidCreds = _isInvalidCredentials(e);
      setState(() {
        _isOfflineError = offline;
        _invalidCredentials = invalidCreds;
        _inlineError = offline
            ? 'You appear to be offline. Check your connection and try again.'
            : (invalidCreds
                ? 'Username or password is wrong.'
                : userFacingAuthError(e));
        _isSubmitting = false;
      });
    }
  }

  bool _isOffline(Object e) {
    if (e is DioException) {
      return e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout;
    }
    return false;
  }

  bool _isInvalidCredentials(Object e) {
    if (e is DioException) {
      final status = e.response?.statusCode;
      if (status == 401) return true;
      final data = e.response?.data;
      if (data is Map && data['error'] == 'INVALID_CREDENTIALS') return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = _isSubmitting;

    return Scaffold(
      appBar: AppBar(title: const Text('Operator Login')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SizedBox(height: 16),
                Icon(
                  Icons.luggage_outlined,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  'Baggage Management',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 6),
                Text(
                  'Sign in to start scanning.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        if (_inlineError != null) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _isOfflineError
                                  ? Theme.of(context).colorScheme.tertiaryContainer
                                  : Theme.of(context).colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Icon(
                                    _isOfflineError
                                        ? Icons.wifi_off_outlined
                                        : Icons.error_outline,
                                    color: _isOfflineError
                                        ? Theme.of(context).colorScheme.onTertiaryContainer
                                        : Theme.of(context).colorScheme.onErrorContainer,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _inlineError!,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: _isOfflineError
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .onTertiaryContainer
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .onErrorContainer,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.username],
                          onChanged: (_) {
                            if (_inlineError != null || _invalidCredentials) {
                              setState(() {
                                _inlineError = null;
                                _isOfflineError = false;
                                _invalidCredentials = false;
                              });
                            }
                          },
                          decoration: InputDecoration(
                            labelText: 'Phone',
                            hintText: '+1 555 123 4567',
                            prefixIcon: const Icon(Icons.phone_outlined),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscure,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _submit(),
                          autofillHints: const [AutofillHints.password],
                          onChanged: (_) {
                            if (_inlineError != null || _invalidCredentials) {
                              setState(() {
                                _inlineError = null;
                                _isOfflineError = false;
                                _invalidCredentials = false;
                              });
                            }
                          },
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            errorText: _invalidCredentials
                                ? 'Check your phone/password'
                                : null,
                            suffixIcon: IconButton(
                              tooltip: _obscure ? 'Show password' : 'Hide password',
                              onPressed: () => setState(() => _obscure = !_obscure),
                              icon: Icon(
                                _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
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
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Offline-first: you can scan and queue actions when offline.\nWhen online, the app syncs automatically.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

