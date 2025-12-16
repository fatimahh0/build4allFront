import 'dart:convert';

class JwtUtils {
  static bool isExpired(String token) {
    try {
      final payload = _decodePayload(token);
      final exp = payload['exp'];
      if (exp is! num) return false;
      final expiry = DateTime.fromMillisecondsSinceEpoch(exp.toInt() * 1000);
      return DateTime.now().isAfter(expiry);
    } catch (_) {
      return false;
    }
  }

  /// Extracts userId from common JWT payload keys.
  /// Works with many Spring Boot JWT styles:
  /// - { "id": 12 }
  /// - { "userId": 12 }
  /// - { "sub": "12" } or { "sub": "user:12" }
  static int? userIdFromToken(String token) {
    try {
      final payload = _decodePayload(token);

      final dynamic id = payload['id'] ?? payload['userId'];
      if (id is num) return id.toInt();
      if (id is String) return int.tryParse(id);

      final sub = payload['sub'];
      if (sub is num) return sub.toInt();
      if (sub is String) {
        // try plain number first
        final n = int.tryParse(sub);
        if (n != null) return n;

        // try formats like "user:12"
        final match = RegExp(r'(\d+)').firstMatch(sub);
        if (match != null) return int.tryParse(match.group(1)!);
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  static Map<String, dynamic> _decodePayload(String token) {
    final parts = token.split('.');
    if (parts.length < 2) return {};

    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final decoded = utf8.decode(base64Url.decode(normalized));
    final jsonMap = jsonDecode(decoded);

    if (jsonMap is Map<String, dynamic>) return jsonMap;
    return {};
  }
}
