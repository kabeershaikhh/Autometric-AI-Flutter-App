
class ApiConfig {
  /// Base URL for AutoMetric AI FastAPI backend.
  /// Uses HTTPS for all platforms (Web + Android) — required for Play Store.
  static String get baseUrl {
    return 'https://autometric-api.duckdns.org';
  }
}
