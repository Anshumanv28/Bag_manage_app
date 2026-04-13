import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/config.dart';
import '../../shared/models/operator.dart';
import 'network_logger.dart';
import 'tokens.dart';

final authDioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );
  dio.interceptors.add(DebugNetworkLogger(tag: 'auth'));
  return dio;
});

final authApiProvider = Provider<AuthApi>((ref) {
  return AuthApi(ref.read(authDioProvider));
});

class LoginResponse {
  const LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.operator,
  });

  final String accessToken;
  final String refreshToken;
  final Operator operator;
}

class AuthApi {
  AuthApi(this._dio);

  final Dio _dio;

  Future<LoginResponse> login({
    required String phone,
    required String password,
  }) async {
    final res = await _dio.post<Map<String, Object?>>(
      '/auth/login',
      data: {'phone': phone, 'password': password},
    );

    final data = res.data ?? const <String, Object?>{};
    return LoginResponse(
      accessToken: (data['accessToken'] as String?) ?? '',
      refreshToken: (data['refreshToken'] as String?) ?? '',
      operator: Operator.fromJson(
        (data['operator'] as Map?)?.cast<String, Object?>() ?? const {},
      ),
    );
  }

  /// Postman/backend expect refresh token in Authorization header.
  Future<Tokens> refresh({required String refreshToken}) async {
    final res = await _dio.post<Map<String, Object?>>(
      '/auth/refresh',
      options: Options(headers: {'Authorization': 'Bearer $refreshToken'}),
    );
    final data = res.data ?? const <String, Object?>{};
    return Tokens(
      accessToken: (data['accessToken'] as String?) ?? '',
      refreshToken: (data['refreshToken'] as String?) ?? '',
    );
  }

  /// Postman/backend expect refresh token in Authorization header. Returns 204.
  Future<void> logout({required String refreshToken}) async {
    await _dio.post<void>(
      '/auth/logout',
      options: Options(headers: {'Authorization': 'Bearer $refreshToken'}),
    );
  }

  /// Backend returns `{ operator: { phone, name } }`.
  Future<Operator> me({required String accessToken}) async {
    final res = await _dio.get<Map<String, Object?>>(
      '/auth/me',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    final data = res.data ?? const <String, Object?>{};
    return Operator.fromJson(
      (data['operator'] as Map?)?.cast<String, Object?>() ?? const {},
    );
  }
}

