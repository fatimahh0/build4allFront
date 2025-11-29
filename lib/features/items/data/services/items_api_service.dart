// lib/features/items/data/services/items_api_service.dart

import 'package:build4front/core/config/env.dart';
import 'package:build4front/core/network/api_fetch.dart';
import 'package:build4front/core/network/api_methods.dart';
import 'package:build4front/core/exceptions/app_exception.dart';
import 'package:build4front/core/exceptions/network_exception.dart';

class ItemsApiService {
  final ApiFetch _fetch;

  // base path relative to Env.apiBaseUrl
  static const String _base = '/api/items';

  ItemsApiService({ApiFetch? fetch}) : _fetch = fetch ?? ApiFetch();

  int _ownerId() => int.tryParse(Env.ownerProjectLinkId) ?? 0;

  // ---------- /api/items/guest/upcoming ----------
  Future<List<dynamic>> getUpcomingGuest({int? typeId}) async {
    final ownerId = _ownerId();

    final query = <String, dynamic>{
      'ownerProjectLinkId': ownerId,
      if (typeId != null) 'typeId': typeId,
    };

    try {
      final res = await _fetch.fetch(
        HttpMethod.get,
        '$_base/guest/upcoming',
        data: query,
      );

      final data = res.data;
      if (data is! List) {
        throw ServerException(
          'Invalid response format for upcoming items',
          statusCode: res.statusCode ?? 200,
        );
      }
      return data;
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to load upcoming items', original: e);
    }
  }

  // ---------- /api/items/by-type/{typeId}?ownerProjectLinkId=... ----------
  Future<List<dynamic>> getByType(int typeId) async {
    final ownerId = _ownerId();

    final query = <String, dynamic>{'ownerProjectLinkId': ownerId};

    try {
      final res = await _fetch.fetch(
        HttpMethod.get,
        '$_base/by-type/$typeId',
        data: query,
      );

      final data = res.data;
      if (data is! List) {
        throw ServerException(
          'Invalid response format for items by type',
          statusCode: res.statusCode ?? 200,
        );
      }
      return data;
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to load items by type', original: e);
    }
  }

  // ---------- /api/items/category-based/{userId}?ownerProjectLinkId=... ----------
  Future<List<dynamic>> getInterestBased({
    required int userId,
    required String token,
  }) async {
    final ownerId = _ownerId();

    final headers = <String, String>{
      'Authorization': token.startsWith('Bearer ') ? token : 'Bearer $token',
    };

    final query = <String, dynamic>{'ownerProjectLinkId': ownerId};

    try {
      final res = await _fetch.fetch(
        HttpMethod.get,
        '$_base/category-based/$userId',
        headers: headers,
        data: query,
      );

      final data = res.data;
      if (data is! List) {
        throw ServerException(
          'Invalid response format for interest-based items',
          statusCode: res.statusCode ?? 200,
        );
      }
      return data;
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to load interest-based items', original: e);
    }
  }
}
