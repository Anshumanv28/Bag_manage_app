import 'dart:convert';
import 'dart:developer' as dev;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class DebugNetworkLogger extends Interceptor {
  DebugNetworkLogger({required this.tag});

  final String tag;

  bool get _enabled => !kReleaseMode;

  String _safeJson(Object? value) {
    try {
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(value);
    } catch (_) {
      return value?.toString() ?? 'null';
    }
  }

  void _print(String message) {
    // `dev.log` doesn't always surface in `flutter run` output depending on IDE
    // tooling. We emit both.
    dev.log(message, name: tag);
    debugPrint('$tag $message');
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_enabled) {
      final headers = Map<String, dynamic>.from(options.headers);
      if (headers.containsKey('Authorization')) headers['Authorization'] = '***';
      options.extra['__startedAtMs'] = DateTime.now().millisecondsSinceEpoch;

      _print('[REQ] ${options.method} ${options.baseUrl}${options.path}');
      _print('      query=${_safeJson(options.queryParameters)}');
      _print('      headers=${_safeJson(headers)}');
      if (options.data != null) {
        _print('      body=${_safeJson(options.data)}');
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (_enabled) {
      final startedAtMs = response.requestOptions.extra['__startedAtMs'] as int?;
      final elapsedMs = startedAtMs == null
          ? null
          : DateTime.now().millisecondsSinceEpoch - startedAtMs;

      final elapsedSuffix = elapsedMs == null ? '' : ' (${elapsedMs}ms)';
      _print(
        '[RES] ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.baseUrl}${response.requestOptions.path}$elapsedSuffix',
      );
      if (response.data != null) {
        _print('      body=${_safeJson(response.data)}');
      }
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (_enabled) {
      final startedAtMs = err.requestOptions.extra['__startedAtMs'] as int?;
      final elapsedMs = startedAtMs == null
          ? null
          : DateTime.now().millisecondsSinceEpoch - startedAtMs;
      final elapsedSuffix = elapsedMs == null ? '' : ' (${elapsedMs}ms)';

      _print(
        '[ERR] ${err.response?.statusCode ?? '—'} ${err.requestOptions.method} ${err.requestOptions.baseUrl}${err.requestOptions.path}$elapsedSuffix',
      );
      _print('      type=${err.type} message=${err.message}');
      if (err.response?.data != null) {
        _print('      body=${_safeJson(err.response?.data)}');
      }
    }
    handler.next(err);
  }
}

