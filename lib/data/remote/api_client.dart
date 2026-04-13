import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/config.dart';
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
  );
});

class ApiClient {
  ApiClient({
    required String baseUrl,
    required Tokens? Function() readTokens,
    required Future<void> Function(Tokens tokens) persistTokens,
    required Future<void> Function() clearTokens,
    required Future<Tokens> Function(String refreshToken) refresh,
  })  : _readTokens = readTokens,
        _persistTokens = persistTokens,
        _clearTokens = clearTokens,
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
          if (status != 401 || alreadyRetried) {
            handler.next(err);
            return;
          }

          final tokens = _readTokens();
          if (tokens == null || tokens.refreshToken.isEmpty) {
            handler.next(err);
            return;
          }

          try {
            final newTokens = await refresh(tokens.refreshToken);
            await _persistTokens(newTokens);

            final req = err.requestOptions;
            req.extra['retried'] = true;
            req.headers['Authorization'] = 'Bearer ${newTokens.accessToken}';

            final res = await dio.fetch(req);
            handler.resolve(res);
          } catch (_) {
            await _clearTokens();
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
}

