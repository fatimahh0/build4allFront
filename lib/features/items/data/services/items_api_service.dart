import 'package:build4front/core/config/env.dart';
import 'package:build4front/core/network/api_fetch.dart';
import 'package:build4front/core/network/api_methods.dart';
import 'package:build4front/core/exceptions/app_exception.dart';
import 'package:build4front/core/exceptions/network_exception.dart';

class ItemsApiService {
  final ApiFetch _fetch;

  ItemsApiService({ApiFetch? fetch}) : _fetch = fetch ?? ApiFetch();

  int _ownerId() => int.tryParse(Env.ownerProjectLinkId) ?? 0;

  String get _appType => (Env.appType ?? '').toUpperCase().trim();
  bool get _isEcommerce => _appType == 'ECOMMERCE' || _appType == 'PRODUCTS';
  String get _base => _isEcommerce ? '/api/products' : '/api/items';

  Map<String, String>? _authHeaders(String? token) {
    final raw = token?.trim();
    if (raw == null || raw.isEmpty) return null;
    return {'Authorization': raw.startsWith('Bearer ') ? raw : 'Bearer $raw'};
  }

  void _requireTokenForEcommerce(String? token, String context) {
    if (!_isEcommerce) return;
    final raw = token?.trim();
    if (raw == null || raw.isEmpty) {
      throw AppException('Auth token is required for products ($context).');
    }
  }

  // ---------------------------------------------------------------------------
  // ✅ FIXED: getUpcomingGuest
  //
  // Activities:
  //   GET /api/items/guest/upcoming?ownerProjectLinkId=...&typeId=...
  //
  // E-commerce (FIX):
  //   ✅ GET /api/products?categoryId=...   (tenant from token)
  //
  // Why:
  //   Your /new-arrivals, /discounted, /best-sellers are returning [].
  //   So Home needs a reliable “main list” => /api/products.
  // ---------------------------------------------------------------------------
  Future<List<dynamic>> getUpcomingGuest({int? typeId, String? token}) async {
    final ownerId = _ownerId();
    final query = <String, dynamic>{};
    String path;

    if (_isEcommerce) {
      _requireTokenForEcommerce(token, 'getUpcomingGuest/products list');

      // ✅ Main list endpoint
      path = _base; // /api/products

      // backward compatibility only (backend may ignore)
      query['ownerProjectId'] = ownerId;

      // optional filter by category
      if (typeId != null) query['categoryId'] = typeId;
    } else {
      path = '$_base/guest/upcoming';
      query['ownerProjectLinkId'] = ownerId;
      if (typeId != null) query['typeId'] = typeId;
    }

    try {
      final res = await _fetch.fetch(
        HttpMethod.get,
        path,
        headers: _authHeaders(token),
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

  // ---------------------------------------------------------------------------
  // getByType
  //
  // Activities:
  //   GET /api/items/by-type/{typeId}?ownerProjectLinkId=...
  //
  // Products:
  //   GET /api/products?categoryId=... (tenant from token)
  // ---------------------------------------------------------------------------
  Future<List<dynamic>> getByType(int typeId, {String? token}) async {
    final ownerId = _ownerId();

    String path;
    final query = <String, dynamic>{};

    if (_isEcommerce) {
      _requireTokenForEcommerce(token, 'getByType/products');
      path = _base;
      query['ownerProjectId'] = ownerId; // may be ignored
      query['categoryId'] = typeId;
    } else {
      path = '$_base/by-type/$typeId';
      query['ownerProjectLinkId'] = ownerId;
    }

    try {
      final res = await _fetch.fetch(
        HttpMethod.get,
        path,
        headers: _authHeaders(token),
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

  Future<Map<String, dynamic>> getById(int id, {String? token}) async {
    final ownerId = _ownerId();
    final path = '$_base/$id';

    final query = <String, dynamic>{};
    if (_isEcommerce) {
      _requireTokenForEcommerce(token, 'getById/products');
    } else {
      query['ownerProjectLinkId'] = ownerId;
    }

    try {
      final res = await _fetch.fetch(
        HttpMethod.get,
        path,
        headers: _authHeaders(token),
        data: query.isEmpty ? null : query,
      );

      final data = res.data;
      if (data is! Map) {
        throw ServerException(
          'Invalid response format for item details',
          statusCode: res.statusCode ?? 200,
        );
      }
      return Map<String, dynamic>.from(data as Map);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to load item details', original: e);
    }
  }

  Future<Map<String, dynamic>> getDetails(int id, {String? token}) async {
    return getById(id, token: token);
  }

  // ---------------------------------------------------------------------------
  // getInterestBased
  //
  // Activities:
  //   GET /api/items/category-based/{userId}?ownerProjectLinkId=...
  //
  // Products:
  //   GET /api/products/best-sellers?limit=20
  // ---------------------------------------------------------------------------
  Future<List<dynamic>> getInterestBased({
    required int userId,
    required String token,
  }) async {
    final ownerId = _ownerId();

    final headers = _authHeaders(token) ?? <String, String>{};

    String path;
    final query = <String, dynamic>{};

    if (_isEcommerce) {
      path = '$_base/best-sellers';
      query['ownerProjectId'] = ownerId; // may be ignored
      query['limit'] = 20;
    } else {
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

  // ---------------------------------------------------------------------------
  // getNewArrivals
  //
  // Products:
  //   GET /api/products/new-arrivals?days=...
  //
  // Activities:
  //   fallback guest/upcoming
  // ---------------------------------------------------------------------------
  Future<List<dynamic>> getNewArrivals(
      {int? categoryId, int? days, String? token}) async {
    final ownerId = _ownerId();

    String path;
    final query = <String, dynamic>{};

    if (_isEcommerce) {
      _requireTokenForEcommerce(token, 'getNewArrivals/products');
      path = '$_base/new-arrivals';
      query['ownerProjectId'] = ownerId; // may be ignored
      if (categoryId != null)
        query['categoryId'] = categoryId; // backend might ignore
      if (days != null) query['days'] = days;
    } else {
      path = '$_base/guest/upcoming';
      query['ownerProjectLinkId'] = ownerId;
    }

    try {
      final res = await _fetch.fetch(
        HttpMethod.get,
        path,
        headers: _authHeaders(token),
        data: query,
      );

      final data = res.data;
      if (data is! List) {
        throw ServerException(
          'Invalid response format for new arrivals',
          statusCode: res.statusCode ?? 200,
        );
      }
      return data;
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to load new arrivals', original: e);
    }
  }

  Future<List<dynamic>> getBestSellers(
      {int? categoryId, int limit = 20, String? token}) async {
    final ownerId = _ownerId();

    String path;
    final query = <String, dynamic>{};

    if (_isEcommerce) {
      _requireTokenForEcommerce(token, 'getBestSellers/products');
      path = '$_base/best-sellers';
      query['ownerProjectId'] = ownerId; // may be ignored
      query['limit'] = limit;
      if (categoryId != null)
        query['categoryId'] = categoryId; // backend might ignore
    } else {
      path = '$_base/guest/upcoming';
      query['ownerProjectLinkId'] = ownerId;
    }

    try {
      final res = await _fetch.fetch(
        HttpMethod.get,
        path,
        headers: _authHeaders(token),
        data: query,
      );

      final data = res.data;
      if (data is! List) {
        throw ServerException(
          'Invalid response format for best-sellers',
          statusCode: res.statusCode ?? 200,
        );
      }
      return data;
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to load best-sellers', original: e);
    }
  }

  Future<List<dynamic>> getDiscounted({int? categoryId, String? token}) async {
    final ownerId = _ownerId();

    String path;
    final query = <String, dynamic>{};

    if (_isEcommerce) {
      _requireTokenForEcommerce(token, 'getDiscounted/products');
      path = '$_base/discounted';
      query['ownerProjectId'] = ownerId; // may be ignored
      if (categoryId != null)
        query['categoryId'] = categoryId; // backend might ignore
    } else {
      path = '$_base/guest/upcoming';
      query['ownerProjectLinkId'] = ownerId;
    }

    try {
      final res = await _fetch.fetch(
        HttpMethod.get,
        path,
        headers: _authHeaders(token),
        data: query,
      );

      final data = res.data;
      if (data is! List) {
        throw ServerException(
          'Invalid response format for discounted items',
          statusCode: res.statusCode ?? 200,
        );
      }
      return data;
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to load discounted items', original: e);
    }
  }
}
