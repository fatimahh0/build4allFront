import 'package:dio/dio.dart';
import 'package:build4front/core/network/api_client.dart';
import 'package:build4front/core/config/env.dart';

class ShippingApiService {
  final Dio _dio;
  ShippingApiService({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;

  String get _baseUrl => '${Env.apiBaseUrl}/api/shipping';

  Options _auth(String token) =>
      Options(headers: {'Authorization': 'Bearer $token'});

  Future<List<dynamic>> listMethods({
    required int ownerProjectId,
    required String authToken,
  }) async {
    final resp = await _dio.get(
      '$_baseUrl/methods',
      queryParameters: {'ownerProjectId': ownerProjectId},
      options: _auth(authToken),
    );
    return resp.data as List<dynamic>;
  }

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

  Future<Map<String, dynamic>> createMethod({
    required Map<String, dynamic> body,
    required String authToken,
  }) async {
    final resp = await _dio.post(
      '$_baseUrl/methods',
      data: body,
      options: _auth(authToken),
    );
    return (resp.data as Map).cast<String, dynamic>();
  }

  Future<Map<String, dynamic>> updateMethod({
    required int id,
    required Map<String, dynamic> body,
    required String authToken,
  }) async {
    final resp = await _dio.put(
      '$_baseUrl/methods/$id',
      data: body,
      options: _auth(authToken),
    );
    return (resp.data as Map).cast<String, dynamic>();
  }

  Future<void> deleteMethod({
    required int id,
    required String authToken,
  }) async {
    await _dio.delete('$_baseUrl/methods/$id', options: _auth(authToken));
  }
}
