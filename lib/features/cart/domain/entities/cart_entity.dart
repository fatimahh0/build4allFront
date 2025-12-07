import 'cart_item_entity.dart';

class CartEntity {
  final int id;
  final List<CartItemEntity> items;
  final double itemsSubtotal;
  final String currencySymbol;

  const CartEntity({
    required this.id,
    required this.items,
    required this.itemsSubtotal,
    required this.currencySymbol,
  });

  bool get isEmpty => items.isEmpty;
}
