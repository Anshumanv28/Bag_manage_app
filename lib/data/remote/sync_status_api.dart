import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';

DateTime? _parseBackendUtc(String? raw) {
  if (raw == null) return null;
  final t = raw.trim();
  if (t.isEmpty) return null;

  final hasZone = RegExp(r'(Z|z|[+-]\d{2}(:?\d{2})?|[+-]\d{4})$').hasMatch(t);
  if (hasZone) return DateTime.tryParse(t);

  // Backend sometimes returns `::text` timestamps without zone (e.g. "2026-04-17 06:13:05.642").
  // Treat these naive timestamps as UTC to avoid showing "5h ago" in IST.
  final normalized = t.contains(' ') ? t.replaceFirst(' ', 'T') : t;
  return DateTime.tryParse('${normalized}Z');
}

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
      lastSyncAt: _parseBackendUtc(raw),
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
    final res = await _dio.get<Map<String, Object?>>(
      '/auth/operators/sync-latest',
    );
    final data = res.data ?? const <String, Object?>{};
    final rows =
        (data['rows'] as List?)
            ?.whereType<Map>()
            .map(
              (m) => OperatorSyncStatusRow.fromJson(m.cast<String, Object?>()),
            )
            .toList() ??
        const <OperatorSyncStatusRow>[];
    return OperatorSyncStatusResponse(rows: rows);
  }
}
