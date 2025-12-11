// lib/features/cart/data/models/cart_item_model.dart
class CartItemModel {
  final int cartItemId;
  final int itemId;
  final String itemName;
  final String? imageUrl;
  final int quantity;
  final double unitPrice;
  final double lineTotal;

  const CartItemModel({
    required this.cartItemId,
    required this.itemId,
    required this.itemName,
    required this.imageUrl,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      cartItemId: (json['cartItemId'] ?? json['id']) as int,
      itemId: json['itemId'] as int,
      itemName: (json['itemName'] ?? '') as String,
      imageUrl: json['imageUrl'] as String?,
      quantity: (json['quantity'] ?? 0) as int,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      lineTotal: (json['lineTotal'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cartItemId': cartItemId,
      'itemId': itemId,
      'itemName': itemName,
      'imageUrl': imageUrl,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'lineTotal': lineTotal,
    };
  }
}
