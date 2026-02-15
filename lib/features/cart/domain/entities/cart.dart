// lib/features/cart/domain/entities/cart.dart
import 'package:equatable/equatable.dart';
import 'cart_item.dart';

class Cart extends Equatable {
  final int id;
  final String status;

  final double itemsTotal;
  final double shippingTotal;
  final double taxTotal;
  final double? discountTotal;
  final double grandTotal;

  final String? currencySymbol;
  final List<CartItem> items;

  // ✅ NEW
  final bool canCheckout;
  final List<String> blockingErrors;
  final double? checkoutTotalPrice;

  const Cart({
    required this.id,
    required this.status,
    required this.itemsTotal,
    required this.shippingTotal,
    required this.taxTotal,
    required this.discountTotal,
    required this.grandTotal,
    required this.currencySymbol,
    required this.items,
    required this.canCheckout,
    required this.blockingErrors,
    required this.checkoutTotalPrice,
  });

  bool get isEmpty => items.isEmpty;

  @override
  List<Object?> get props => [
        id,
        status,
        itemsTotal,
        shippingTotal,
        taxTotal,
        discountTotal,
        grandTotal,
        currencySymbol,
        items,
        canCheckout,
        blockingErrors,
        checkoutTotalPrice,
      ];
}
