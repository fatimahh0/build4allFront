import 'package:build4front/features/cart/domain/entities/cart_entity.dart';
import 'package:build4front/features/cart/domain/repositories/cart_repository.dart';

import '../models/cart_model.dart';
import '../services/cart_api_service.dart';

class CartRepositoryImpl implements CartRepository {
  final CartApiService api;

  CartRepositoryImpl(this.api);

  @override
  Future<CartEntity> getCart() async {
    final CartModel model = await api.getCart();
    return model.toEntity();
  }

  @override
  Future<CartEntity> addItem({
    required int itemId,
    required int quantity,
  }) async {
    final CartModel model = await api.addItem(
      itemId: itemId,
      quantity: quantity,
    );
    return model.toEntity();
  }

  @override
  Future<CartEntity> updateItemQuantity({
    required int cartItemId,
    required int quantity,
  }) async {
    final CartModel model = await api.updateItemQuantity(
      cartItemId: cartItemId,
      quantity: quantity,
    );
    return model.toEntity();
  }

  @override
  Future<CartEntity> removeItem({required int cartItemId}) async {
    final CartModel model = await api.removeItem(cartItemId: cartItemId);
    return model.toEntity();
  }

  @override
  Future<void> clearCart() {
    return api.clearCart();
  }
}
