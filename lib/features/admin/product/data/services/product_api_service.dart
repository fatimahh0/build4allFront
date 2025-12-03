import 'package:dio/dio.dart';
import 'package:build4front/core/network/api_client.dart';
import 'package:build4front/core/config/env.dart';

class ProductApiService {
  final Dio _dio;

  ProductApiService({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;

  String get _baseUrl => '${Env.apiBaseUrl}/api/products';

  /// 🔹 ADMIN OWNER: list products for current app
  /// GET /api/products/owner/app-products?ownerProjectId=...
  Future<List<dynamic>> getProducts({
    required int ownerProjectId,
    int? itemTypeId,
    int? categoryId,
    required String authToken,
  }) async {
    final resp = await _dio.get(
      '$_baseUrl',
      queryParameters: {
        'ownerProjectId': ownerProjectId,
        // if (itemTypeId != null) 'itemTypeId': itemTypeId,
        // if (categoryId != null) 'categoryId': categoryId,
      },
      options: Options(headers: {'Authorization': 'Bearer $authToken'}),
    );
    return resp.data as List<dynamic>;
  }

  /// 🔹 New arrivals (public/user)
  Future<List<dynamic>> getNewArrivals({
    required int ownerProjectId,
    int? days,
    required String authToken,
  }) async {
    final resp = await _dio.get(
      '$_baseUrl/new-arrivals',
      queryParameters: {
        'ownerProjectId': ownerProjectId,
        if (days != null) 'days': days,
      },
      options: Options(headers: {'Authorization': 'Bearer $authToken'}),
    );
    return resp.data as List<dynamic>;
  }

  /// 🔹 Best sellers
  Future<List<dynamic>> getBestSellers({
    required int ownerProjectId,
    int? limit,
    required String authToken,
  }) async {
    final resp = await _dio.get(
      '$_baseUrl/best-sellers',
      queryParameters: {
        'ownerProjectId': ownerProjectId,
        if (limit != null) 'limit': limit,
      },
      options: Options(headers: {'Authorization': 'Bearer $authToken'}),
    );
    return resp.data as List<dynamic>;
  }

  /// 🔹 Discounted products
  Future<List<dynamic>> getDiscounted({
    required int ownerProjectId,
    required String authToken,
  }) async {
    final resp = await _dio.get(
      '$_baseUrl/discounted',
      queryParameters: {'ownerProjectId': ownerProjectId},
      options: Options(headers: {'Authorization': 'Bearer $authToken'}),
    );
    return resp.data as List<dynamic>;
  }

  /// 🔹 Get one
  Future<Map<String, dynamic>> getById({
    required int id,
    required String authToken,
  }) async {
    final resp = await _dio.get(
      '$_baseUrl/$id',
      options: Options(headers: {'Authorization': 'Bearer $authToken'}),
    );
    return resp.data as Map<String, dynamic>;
  }

  /// 🔹 Create product
  Future<Map<String, dynamic>> create({
    required Map<String, dynamic> body,
    required String authToken,
  }) async {
    final resp = await _dio.post(
      _baseUrl,
      data: body,
      options: Options(headers: {'Authorization': 'Bearer $authToken'}),
    );
    return resp.data as Map<String, dynamic>;
  }

  /// 🔹 Update product
  Future<Map<String, dynamic>> update({
    required int id,
    required Map<String, dynamic> body,
    required String authToken,
  }) async {
    final resp = await _dio.put(
      '$_baseUrl/$id',
      data: body,
      options: Options(headers: {'Authorization': 'Bearer $authToken'}),
    );
    return resp.data as Map<String, dynamic>;
  }

  /// 🔹 Delete product
  Future<void> delete({required int id, required String authToken}) async {
    await _dio.delete(
      '$_baseUrl/$id',
      options: Options(headers: {'Authorization': 'Bearer $authToken'}),
    );
  }
}
