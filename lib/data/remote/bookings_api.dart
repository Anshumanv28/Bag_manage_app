import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';

final bookingsApiProvider = Provider<BookingsApi>((ref) {
  final client = ref.read(apiClientProvider);
  return BookingsApi(client.dio);
});

class BookingIdsResponse {
  const BookingIdsResponse({required this.ids, required this.nextCursor});
  final List<String> ids;
  final String? nextCursor;
}

class BookingsApi {
  BookingsApi(this._dio);
  final Dio _dio;

  Future<BookingIdsResponse> listIds({
    DateTime? updatedSince,
    int limit = 1000,
    String? cursor,
  }) async {
    final res = await _dio.get<Map<String, Object?>>(
      '/bookings/ids',
      queryParameters: <String, Object?>{
        if (updatedSince != null) 'updatedSince': updatedSince.toUtc().toIso8601String(),
        'limit': limit,
        if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
      },
    );
    final data = res.data ?? const <String, Object?>{};
    final ids = (data['ids'] as List?)?.whereType<String>().toList() ?? const <String>[];
    return BookingIdsResponse(
      ids: ids,
      nextCursor: data['nextCursor'] as String?,
    );
  }
}

