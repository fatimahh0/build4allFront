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

  // ---------------- NEW (Tenant-safe) ----------------
  // Backend now derives tenant (ownerProjectId) from JWT.

  /// ✅ List categories for current tenant
  Future<List<Map<String, dynamic>>> getCategoriesForTenant({
    required String authToken,
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

  /// ✅ List categories for a project (tenant-verified in backend)
  /// If projectId doesn't belong to tenant => backend returns 404.
  Future<List<Map<String, dynamic>>> getCategoriesByProject(
    int projectId, {
    required String authToken,
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

  /// ✅ Get one category (tenant-safe)
  Future<Map<String, dynamic>> getCategory(
    int categoryId, {
    required String authToken,
  }) async {
    try {
      final path = '$_base/$categoryId';
      final r = await _fetch.fetch(
        HttpMethod.get,
        path,
        headers: _authHeaders(authToken),
      );
      return _asMap(r.data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to load category', original: e);
    }
  }

  /// ✅ Create category (tenant-safe)
  /// Backend uses token tenant to resolve projectRef.
  Future<Map<String, dynamic>> createCategory({
    required String name,
    String? iconName,
    String? iconLibrary,
    bool ensureIconExists = true,
    required String authToken,
  }) async {
    try {
      final path = '$_base?ensureIconExists=${Uri.encodeQueryComponent(ensureIconExists.toString())}';

      final data = <String, dynamic>{
        'name': name,
      };

      if (iconName != null) data['iconName'] = iconName;
      if (iconLibrary != null) data['iconLibrary'] = iconLibrary;

      final r = await _fetch.fetch(
        HttpMethod.post,
        path,
        data: data,
        headers: _authHeaders(authToken),
      );

      return _asMap(r.data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to create category', original: e);
    }
  }

  /// ✅ Update category (tenant-safe)
  Future<Map<String, dynamic>> updateCategory(
    int categoryId, {
    String? name,
    String? iconName,
    String? iconLibrary,
    bool ensureIconExists = true,
    required String authToken,
  }) async {
    try {
      final path = '$_base/$categoryId?ensureIconExists=${Uri.encodeQueryComponent(ensureIconExists.toString())}';

      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (iconName != null) data['iconName'] = iconName;
      if (iconLibrary != null) data['iconLibrary'] = iconLibrary;

      final r = await _fetch.fetch(
        HttpMethod.put,
        path,
        data: data,
        headers: _authHeaders(authToken),
      );

      return _asMap(r.data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to update category', original: e);
    }
  }

  /// ✅ Delete category (tenant-safe)
  /// NO ownerProjectId query param anymore.
  Future<void> deleteCategory(
    int categoryId, {
    required String authToken,
  }) async {
    try {
      final path = '$_base/$categoryId';

      await _fetch.fetch(
        HttpMethod.delete,
        path,
        headers: _authHeaders(authToken),
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to delete category', original: e);
    }
  }

  // ---------------- LEGACY (Optional during migration) ----------------
  // If your UI still calls these endpoints, you can keep them.
  // Backend now verifies ownerProjectId matches token tenant, so spoofing won’t work.

  Future<List<Map<String, dynamic>>> getCategoriesByOwnerProjectLegacy(
    int ownerProjectId, {
    required String authToken,
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
      throw AppException('Failed to load categories by owner project', original: e);
    }
  }

  Future<Map<String, dynamic>> createCategoryByOwnerProjectLegacy({
    required int ownerProjectId,
    required String name,
    String? iconName,
    String? iconLibrary,
    bool ensureIconExists = true,
    required String authToken,
  }) async {
    try {
      final path = '$_base/by-owner-project/$ownerProjectId'
          '?ensureIconExists=${Uri.encodeQueryComponent(ensureIconExists.toString())}';

      final data = <String, dynamic>{'name': name};
      if (iconName != null) data['iconName'] = iconName;
      if (iconLibrary != null) data['iconLibrary'] = iconLibrary;

      final r = await _fetch.fetch(
        HttpMethod.post,
        path,
        data: data,
        headers: _authHeaders(authToken),
      );

      return _asMap(r.data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to create category by owner project', original: e);
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
