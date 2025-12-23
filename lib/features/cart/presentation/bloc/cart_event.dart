// lib/features/cart/presentation/bloc/cart_event.dart
import 'package:equatable/equatable.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class CartStarted extends CartEvent {
  const CartStarted();
}

class CartReset extends CartEvent {
  const CartReset();
}


class CartRefreshed extends CartEvent {
  const CartRefreshed();
}

class CartAddItemRequested extends CartEvent {
  final int itemId;
  final int quantity;

  const CartAddItemRequested({required this.itemId, this.quantity = 1});

  @override
  List<Object?> get props => [itemId, quantity];
}

class CartItemQuantityChanged extends CartEvent {
  final int cartItemId;
  final int quantity;

  const CartItemQuantityChanged({
    required this.cartItemId,
    required this.quantity,
  });

  @override
  List<Object?> get props => [cartItemId, quantity];
}

class CartItemRemoved extends CartEvent {
  final int cartItemId;

  const CartItemRemoved({required this.cartItemId});

  @override
  List<Object?> get props => [cartItemId];
}

class CartCleared extends CartEvent {
  const CartCleared();
}
