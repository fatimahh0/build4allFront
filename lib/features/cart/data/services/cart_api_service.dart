// lib/features/cart/data/datasources/cart_api_service.dart
import 'package:dio/dio.dart';
import 'package:build4front/core/network/globals.dart' as g;

import '../models/cart_model.dart';

class CartApiService {
  final Dio _dio;

  CartApiService() : _dio = g.dio();

  Future<CartModel> getMyCart() async {
    final resp = await _dio.get('/api/cart');
    return CartModel.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<CartModel> addToCart({required int itemId, int quantity = 1}) async {
    final resp = await _dio.post(
      '/api/cart/items',
      data: {'itemId': itemId, 'quantity': quantity},
    );
    return CartModel.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<CartModel> updateCartItem({
    required int cartItemId,
    required int quantity,
  }) async {
    final resp = await _dio.put(
      '/api/cart/items/$cartItemId',
      data: {'quantity': quantity},
    );
    return CartModel.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<CartModel> removeCartItem({required int cartItemId}) async {
    final resp = await _dio.delete('/api/cart/items/$cartItemId');
    return CartModel.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<void> clearCart() async {
    await _dio.delete('/api/cart');
  }
}
