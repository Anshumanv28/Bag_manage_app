import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/config.dart';
import 'network_logger.dart';
import 'tokens.dart';

final syncApiProvider = Provider<SyncApi>((ref) {
  // Sync endpoints are hosted at backend origin (no `/api/v1` prefix).
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.backendOrigin,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );
  dio.interceptors.add(DebugNetworkLogger(tag: 'api'));
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final tokens = ref.read(tokensProvider);
        if (tokens != null && tokens.accessToken.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
        } else {
          options.headers.remove('Authorization');
        }
        handler.next(options);
      },
    ),
  );
  return SyncApi(dio);
});

class SyncPullResponse {
  const SyncPullResponse({required this.nextCursor, required this.changes});
  final String? nextCursor;
  final List<Map<String, Object?>> changes;
}

class SyncPushResponse {
  const SyncPushResponse({required this.cursor, required this.results});
  final String? cursor;
  final List<Map<String, Object?>> results;
}

class SyncApi {
  SyncApi(this._dio);
  final Dio _dio;

  Future<SyncPullResponse> pull({String? cursor, int limit = 200}) async {
    final payload = <String, Object?>{
      'limit': limit,
      ...?switch (cursor) {
        final c? => <String, Object?>{'cursor': c},
        null => null,
      },
    };

    final res = await _dio.post<Map<String, Object?>>(
      '/sync/pull',
      data: payload,
    );
    final data = res.data ?? const <String, Object?>{};
    final changes = (data['changes'] as List?)
            ?.whereType<Map>()
            .map((m) => m.cast<String, Object?>())
            .toList() ??
        const <Map<String, Object?>>[];
    return SyncPullResponse(
      nextCursor: data['nextCursor'] as String?,
      changes: changes,
    );
  }

  Future<SyncPushResponse> push({
    required String deviceId,
    required List<Map<String, Object?>> mutations,
  }) async {
    final res = await _dio.post<Map<String, Object?>>(
      '/sync/push',
      data: {'deviceId': deviceId, 'mutations': mutations},
    );
    final data = res.data ?? const <String, Object?>{};
    final results = (data['results'] as List?)
            ?.whereType<Map>()
            .map((m) => m.cast<String, Object?>())
            .toList() ??
        const <Map<String, Object?>>[];
    return SyncPushResponse(
      cursor: data['cursor'] as String?,
      results: results,
    );
  }
}

