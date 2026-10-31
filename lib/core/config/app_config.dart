import 'package:flutter/foundation.dart';

class AppConfig {
  AppConfig._();

  /// Configurable backend API base URL with safe platform-aware defaults.
  /// Can be overridden at build/run time via:
  /// `--dart-define=API_BASE_URL=https://api.yourdomain.com/api/v1`
  static String get apiBaseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;

    if (kIsWeb) {
      return 'http://localhost:4000/api/v1';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        // Use 127.0.0.1 which connects through ADB reverse tcp:4000 tcp:4000 over USB with zero latency
        return 'http://127.0.0.1:4000/api/v1';
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      default:
        return 'http://localhost:4000/api/v1';
    }
  }

  /// Explicit development-only authentication mode flag.
  /// Strictly prohibited in release builds: cannot be enabled in production.
  static bool get isDevAuthAllowed {
    if (kReleaseMode) return false;
    return const bool.fromEnvironment('ENABLE_DEV_AUTH', defaultValue: true);
  }

  /// Request timeout in seconds
  static const int requestTimeoutSeconds = 4;
}
