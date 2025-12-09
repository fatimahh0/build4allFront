import 'package:dio/dio.dart';
import 'package:build4front/core/network/api_client.dart';
import 'package:build4front/core/config/env.dart';

class TaxApiService {
  final Dio _dio;
  TaxApiService({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;

  String get _baseUrl => '${Env.apiBaseUrl}/api/tax';

  Options _auth(String token) =>
      Options(headers: {'Authorization': 'Bearer $token'});

  Future<List<dynamic>> listRules({
    required int ownerProjectId,
    required String authToken,
  }) async {
    final resp = await _dio.get(
      '$_baseUrl/rules',
      queryParameters: {'ownerProjectId': ownerProjectId},
      options: _auth(authToken),
    );
    return resp.data as List<dynamic>;
  }

  Future<Map<String, dynamic>> getRule({
    required int id,
    required String authToken,
  }) async {
    final resp = await _dio.get(
      '$_baseUrl/rules/$id',
      options: _auth(authToken),
    );
    return (resp.data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> createRule({
    required Map<String, dynamic> body,
    required String authToken,
  }) async {
    final resp = await _dio.post(
      '$_baseUrl/rules',
      data: body,
      options: _auth(authToken),
    );
    return (resp.data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> updateRule({
    required int id,
    required Map<String, dynamic> body,
    required String authToken,
  }) async {
    final resp = await _dio.put(
      '$_baseUrl/rules/$id',
      data: body,
      options: _auth(authToken),
    );
    return (resp.data as Map).cast<String, dynamic>();
  }

  Future<void> deleteRule({required int id, required String authToken}) async {
    await _dio.delete('$_baseUrl/rules/$id', options: _auth(authToken));
  }
}
