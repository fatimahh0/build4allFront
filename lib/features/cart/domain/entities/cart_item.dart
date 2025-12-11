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

  const CartItem({
    required this.cartItemId,
    required this.itemId,
    required this.itemName,
    required this.imageUrl,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
  });

  CartItem copyWith({int? quantity, double? unitPrice, double? lineTotal}) {
    return CartItem(
      cartItemId: cartItemId,
      itemId: itemId,
      itemName: itemName,
      imageUrl: imageUrl,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      lineTotal: lineTotal ?? this.lineTotal,
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
  ];
}
