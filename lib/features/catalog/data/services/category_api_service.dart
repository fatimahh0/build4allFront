// lib/features/catalog/data/services/category_api_service.dart

import 'package:build4front/core/network/api_fetch.dart';
import 'package:build4front/core/network/api_methods.dart' show HttpMethod;
import 'package:build4front/core/exceptions/app_exception.dart';
import 'package:build4front/core/exceptions/network_exception.dart';

class CategoryApiService {
  final ApiFetch _fetch;

  CategoryApiService({ApiFetch? fetch}) : _fetch = fetch ?? ApiFetch();

  static const String _base = '/api/admin/categories';

  /// GET /api/admin/categories/by-project/{projectId}
  Future<List<Map<String, dynamic>>> getCategoriesByProject(
    int projectId,
  ) async {
    try {
      final path = '$_base/by-project/$projectId';
      final r = await _fetch.fetch(HttpMethod.get, path);
      return _asListOfMap(r.data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to load categories by project', original: e);
    }
  }

  /// GET /api/admin/categories
  Future<List<Map<String, dynamic>>> getAllCategories() async {
    try {
      final r = await _fetch.fetch(HttpMethod.get, _base);
      return _asListOfMap(r.data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to load categories', original: e);
    }
  }

  /// POST /api/admin/categories  (create category)
  Future<Map<String, dynamic>> createCategory({
    required String name,
    required int projectId,
    required String authToken,
  }) async {
    try {
      final r = await _fetch.fetch(
        HttpMethod.post,
        _base,
        data: {'name': name, 'projectId': projectId},
        headers: {'Authorization': 'Bearer $authToken'},
      );
      return _asMap(r.data);
    } on AppException {
      // هنا الـ ServerException غالباً حيحمل message من backend:
      // ex: "Category already exists in this project: LAPTOPS"
      rethrow;
    } catch (e) {
      throw AppException('Failed to create category', original: e);
    }
  }

  // ---------- Helpers ----------
  List<Map<String, dynamic>> _asListOfMap(dynamic data) {
    if (data is List) {
      return data
          .cast<dynamic>()
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }
    if (data is Map && data['data'] is List) {
      final list = data['data'] as List;
      return list
          .cast<dynamic>()
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }

    throw ServerException(
      'Invalid response format for categories',
      statusCode: 200,
    );
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);

    throw ServerException(
      'Invalid response format for category',
      statusCode: 200,
    );
  }
}
