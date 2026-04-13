import 'package:dio/dio.dart';

/// Converts low-level exceptions into short operator-facing messages.
String userFacingAuthError(Object e) {
  if (e is DioException) {
    // Connection / DNS / server down.
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return 'Server not reachable. Check internet and backend status.';
    }
    if (e.type == DioExceptionType.receiveTimeout) {
      return 'Server timed out. Try again.';
    }

    final status = e.response?.statusCode;
    if (status == 401) return 'Incorrect phone or password.';
    if (status == 403) return 'Login not allowed.';
    if (status != null && status >= 500) {
      return 'Server error. Try again later.';
    }

    // Backend error payload: { error: "CODE" }
    final data = e.response?.data;
    if (data is Map && data['error'] is String) {
      final code = data['error'] as String;
      if (code == 'INVALID_CREDENTIALS') return 'Incorrect phone or password.';
      if (code == 'MISSING_REFRESH_TOKEN' || code == 'INVALID_REFRESH_TOKEN') {
        return 'Session expired. Please sign in again.';
      }
    }

    return 'Login failed. Please try again.';
  }

  return 'Login failed. Please try again.';
}

