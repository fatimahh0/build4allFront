import 'package:equatable/equatable.dart';

class CartEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CartLoadRequested extends CartEvent {}

class CartAddItemRequested extends CartEvent {
  final int itemId;
  final int quantity;

  CartAddItemRequested({required this.itemId, this.quantity = 1});

  @override
  List<Object?> get props => [itemId, quantity];
}

class CartUpdateItemRequested extends CartEvent {
  final int cartItemId;
  final int quantity;

  CartUpdateItemRequested({required this.cartItemId, required this.quantity});

  @override
  List<Object?> get props => [cartItemId, quantity];
}

class CartRemoveItemRequested extends CartEvent {
  final int cartItemId;

  CartRemoveItemRequested(this.cartItemId);

  @override
  List<Object?> get props => [cartItemId];
}

class CartClearRequested extends CartEvent {}
