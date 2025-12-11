// lib/features/cart/data/models/cart_model.dart
import 'cart_item_model.dart';

class CartModel {
  final int cartId;
  final String status;
  final double totalPrice;
  final String? currencySymbol;
  final List<CartItemModel> items;

  const CartModel({
    required this.cartId,
    required this.status,
    required this.totalPrice,
    required this.currencySymbol,
    required this.items,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      cartId: (json['cartId'] ?? json['id']) as int,
      status: (json['status'] ?? 'ACTIVE') as String,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      currencySymbol: json['currencySymbol'] as String?,
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cartId': cartId,
      'status': status,
      'totalPrice': totalPrice,
      'currencySymbol': currencySymbol,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }
}
