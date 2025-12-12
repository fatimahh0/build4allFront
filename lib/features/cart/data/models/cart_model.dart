// lib/features/cart/data/models/cart_model.dart
import 'cart_item_model.dart';

class CartModel {
  final int cartId;
  final String status;

  /// New fields from backend
  final double itemsTotal;
  final double shippingTotal;
  final double taxTotal;
  final double? discountTotal;
  final double grandTotal;

  final String? currencySymbol;
  final List<CartItemModel> items;

  const CartModel({
    required this.cartId,
    required this.status,
    required this.itemsTotal,
    required this.shippingTotal,
    required this.taxTotal,
    required this.discountTotal,
    required this.grandTotal,
    required this.currencySymbol,
    required this.items,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    double _d(dynamic v) =>
        v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '') ?? 0.0;

    return CartModel(
      cartId: (json['cartId'] ?? json['id']) as int,
      status: (json['status'] ?? 'ACTIVE') as String,

      // if backend not ready yet, fall back to old totalPrice
      itemsTotal: json['itemsTotal'] != null
          ? _d(json['itemsTotal'])
          : _d(json['totalPrice']),
      shippingTotal: _d(json['shippingTotal']),
      taxTotal: _d(json['taxTotal']),
      discountTotal: json['discountTotal'] != null
          ? _d(json['discountTotal'])
          : null,
      grandTotal: json['grandTotal'] != null
          ? _d(json['grandTotal'])
          : _d(json['totalPrice']),

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
      'itemsTotal': itemsTotal,
      'shippingTotal': shippingTotal,
      'taxTotal': taxTotal,
      'discountTotal': discountTotal,
      'grandTotal': grandTotal,
      'currencySymbol': currencySymbol,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }
}
