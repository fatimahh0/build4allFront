// lib/features/cart/data/models/cart_model.dart
import 'cart_item_model.dart';

class CartModel {
  final int cartId;
  final String status;

  final double itemsTotal;
  final double shippingTotal;
  final double taxTotal;
  final double? discountTotal;
  final double grandTotal;

  final String? currencySymbol;
  final List<CartItemModel> items;

  // ✅ NEW from backend
  final bool canCheckout;
  final List<String> blockingErrors;
  final double? checkoutTotalPrice;

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

    // new
    required this.canCheckout,
    required this.blockingErrors,
    required this.checkoutTotalPrice,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    double _d(dynamic v) =>
        v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '') ?? 0.0;

    return CartModel(
      cartId: (json['cartId'] ?? json['id']) as int,
      status: (json['status'] ?? 'ACTIVE') as String,

      // backend تبعك بيبعت totalPrice + checkoutTotalPrice
      itemsTotal: json['itemsTotal'] != null
          ? _d(json['itemsTotal'])
          : _d(json['totalPrice']),
      shippingTotal: _d(json['shippingTotal']),
      taxTotal: _d(json['taxTotal']),
      discountTotal:
          json['discountTotal'] != null ? _d(json['discountTotal']) : null,
      grandTotal: json['grandTotal'] != null
          ? _d(json['grandTotal'])
          : _d(json['totalPrice']),

      currencySymbol: json['currencySymbol'] as String?,
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),

      // ✅ NEW mapping
      canCheckout: (json['canCheckout'] ?? true) as bool,
      blockingErrors: (json['blockingErrors'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      checkoutTotalPrice: json['checkoutTotalPrice'] != null
          ? _d(json['checkoutTotalPrice'])
          : null,
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

      // new
      'canCheckout': canCheckout,
      'blockingErrors': blockingErrors,
      'checkoutTotalPrice': checkoutTotalPrice,
    };
  }
}
