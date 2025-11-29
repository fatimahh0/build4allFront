// lib/features/items/data/services/item_type_api_service.dart

import 'package:build4front/core/network/api_fetch.dart';
import 'package:build4front/core/network/api_methods.dart' show HttpMethod;
import 'package:build4front/core/exceptions/network_exception.dart';
import 'package:build4front/core/exceptions/app_exception.dart';

class ItemTypeApiService {
  final ApiFetch _fetch;

  ItemTypeApiService({ApiFetch? fetch}) : _fetch = fetch ?? ApiFetch();

  static const String _base = '/api/item-types';

  // ---------- list by PROJECT ----------
  Future<List<Map<String, dynamic>>> getItemTypesByProject(
    int projectId,
  ) async {
    try {
      final r = await _fetch.fetch(
        HttpMethod.get,
        '$_base/by-project/$projectId',
      );
      return _asListOfMap(r.data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to load item types by project', original: e);
    }
  }

  // ---------- list by CATEGORY ----------
  Future<List<Map<String, dynamic>>> getItemTypesByCategory(
    int categoryId,
  ) async {
    try {
      final path = '$_base/by-category/$categoryId';
      final r = await _fetch.fetch(HttpMethod.get, path);
      return _asListOfMap(r.data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to load item types by category', original: e);
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
    // If backend returns wrong shape, treat as server error
    throw ServerException(
      'Invalid response format for item types',
      statusCode: 200,
    );
  }
}
