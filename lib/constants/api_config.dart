
import 'package:flutter/foundation.dart';

class ApiConfig {
  /// Base URL for AutoMetric AI FastAPI backend.
  ///
  /// Web: HTTPS through Caddy reverse proxy.
  /// Android: Existing EC2 HTTP endpoint.
  static String get baseUrl {
    if (kIsWeb) {
      return 'https://autometric-api.duckdns.org';
    } else {
      return 'http://3.89.159.124:8000';
    }
  }
}
