import 'dart:convert';
import 'package:dio/dio.dart';

class RuntimeConfigService {
  final Dio dio;

  RuntimeConfigService(this.dio);

  Future<Map<String, dynamic>> fetchByLinkId({
    required String apiBaseUrl,
    required String linkId,
  }) async {
    final url = '$apiBaseUrl/api/public/runtime-config/by-link?linkId=$linkId';

    final resp = await dio.get(url);
    if (resp.statusCode != 200) {
      throw Exception('Runtime config failed: HTTP ${resp.statusCode}');
    }

    // Dio can return Map already; ensure it's Map<String,dynamic>
    final data = resp.data;
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);

    // Fallback if string
    if (data is String) {
      return jsonDecode(data) as Map<String, dynamic>;
    }

    throw Exception(
        'Unexpected runtime config response type: ${data.runtimeType}');
  }
}
