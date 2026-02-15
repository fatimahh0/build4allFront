// lib/features/cart/data/repositories/cart_repository_impl.dart
import 'package:build4front/features/cart/data/services/cart_api_service.dart';
import 'package:build4front/features/cart/domain/entities/cart.dart';
import 'package:build4front/features/cart/domain/entities/cart_item.dart';

import 'package:build4front/features/cart/domain/repositories/cart_repository.dart';

import '../models/cart_model.dart';
import '../models/cart_item_model.dart';

class CartRepositoryImpl implements CartRepository {
  final CartApiService api;

  CartRepositoryImpl(this.api);

 Cart _mapCart(CartModel model) {
    return Cart(
      id: model.cartId,
      status: model.status,
      itemsTotal: model.itemsTotal,
      shippingTotal: model.shippingTotal,
      taxTotal: model.taxTotal,
      discountTotal: model.discountTotal,
      grandTotal: model.grandTotal,
      currencySymbol: model.currencySymbol,
      items: model.items.map(_mapCartItem).toList(),

      // ✅ NEW
      canCheckout: model.canCheckout,
      blockingErrors: model.blockingErrors,
      checkoutTotalPrice: model.checkoutTotalPrice,
    );
  }

  CartItem _mapCartItem(CartItemModel m) {
    return CartItem(
      cartItemId: m.cartItemId,
      itemId: m.itemId,
      itemName: m.itemName,
      imageUrl: m.imageUrl,
      quantity: m.quantity,
      unitPrice: m.unitPrice,
      lineTotal: m.lineTotal,

      // ✅ NEW
      availableStock: m.availableStock,
      outOfStock: m.outOfStock,
      quantityExceedsStock: m.quantityExceedsStock,
      maxAllowedQuantity: m.maxAllowedQuantity,
      disabled: m.disabled,
      blockingReason: m.blockingReason,
    );
  }

  @override
  Future<Cart> getMyCart() async {
    final model = await api.getMyCart();
    return _mapCart(model);
  }

  @override
  Future<Cart> addToCart({required int itemId, int quantity = 1}) async {
    final model = await api.addToCart(itemId: itemId, quantity: quantity);
    return _mapCart(model);
  }

  @override
  Future<Cart> updateCartItem({
    required int cartItemId,
    required int quantity,
  }) async {
    final model = await api.updateCartItem(
      cartItemId: cartItemId,
      quantity: quantity,
    );
    return _mapCart(model);
  }

  @override
  Future<Cart> removeCartItem({required int cartItemId}) async {
    final model = await api.removeCartItem(cartItemId: cartItemId);
    return _mapCart(model);
  }

  @override
  Future<void> clearCart() {
    return api.clearCart();
  }
}
