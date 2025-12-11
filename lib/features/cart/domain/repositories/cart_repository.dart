// lib/features/cart/domain/repositories/cart_repository.dart
import '../entities/cart.dart';

abstract class CartRepository {
  Future<Cart> getMyCart();

  Future<Cart> addToCart({required int itemId, int quantity = 1});

  Future<Cart> updateCartItem({required int cartItemId, required int quantity});

  Future<Cart> removeCartItem({required int cartItemId});

  Future<void> clearCart();
}
