class CartItemEntity {
  final int id;          // cartItemId from backend
  final int itemId;      // Item / Product id
  final String name;
  final int quantity;
  final double unitPrice;
  final double lineSubtotal;
  final String? imageUrl;

  const CartItemEntity({
    required this.id,
    required this.itemId,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.lineSubtotal,
    this.imageUrl,
  });
}
