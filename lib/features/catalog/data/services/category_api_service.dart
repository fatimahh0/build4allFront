// lib/features/catalog/data/services/category_api_service.dart

import 'package:build4front/core/network/api_fetch.dart';
import 'package:build4front/core/network/api_methods.dart' show HttpMethod;
import 'package:build4front/core/exceptions/app_exception.dart';
import 'package:build4front/core/exceptions/network_exception.dart';

class CategoryApiService {
  final ApiFetch _fetch;

  CategoryApiService({ApiFetch? fetch}) : _fetch = fetch ?? ApiFetch();

  static const String _base = '/api/admin/categories';

  // ---------------- Helpers ----------------

  Map<String, String>? _authHeaders(String? token) {
    final t = token?.trim();
    if (t == null || t.isEmpty) return null;
    final normalized = t.startsWith('Bearer ') ? t : 'Bearer $t';
    return {'Authorization': normalized};
  }

  // ---------------- By PROJECT ----------------
  // ⚠️ Uses "projectId" (Project table). If you send ownerProjectId here you'll get:
  // "project not found: X"

  Future<List<Map<String, dynamic>>> getCategoriesByProject(
    int projectId, {
    String? authToken,
  }) async {
    try {
      final path = '$_base/by-project/$projectId';
      final r = await _fetch.fetch(
        HttpMethod.get,
        path,
        headers: _authHeaders(authToken),
      );
      return _asListOfMap(r.data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to load categories by project', original: e);
    }
  }

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
        headers: _authHeaders(authToken),
      );
      return _asMap(r.data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to create category', original: e);
    }
  }

  // ---------------- By OWNER PROJECT ----------------
  // ✅ Uses "ownerProjectId" (tenant / AUP / store). This matches your screen param:
  // widget.ownerProjectId

  Future<List<Map<String, dynamic>>> getCategoriesByOwnerProject(
    int ownerProjectId, {
    String? authToken,
  }) async {
    try {
      final path = '$_base/by-owner-project/$ownerProjectId';
      final r = await _fetch.fetch(
        HttpMethod.get,
        path,
        headers: _authHeaders(authToken),
      );
      return _asListOfMap(r.data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(
        'Failed to load categories by owner project',
        original: e,
      );
    }
  }

  Future<Map<String, dynamic>> createCategoryByOwnerProject({
    required int ownerProjectId,
    required String name,
    required String authToken,
  }) async {
    try {
      final path = '$_base/by-owner-project/$ownerProjectId';
      final r = await _fetch.fetch(
        HttpMethod.post,
        path,
        data: {'name': name},
        headers: _authHeaders(authToken),
      );
      return _asMap(r.data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException(
        'Failed to create category by owner project',
        original: e,
      );
    }
  }

  // ---------------- Other ----------------

  Future<List<Map<String, dynamic>>> getAllCategories({
    String? authToken,
  }) async {
    try {
      final r = await _fetch.fetch(
        HttpMethod.get,
        _base,
        headers: _authHeaders(authToken),
      );
      return _asListOfMap(r.data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to load categories', original: e);
    }
  }

  // ---------------- Parsing ----------------

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
