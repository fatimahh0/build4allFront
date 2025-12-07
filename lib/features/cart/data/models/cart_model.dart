import '../../../cart/domain/entities/cart_entity.dart';
import 'cart_item_model.dart';

class CartModel {
  final int id;
  final List<CartItemModel> items;
  final double itemsSubtotal;
  final String currencySymbol;

  CartModel({
    required this.id,
    required this.items,
    required this.itemsSubtotal,
    required this.currencySymbol,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    final itemsJson = (json['items'] as List? ?? []);

    return CartModel(
      id: (json['id'] as num).toInt(),
      items: itemsJson
          .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      itemsSubtotal: (json['itemsSubtotal'] as num?)?.toDouble() ?? 0.0,
      currencySymbol: json['currencySymbol'] as String? ?? '',
    );
  }

  CartEntity toEntity() {
    return CartEntity(
      id: id,
      items: items.map((m) => m.toEntity()).toList(),
      itemsSubtotal: itemsSubtotal,
      currencySymbol: currencySymbol,
    );
  }
}
