import '../entities/cart_entity.dart';

abstract class CartRepository {
  Future<CartEntity> getCart();
  Future<CartEntity> addItem({required int itemId, required int quantity});
  Future<CartEntity> updateItemQuantity({
    required int cartItemId,
    required int quantity,
  });
  Future<CartEntity> removeItem({required int cartItemId});
  Future<void> clearCart();
}
