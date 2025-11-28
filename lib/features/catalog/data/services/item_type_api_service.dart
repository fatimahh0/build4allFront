import 'dart:io';

import 'package:build4front/core/network/api_fetch.dart';
import 'package:build4front/core/network/api_methods.dart' show HttpMethod;

class ItemTypeApiService {
  final ApiFetch _fetch;

  ItemTypeApiService({ApiFetch? fetch}) : _fetch = fetch ?? ApiFetch();

  static const String _base = '/api/item-types';

  // ---------- list by PROJECT ----------
  Future<List<Map<String, dynamic>>> getItemTypesByProject(
    int projectId,
  ) async {
    final r = await _fetch.fetch(
      HttpMethod.get,
      '$_base/by-project/$projectId',
    );

    return (r.data as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  // ---------- list by CATEGORY ----------
  Future<List<Map<String, dynamic>>> getItemTypesByCategory(
    int categoryId,
  ) async {
    final path = '$_base/by-category/$categoryId';
    final r = await _fetch.fetch(HttpMethod.get, path);
    _ok(r.statusCode, r.statusMessage);
    return _asListOfMap(r.data);
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
    return const <Map<String, dynamic>>[];
  }

  void _ok(int? code, String? msg) {
    if (code == null || code < 200 || code >= 300) {
      throw HttpException('Request failed: $code $msg');
    }
  }
}
