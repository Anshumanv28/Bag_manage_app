import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kReleaseMode;

class AppConfig {
  // Your dev machine Wi‑Fi IP (so physical devices can reach it).
  static const String _devHostIp = '172.31.174.125';

  /// Deployed API (release builds default here unless overridden).
  static const String _productionBackendOrigin = 'http://3.109.235.112:3040';

  /// Backend origin (scheme + host + port), e.g. `http://localhost:3000`.
  ///
  /// Override at runtime via:
  /// - `flutter run --dart-define=BACKEND_ORIGIN=http://<host>:3040`
  static String get backendOrigin {
    const override = String.fromEnvironment('BACKEND_ORIGIN');
    if (override.isNotEmpty) return override;

    if (kReleaseMode) return _productionBackendOrigin;

    // Android emulator: host machine is reachable at 10.0.2.2
    // Physical Android devices: use the dev machine LAN/Wi‑Fi IP.
    if (Platform.isAndroid) return 'http://$_devHostIp:3040';
    return 'http://localhost:3040';
  }

  /// API base URL used by app APIs.
  ///
  /// Override at runtime via:
  /// - `flutter run --dart-define=API_BASE_URL=http://<host>:3040/api/v1`
  static String get apiBaseUrl {
    const override = String.fromEnvironment('API_BASE_URL');
    if (override.isNotEmpty) return override;
    return '${backendOrigin.replaceAll(RegExp(r'/+$'), '')}/api/v1';
  }

  /// Backwards-compat alias used across the app.
  static String get baseUrl => apiBaseUrl;
}
