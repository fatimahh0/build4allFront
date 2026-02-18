import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:build4front/core/config/env.dart';

class AdminUserApiService {
  final Future<String?> Function() getToken;
  AdminUserApiService({required this.getToken});

  String get _base => Env.apiBaseUrl;

  Future<Map<String, dynamic>> getMyProfileJson() async {
    final token = (await getToken())?.trim() ?? '';
    if (token.isEmpty) {
      throw Exception('Missing token');
    }

    final auth = token.startsWith('Bearer ') ? token : 'Bearer $token';
    final uri = Uri.parse('$_base/api/admin/users/me');

    final res = await http.get(
      uri,
      headers: {
        'Authorization': auth,
        'Accept': 'application/json',
      },
    );

    if (res.statusCode >= 200 && res.statusCode < 300) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }

    // backend usually returns {message, error}
    try {
      final map = jsonDecode(res.body) as Map<String, dynamic>;
      final msg = (map['message'] ?? map['error'] ?? 'Request failed').toString();
      throw Exception(msg);
    } catch (_) {
      throw Exception('Request failed (${res.statusCode})');
    }
  }
}
