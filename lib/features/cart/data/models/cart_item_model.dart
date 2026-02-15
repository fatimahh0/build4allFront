// lib/features/cart/data/models/cart_item_model.dart
class CartItemModel {
  final int cartItemId;
  final int itemId;
  final String itemName;
  final String? imageUrl;
  final int quantity;
  final double unitPrice;
  final double lineTotal;

  // ✅ NEW from backend
  final int? availableStock; // null => stock not tracked
  final bool outOfStock;
  final bool quantityExceedsStock;
  final int? maxAllowedQuantity; // equals stock when tracked
  final bool disabled;
  final String? blockingReason;

  const CartItemModel({
    required this.cartItemId,
    required this.itemId,
    required this.itemName,
    required this.imageUrl,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,

    // new
    required this.availableStock,
    required this.outOfStock,
    required this.quantityExceedsStock,
    required this.maxAllowedQuantity,
    required this.disabled,
    required this.blockingReason,
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

      // ✅ NEW mapping
      availableStock: json['availableStock'] as int?,
      outOfStock: (json['outOfStock'] ?? false) as bool,
      quantityExceedsStock: (json['quantityExceedsStock'] ?? false) as bool,
      maxAllowedQuantity: json['maxAllowedQuantity'] as int?,
      disabled: (json['disabled'] ?? false) as bool,
      blockingReason: json['blockingReason'] as String?,
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

      // new
      'availableStock': availableStock,
      'outOfStock': outOfStock,
      'quantityExceedsStock': quantityExceedsStock,
      'maxAllowedQuantity': maxAllowedQuantity,
      'disabled': disabled,
      'blockingReason': blockingReason,
    };
  }
}
