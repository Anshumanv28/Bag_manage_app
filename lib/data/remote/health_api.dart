import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/config.dart';
import 'network_logger.dart';

final healthDioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.backendOrigin,
      connectTimeout: const Duration(seconds: 3),
      receiveTimeout: const Duration(seconds: 5),
      sendTimeout: const Duration(seconds: 5),
    ),
  );
  dio.interceptors.add(DebugNetworkLogger(tag: 'health'));
  return dio;
});

final healthApiProvider = Provider<HealthApi>((ref) {
  return HealthApi(ref.read(healthDioProvider));
});

class HealthApi {
  HealthApi(this._dio);

  final Dio _dio;

  Future<bool> isHealthy() async {
    final res = await _dio.get<Map<String, Object?>>('/health');
    final data = res.data ?? const <String, Object?>{};
    final ok = data['ok'];
    return res.statusCode == 200 && ok == true;
  }
}

