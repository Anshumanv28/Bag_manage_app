class AppConfig {
  // ---------------------------------------------------------------------------
  // Backend switching (debug + release)
  //
  // Flip the active backend by commenting/uncommenting ONE of the lines below.
  // ---------------------------------------------------------------------------
  static const String _activeBackendOrigin = 'http://3.109.235.112:3040';
  // static const String _activeBackendOrigin = 'http://localhost:3040';
  // static const String _activeBackendOrigin = 'http://192.168.1.45:3040';

  /// Backend origin (scheme + host + port), e.g. `http://localhost:3000`.
  ///
  /// Override at runtime via:
  /// - `flutter run --dart-define=BACKEND_ORIGIN=http://<host>:3040`
  /// - `flutter build apk --release --dart-define=BACKEND_ORIGIN=http://<host>:3040`
  static String get backendOrigin {
    const override = String.fromEnvironment('BACKEND_ORIGIN');
    if (override.isNotEmpty) return override;
    return _activeBackendOrigin;
  }

  /// API base URL used by app APIs.
  ///
  /// Override at runtime via:
  /// - `flutter run --dart-define=API_BASE_URL=http://<host>:3040/api/v1`
  /// - `flutter build apk --release --dart-define=API_BASE_URL=http://<host>:3040/api/v1`
  static String get apiBaseUrl {
    const override = String.fromEnvironment('API_BASE_URL');
    if (override.isNotEmpty) return override;
    return '${backendOrigin.replaceAll(RegExp(r'/+$'), '')}/api/v1';
  }

  /// Backwards-compat alias used across the app.
  static String get baseUrl => apiBaseUrl;

  /// Test hook: disable refresh-token retry flow.
  ///
  /// Run with:
  /// - `flutter run --dart-define=DISABLE_REFRESH=true`
  /// - `flutter build apk --release --dart-define=DISABLE_REFRESH=true`
  static bool get disableRefresh {
    const raw = String.fromEnvironment('DISABLE_REFRESH');
    return raw.toLowerCase() == 'true' || raw == '1';
  }

  /// Auto sync interval.
  ///
  /// Override at runtime via:
  /// - `flutter run --dart-define=AUTO_SYNC_SECONDS=5`
  /// - `flutter build apk --release --dart-define=AUTO_SYNC_SECONDS=5`
  ///
  /// Defaults to 5 seconds (same for debug + release).
  static Duration get autoSyncInterval {
    const raw = String.fromEnvironment('AUTO_SYNC_SECONDS');
    final v = int.tryParse(raw);
    if (v != null && v > 0 && v <= 3600) {
      return Duration(seconds: v);
    }
    return const Duration(seconds: 5);
  }
}
