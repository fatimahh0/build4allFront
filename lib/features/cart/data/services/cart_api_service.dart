import 'dart:convert';
import 'dart:io';

import 'package:build4front/core/config/env.dart';
import 'package:build4front/core/network/globals.dart' as g;
import 'package:build4front/core/exceptions/app_exception.dart';
import 'package:build4front/core/exceptions/network_exception.dart';
import 'package:http/http.dart' as http;

import '../models/cart_model.dart';

class CartApiService {
  final http.Client _client;

  CartApiService({http.Client? client}) : _client = client ?? http.Client();

  String get _base => Env.apiBaseUrl;
  Uri _uri(String path) => Uri.parse('$_base$path');

  Map<String, String> _authHeaders({Map<String, String>? extra}) {
    final token = g.authToken ?? '';
    final map = <String, String>{
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
    if (extra != null) map.addAll(extra);
    return map;
  }

  // GET /api/cart
  Future<CartModel> getCart() async {
    final uri = _uri('/api/cart');
    try {
      final resp = await _client
          .get(uri, headers: _authHeaders())
          .timeout(const Duration(seconds: 30));

      if (resp.statusCode == 204 || resp.body.isEmpty) {
        return CartModel(
          id: 0,
          items: const [],
          itemsSubtotal: 0.0,
          currencySymbol: '',
        );
      }

      final decoded = _safeJson(resp.body);
      if (resp.statusCode >= 400) {
        throw AppException(decoded['error'] ?? 'Failed to load cart');
      }

      return CartModel.fromJson(decoded);
    } on SocketException catch (e) {
      throw NetworkException('No internet connection', original: e);
    }
  }

  // POST /api/cart/items
  Future<CartModel> addItem({
    required int itemId,
    required int quantity,
  }) async {
    final uri = _uri('/api/cart/items');

    final body = jsonEncode({'itemId': itemId, 'quantity': quantity});

    try {
      final resp = await _client
          .post(
            uri,
            headers: _authHeaders(extra: {'Content-Type': 'application/json'}),
            body: body,
          )
          .timeout(const Duration(seconds: 30));

      final decoded = _safeJson(resp.body);
      if (resp.statusCode >= 400) {
        throw AppException(decoded['error'] ?? 'Failed to add to cart');
      }

      return CartModel.fromJson(decoded);
    } on SocketException catch (e) {
      throw NetworkException('No internet connection', original: e);
    }
  }

  // PUT /api/cart/items/{cartItemId}
  Future<CartModel> updateItemQuantity({
    required int cartItemId,
    required int quantity,
  }) async {
    final uri = _uri('/api/cart/items/$cartItemId');

    final body = jsonEncode({'quantity': quantity});

    try {
      final resp = await _client
          .put(
            uri,
            headers: _authHeaders(extra: {'Content-Type': 'application/json'}),
            body: body,
          )
          .timeout(const Duration(seconds: 30));

      final decoded = _safeJson(resp.body);
      if (resp.statusCode >= 400) {
        throw AppException(decoded['error'] ?? 'Failed to update cart item');
      }

      return CartModel.fromJson(decoded);
    } on SocketException catch (e) {
      throw NetworkException('No internet connection', original: e);
    }
  }

  // DELETE /api/cart/items/{cartItemId}
  Future<CartModel> removeItem({required int cartItemId}) async {
    final uri = _uri('/api/cart/items/$cartItemId');

    try {
      final resp = await _client
          .delete(uri, headers: _authHeaders())
          .timeout(const Duration(seconds: 30));

      if (resp.statusCode == 204 || resp.body.isEmpty) {
        return CartModel(
          id: 0,
          items: const [],
          itemsSubtotal: 0.0,
          currencySymbol: '',
        );
      }

      final decoded = _safeJson(resp.body);
      if (resp.statusCode >= 400) {
        throw AppException(decoded['error'] ?? 'Failed to remove cart item');
      }

      return CartModel.fromJson(decoded);
    } on SocketException catch (e) {
      throw NetworkException('No internet connection', original: e);
    }
  }

  // DELETE /api/cart
  Future<void> clearCart() async {
    final uri = _uri('/api/cart');

    try {
      final resp = await _client
          .delete(uri, headers: _authHeaders())
          .timeout(const Duration(seconds: 30));

      if (resp.statusCode >= 400) {
        final decoded = _safeJson(resp.body);
        throw AppException(decoded['error'] ?? 'Failed to clear cart');
      }
    } on SocketException catch (e) {
      throw NetworkException('No internet connection', original: e);
    }
  }

  Map<String, dynamic> _safeJson(String body) {
    if (body.isEmpty) return {};
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) return decoded;
      return {};
    } catch (_) {
      return {};
    }
  }
}
