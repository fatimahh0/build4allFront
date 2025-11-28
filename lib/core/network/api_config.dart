import 'package:build4front/core/config/env.dart';

/// Reads base URL from Env.apiBaseUrl.
/// Example: "http://192.168.1.5:8080"
class ApiConfig {
  final String baseUrl; // e.g. http://192.168.1.5:8080
  final String serverRoot; // same as baseUrl here (kept for compatibility)

  ApiConfig._(this.baseUrl, this.serverRoot);

  static Future<ApiConfig> load() async {
    var raw = Env.apiBaseUrl.trim();
    if (raw.isEmpty) {
      throw Exception(
        'Env.apiBaseUrl is empty. Check your dart-define API_BASE_URL.',
      );
    }

    // remove trailing slashes
    raw = raw.replaceAll(RegExp(r'/+$'), '');

    // root here is the same (we are not forcing /api in front)
    final root = raw;

    return ApiConfig._(raw, root);
  }
}
