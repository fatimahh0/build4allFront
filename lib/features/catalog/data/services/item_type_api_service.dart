// lib/features/catalog/data/services/item_type_api_service.dart

import 'package:build4front/core/network/api_fetch.dart';
import 'package:build4front/core/network/api_methods.dart' show HttpMethod;
import 'package:build4front/core/exceptions/network_exception.dart';
import 'package:build4front/core/exceptions/app_exception.dart';

class ItemTypeApiService {
  final ApiFetch _fetch;

  ItemTypeApiService({ApiFetch? fetch}) : _fetch = fetch ?? ApiFetch();

  static const String _base = '/api/item-types';

  Future<List<Map<String, dynamic>>> getItemTypesByProject(
    int projectId, {
    String? authToken,
  }) async {
    try {
      final r = await _fetch.fetch(
        HttpMethod.get,
        '$_base/by-project/$projectId',
        headers: authToken != null && authToken.isNotEmpty
            ? {'Authorization': 'Bearer $authToken'}
            : null,
      );
      return _asListOfMap(r.data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to load item types by project', original: e);
    }
  }

  Future<List<Map<String, dynamic>>> getItemTypesByCategory(
    int categoryId, {
    String? authToken,
  }) async {
    try {
      final r = await _fetch.fetch(
        HttpMethod.get,
        '$_base/by-category/$categoryId',
        headers: authToken != null && authToken.isNotEmpty
            ? {'Authorization': 'Bearer $authToken'}
            : null,
      );
      return _asListOfMap(r.data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to load item types by category', original: e);
    }
  }

  Future<Map<String, dynamic>> createItemType({
    required String name,
    required int categoryId,
    required String authToken,
  }) async {
    try {
      final r = await _fetch.fetch(
        HttpMethod.post,
        _base,
        headers: {'Authorization': 'Bearer $authToken'},
        data: {'name': name, 'categoryId': categoryId},
      );
      return _asMap(r.data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to create item type', original: e);
    }
  }

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
      'Invalid response format for item types',
      statusCode: 200,
    );
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);

    throw ServerException(
      'Invalid response format for item type',
      statusCode: 200,
    );
  }
}
