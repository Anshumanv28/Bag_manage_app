import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/remote/auth_api.dart';
import '../../data/remote/tokens.dart';
import '../../shared/models/operator.dart';

class AuthSession {
  const AuthSession({required this.operator});
  final Operator operator;
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, AuthSession?>(AuthController.new);

class AuthController extends AsyncNotifier<AuthSession?> {
  @override
  Future<AuthSession?> build() async {
    final tokenStore = ref.read(tokenStoreProvider);
    final tokens = await tokenStore.read();
    if (tokens == null) return null;

    ref.read(tokensProvider.notifier).setTokens(tokens);

    try {
      final me = await ref.read(authApiProvider).me(accessToken: tokens.accessToken);
      return AuthSession(operator: me);
    } catch (_) {
      await tokenStore.clear();
      ref.read(tokensProvider.notifier).clear();
      return null;
    }
  }

  Future<void> login({required String phone, required String password}) async {
    final authApi = ref.read(authApiProvider);
    final tokenStore = ref.read(tokenStoreProvider);

    try {
      final res = await authApi.login(phone: phone, password: password);
      final tokens =
          Tokens(accessToken: res.accessToken, refreshToken: res.refreshToken);
      await tokenStore.save(tokens);
      ref.read(tokensProvider.notifier).setTokens(tokens);

      state = AsyncData(AuthSession(operator: res.operator));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    final authApi = ref.read(authApiProvider);
    final tokenStore = ref.read(tokenStoreProvider);
    final tokens = ref.read(tokensProvider);

    try {
      if (tokens != null) {
        await authApi.logout(refreshToken: tokens.refreshToken);
      }
    } catch (_) {}

    await tokenStore.clear();
    ref.read(tokensProvider.notifier).clear();
    state = const AsyncData(null);
  }
}

