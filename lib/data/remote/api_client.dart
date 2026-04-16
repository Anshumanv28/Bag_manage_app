import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/config.dart';
import '../../features/auth/auth_controller.dart';
import '../../shared/models/operator.dart';
import 'auth_api.dart';
import 'network_logger.dart';
import 'tokens.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  final tokenStore = ref.read(tokenStoreProvider);
  final tokensCtrl = ref.read(tokensProvider.notifier);

  return ApiClient(
    baseUrl: AppConfig.baseUrl,
    readTokens: () => ref.read(tokensProvider),
    persistTokens: (t) async {
      tokensCtrl.setTokens(t);
      await tokenStore.save(t);
    },
    clearTokens: () async {
      tokensCtrl.clear();
      await tokenStore.clear();
    },
    refresh: (refreshToken) =>
        ref.read(authApiProvider).refresh(refreshToken: refreshToken),
    setOperator: (op) =>
        ref.read(authControllerProvider.notifier).updateOperator(op),
    logout: () => ref.read(authControllerProvider.notifier).logout(),
  );
});

class ApiClient {
  ApiClient({
    required String baseUrl,
    required Tokens? Function() readTokens,
    required Future<void> Function(Tokens tokens) persistTokens,
    required Future<void> Function() clearTokens,
    required Future<RefreshResponse> Function(String refreshToken) refresh,
    required void Function(Operator operator) setOperator,
    required Future<void> Function() logout,
  }) : _readTokens = readTokens,
       _persistTokens = persistTokens,
       _clearTokens = clearTokens,
       _setOperator = setOperator,
       _logout = logout,
       dio = Dio(
         BaseOptions(
           baseUrl: baseUrl,
           connectTimeout: const Duration(seconds: 10),
           receiveTimeout: const Duration(seconds: 20),
         ),
       ) {
    dio.interceptors.add(DebugNetworkLogger(tag: 'api'));

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final tokens = _readTokens();
          if (tokens != null && tokens.accessToken.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
          } else {
            options.headers.remove('Authorization');
          }
          handler.next(options);
        },
        onError: (err, handler) async {
          final status = err.response?.statusCode;
          final alreadyRetried = err.requestOptions.extra['retried'] == true;
          if (status != 401) {
            handler.next(err);
            return;
          }

          // Avoid refresh loops for auth endpoints.
          final path = err.requestOptions.path;
          final isAuthEndpoint = path.startsWith('/auth/');

          if (AppConfig.disableRefresh) {
            await _clearTokens();
            await _logout();
            handler.next(err);
            return;
          }

          // If we already retried once and still got 401, force logout.
          if (alreadyRetried) {
            await _clearTokens();
            await _logout();
            handler.next(err);
            return;
          }

          final tokens = _readTokens();
          if (tokens == null || tokens.refreshToken.isEmpty) {
            // No way to recover: clear and logout.
            await _clearTokens();
            await _logout();
            handler.next(err);
            return;
          }

          if (isAuthEndpoint) {
            // If auth endpoints themselves return 401, don't attempt refresh: logout.
            await _clearTokens();
            await _logout();
            handler.next(err);
            return;
          }

          try {
            final refreshRes = await refresh(tokens.refreshToken);
            final newTokens = Tokens(
              accessToken: refreshRes.accessToken,
              refreshToken: refreshRes.refreshToken,
            );
            await _persistTokens(newTokens);
            _setOperator(refreshRes.operator);

            final req = err.requestOptions;
            req.extra['retried'] = true;
            req.headers['Authorization'] = 'Bearer ${newTokens.accessToken}';

            final res = await dio.fetch(req);
            handler.resolve(res);
          } catch (_) {
            await _clearTokens();
            await _logout();
            handler.next(err);
          }
        },
      ),
    );
  }

  final Dio dio;
  final Tokens? Function() _readTokens;
  final Future<void> Function(Tokens tokens) _persistTokens;
  final Future<void> Function() _clearTokens;
  final void Function(Operator operator) _setOperator;
  final Future<void> Function() _logout;
}
