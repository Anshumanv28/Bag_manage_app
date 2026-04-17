import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';

final syncStatusApiProvider = Provider<SyncStatusApi>((ref) {
  final client = ref.read(apiClientProvider);
  return SyncStatusApi(client.dio);
});

class OperatorSyncStatusRow {
  const OperatorSyncStatusRow({
    required this.operatorId,
    required this.name,
    required this.lastSyncAt,
    required this.deviceId,
  });

  final String operatorId;
  final String name;
  final DateTime? lastSyncAt;
  final String? deviceId;

  factory OperatorSyncStatusRow.fromJson(Map<String, Object?> json) {
    final raw = json['lastSyncAt'] as String?;
    return OperatorSyncStatusRow(
      operatorId: (json['operatorId'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      lastSyncAt: raw == null ? null : DateTime.tryParse(raw),
      deviceId: json['deviceId'] as String?,
    );
  }
}

class OperatorSyncStatusResponse {
  const OperatorSyncStatusResponse({required this.rows});
  final List<OperatorSyncStatusRow> rows;
}

class SyncStatusApi {
  SyncStatusApi(this._dio);
  final Dio _dio;

  Future<OperatorSyncStatusResponse> latestByOperator() async {
    final res = await _dio.get<Map<String, Object?>>('/auth/operators/sync-latest');
    final data = res.data ?? const <String, Object?>{};
    final rows = (data['rows'] as List?)
            ?.whereType<Map>()
            .map((m) => OperatorSyncStatusRow.fromJson(m.cast<String, Object?>()))
            .toList() ??
        const <OperatorSyncStatusRow>[];
    return OperatorSyncStatusResponse(rows: rows);
  }
}

