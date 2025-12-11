// lib/features/cart/presentation/bloc/cart_state.dart
import 'package:equatable/equatable.dart';
import 'package:build4front/features/cart/domain/entities/cart.dart';

class CartState extends Equatable {
  final bool isLoading;
  final bool isUpdating; // when mutating quantity / add / remove
  final Cart? cart;
  final String? errorMessage;
  final String? lastMessage; // for SnackBar messages

  const CartState({
    required this.isLoading,
    required this.isUpdating,
    required this.cart,
    required this.errorMessage,
    required this.lastMessage,
  });

  factory CartState.initial() => const CartState(
    isLoading: false,
    isUpdating: false,
    cart: null,
    errorMessage: null,
    lastMessage: null,
  );

  CartState copyWith({
    bool? isLoading,
    bool? isUpdating,
    Cart? cart,
    String? errorMessage,
    String? lastMessage,
  }) {
    return CartState(
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating,
      cart: cart ?? this.cart,
      errorMessage: errorMessage,
      lastMessage: lastMessage,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isUpdating,
    cart,
    errorMessage,
    lastMessage,
  ];
}
