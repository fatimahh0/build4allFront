import 'package:equatable/equatable.dart';
import 'package:build4front/features/cart/domain/entities/cart_entity.dart';

class CartState extends Equatable {
  final bool isLoading;
  final CartEntity? cart;
  final Object? error;

  const CartState({required this.isLoading, this.cart, this.error});

  factory CartState.initial() => const CartState(isLoading: false);

  CartState copyWith({bool? isLoading, CartEntity? cart, Object? error}) {
    return CartState(
      isLoading: isLoading ?? this.isLoading,
      cart: cart ?? this.cart,
      error: error,
    );
  }

  @override
  List<Object?> get props => [isLoading, cart, error];
}
