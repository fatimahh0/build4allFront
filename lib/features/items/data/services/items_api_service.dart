import 'package:build4front/core/config/env.dart';
import 'package:build4front/core/network/api_fetch.dart';
import 'package:build4front/core/network/api_methods.dart';
import 'package:build4front/core/exceptions/app_exception.dart';
import 'package:build4front/core/exceptions/network_exception.dart';

/// Service responsible for talking to backend "items" API.
///
/// It is multi-mode:
/// - Activities mode:
///   base = /api/items
/// - E-commerce/products mode:
///   base = /api/products
///
/// The same methods are reused by the repository and use cases.
class ItemsApiService {
  final ApiFetch _fetch;

  ItemsApiService({ApiFetch? fetch}) : _fetch = fetch ?? ApiFetch();

  int _ownerId() => int.tryParse(Env.ownerProjectLinkId) ?? 0;

  String get _appType => (Env.appType ?? '').toUpperCase().trim();

  bool get _isEcommerce => _appType == 'ECOMMERCE' || _appType == 'PRODUCTS';

  /// Base path:
  /// - Activities => /api/items
  /// - E-commerce  => /api/products
  String get _base => _isEcommerce ? '/api/products' : '/api/items';

  // ---------------------------------------------------------------------------
  //  getUpcomingGuest
  //
  //  Activities:
  //    GET /api/items/guest/upcoming?ownerProjectLinkId=...&typeId=...
  //
  //  Products:
  //    GET /api/products/new-arrivals?ownerProjectId=...&categoryId=...
  //
  //  We re-use this method in UI as "Upcoming / New items".
  // ---------------------------------------------------------------------------
  Future<List<dynamic>> getUpcomingGuest({int? typeId}) async {
    final ownerId = _ownerId();

    final query = <String, dynamic>{};
    String path;

    if (_isEcommerce) {
      // Products mode → use "new-arrivals"
      path = '$_base/new-arrivals';
      query['ownerProjectId'] = ownerId;

      // We use the typeId as a categoryId in e-commerce context.
      if (typeId != null) {
        query['categoryId'] = typeId;
      }
    } else {
      // Activities mode → use "guest/upcoming"
      path = '$_base/guest/upcoming';
      query['ownerProjectLinkId'] = ownerId;
      if (typeId != null) {
        query['typeId'] = typeId;
      }
    }

    try {
      final res = await _fetch.fetch(HttpMethod.get, path, data: query);

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

  // ---------------------------------------------------------------------------
  //  getByType
  //
  //  Activities:
  //    GET /api/items/by-type/{typeId}?ownerProjectLinkId=...
  //
  //  Products:
  //    GET /api/products?ownerProjectId=...&categoryId=typeId
  //
  //  In e-commerce, "typeId" is used as categoryId.
  // ---------------------------------------------------------------------------
  Future<List<dynamic>> getByType(int typeId) async {
    final ownerId = _ownerId();

    String path;
    final query = <String, dynamic>{};

    if (_isEcommerce) {
      // E-commerce: filter products by category
      path = _base;
      query['ownerProjectId'] = ownerId;
      query['categoryId'] = typeId;
    } else {
      // Activities: filter items by item type
      path = '$_base/by-type/$typeId';
      query['ownerProjectLinkId'] = ownerId;
    }

    try {
      final res = await _fetch.fetch(HttpMethod.get, path, data: query);

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

  // ---------------------------------------------------------------------------
  //  getInterestBased
  //
  //  Activities:
  //    GET /api/items/category-based/{userId}?ownerProjectLinkId=...
  //
  //  Products:
  //    For now we re-use "best-sellers" as a kind of "recommended":
  //    GET /api/products/best-sellers?ownerProjectId=...&limit=20
  //
  //  Token is required for activities; for products we still send it
  //  in case backend adds auth in the future.
  // ---------------------------------------------------------------------------
  Future<List<dynamic>> getInterestBased({
    required int userId,
    required String token,
  }) async {
    final ownerId = _ownerId();

    final headers = <String, String>{
      'Authorization': token.startsWith('Bearer ') ? token : 'Bearer $token',
    };

    String path;
    final query = <String, dynamic>{};

    if (_isEcommerce) {
      // E-commerce mode → "best-sellers" used as recommendation
      path = '$_base/best-sellers';
      query['ownerProjectId'] = ownerId;
      query['limit'] = 20;
    } else {
      // Activities mode → interest-based by user categories
      path = '$_base/category-based/$userId';
      query['ownerProjectLinkId'] = ownerId;
    }

    try {
      final res = await _fetch.fetch(
        HttpMethod.get,
        path,
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
