import 'package:dio/dio.dart';
import 'package:build4front/core/network/api_client.dart';
import 'package:build4front/core/config/env.dart';

class ShippingApiService {
  final Dio _dio;
  ShippingApiService({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;

  String get _baseUrl => '${Env.apiBaseUrl}/api/shipping';

  Options _auth(String token) =>
      Options(headers: {'Authorization': 'Bearer $token'});

  // ✅ OWNER/SUPER_ADMIN: derived from token (no ownerProjectId)
  Future<List<dynamic>> listMethods({
    required String authToken,
  }) async {
    final resp = await _dio.get(
      '$_baseUrl/methods',
      options: _auth(authToken),
    );
    return resp.data as List<dynamic>;
  }

  // ✅ OWNER/SUPER_ADMIN: derived from token
  Future<Map<String, dynamic>> getMethod({
    required int id,
    required String authToken,
  }) async {
    final resp = await _dio.get(
      '$_baseUrl/methods/$id',
      options: _auth(authToken),
    );
    return (resp.data as Map).cast<String, dynamic>();
  }

  // ✅ OWNER/SUPER_ADMIN: do NOT send ownerProjectId in body
  Future<Map<String, dynamic>> createMethod({
    required Map<String, dynamic> body,
    required String authToken,
  }) async {
    final sanitized = Map<String, dynamic>.from(body)..remove('ownerProjectId');

    final resp = await _dio.post(
      '$_baseUrl/methods',
      data: sanitized,
      options: _auth(authToken),
    );
    return (resp.data as Map).cast<String, dynamic>();
  }

  // ✅ OWNER/SUPER_ADMIN: do NOT send ownerProjectId in body
  Future<Map<String, dynamic>> updateMethod({
    required int id,
    required Map<String, dynamic> body,
    required String authToken,
  }) async {
    final sanitized = Map<String, dynamic>.from(body)..remove('ownerProjectId');

    final resp = await _dio.put(
      '$_baseUrl/methods/$id',
      data: sanitized,
      options: _auth(authToken),
    );
    return (resp.data as Map).cast<String, dynamic>();
  }

  // ✅ OWNER/SUPER_ADMIN: derived from token
  Future<void> deleteMethod({
    required int id,
    required String authToken,
  }) async {
    await _dio.delete(
      '$_baseUrl/methods/$id',
      options: _auth(authToken),
    );
  }

  // ✅ PUBLIC list still needs ownerProjectId (app context)
  Future<List<dynamic>> listPublicMethods({
    required int ownerProjectId,
    required String authToken,
  }) async {
    final resp = await _dio.get(
      '$_baseUrl/methods/public',
      queryParameters: {'ownerProjectId': ownerProjectId},
      options: _auth(authToken),
    );
    return resp.data as List<dynamic>;
  }
}
