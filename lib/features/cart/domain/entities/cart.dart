// lib/features/cart/domain/entities/cart.dart
import 'package:equatable/equatable.dart';
import 'cart_item.dart';

class Cart extends Equatable {
  final int id;
  final String status;
  final double totalPrice;
  final String? currencySymbol;
  final List<CartItem> items;

  const Cart({
    required this.id,
    required this.status,
    required this.totalPrice,
    required this.currencySymbol,
    required this.items,
  });

  bool get isEmpty => items.isEmpty;

  @override
  List<Object?> get props => [id, status, totalPrice, currencySymbol, items];
}
