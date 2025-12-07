import '../../../cart/domain/entities/cart_item_entity.dart';

class CartItemModel {
  final int id; // cartItemId
  final int itemId;
  final String name;
  final int quantity;
  final double unitPrice;
  final double lineSubtotal;
  final String? imageUrl;

  CartItemModel({
    required this.id,
    required this.itemId,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.lineSubtotal,
    this.imageUrl,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: (json['id'] as num).toInt(),
      itemId: (json['itemId'] as num).toInt(),
      name: json['name'] as String? ?? '',
      quantity: (json['quantity'] as num).toInt(),
      unitPrice: (json['unitPrice'] as num).toDouble(),
      lineSubtotal: (json['lineSubtotal'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String?,
    );
  }

  CartItemEntity toEntity() {
    return CartItemEntity(
      id: id,
      itemId: itemId,
      name: name,
      quantity: quantity,
      unitPrice: unitPrice,
      lineSubtotal: lineSubtotal,
      imageUrl: imageUrl,
    );
  }
}
