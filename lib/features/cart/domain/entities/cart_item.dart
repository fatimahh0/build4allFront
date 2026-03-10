// lib/features/cart/domain/entities/cart_item.dart
import 'package:equatable/equatable.dart';

class CartItem extends Equatable {
  final int cartItemId;
  final int itemId;
  final String itemName;
  final String? imageUrl;
  final int quantity;
  final double unitPrice;
  final double lineTotal;

  final int? availableStock;
  final bool outOfStock;
  final bool quantityExceedsStock;
  final int? maxAllowedQuantity;
  final bool disabled;
  final String? blockingReason;

  // ✅ NEW
  final bool isUpcoming;
  final String? statusCode;
  final String? statusName;

  const CartItem({
    required this.cartItemId,
    required this.itemId,
    required this.itemName,
    required this.imageUrl,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
    required this.availableStock,
    required this.outOfStock,
    required this.quantityExceedsStock,
    required this.maxAllowedQuantity,
    required this.disabled,
    required this.blockingReason,
    required this.isUpcoming,
    required this.statusCode,
    required this.statusName,
  });

  String get normalizedStatusCode => (statusCode ?? '').trim().toUpperCase();
  String get normalizedStatusName => (statusName ?? '').trim().toUpperCase();

  bool get isComingSoon =>
      isUpcoming ||
      normalizedStatusCode == 'UPCOMING' ||
      normalizedStatusName == 'UPCOMING' ||
      normalizedStatusCode == 'COMING_SOON' ||
      normalizedStatusName == 'COMING_SOON' ||
      normalizedStatusName == 'COMING SOON';

  bool get isBlockedInCart =>
      disabled || outOfStock || quantityExceedsStock || isComingSoon;

  String? get effectiveBlockingReason {
    final r = (blockingReason ?? '').trim();
    if (r.isNotEmpty) return r;
    if (isComingSoon) return 'Coming Soon';
    if (outOfStock) return 'Out of stock';
    return null;
  }

  CartItem copyWith({
    int? quantity,
  }) {
    return CartItem(
      cartItemId: cartItemId,
      itemId: itemId,
      itemName: itemName,
      imageUrl: imageUrl,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice,
      lineTotal: lineTotal,
      availableStock: availableStock,
      outOfStock: outOfStock,
      quantityExceedsStock: quantityExceedsStock,
      maxAllowedQuantity: maxAllowedQuantity,
      disabled: disabled,
      blockingReason: blockingReason,
      isUpcoming: isUpcoming,
      statusCode: statusCode,
      statusName: statusName,
    );
  }

  @override
  List<Object?> get props => [
        cartItemId,
        itemId,
        itemName,
        imageUrl,
        quantity,
        unitPrice,
        lineTotal,
        availableStock,
        outOfStock,
        quantityExceedsStock,
        maxAllowedQuantity,
        disabled,
        blockingReason,
        isUpcoming,
        statusCode,
        statusName,
      ];
}