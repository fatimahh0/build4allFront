// lib/features/cart/presentation/bloc/cart_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cart_event.dart';
import 'cart_state.dart';

import 'package:build4front/features/cart/domain/usecases/get_my_cart.dart';
import 'package:build4front/features/cart/domain/usecases/add_to_cart.dart';
import 'package:build4front/features/cart/domain/usecases/update_cart_item.dart';
import 'package:build4front/features/cart/domain/usecases/remove_cart_item.dart';
import 'package:build4front/features/cart/domain/usecases/clear_cart.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final GetMyCart getMyCart;
  final AddToCart addToCartUc;
  final UpdateCartItem updateCartItemUc;
  final RemoveCartItem removeCartItemUc;
  final ClearCart clearCartUc;

  CartBloc({
    required this.getMyCart,
    required this.addToCartUc,
    required this.updateCartItemUc,
    required this.removeCartItemUc,
    required this.clearCartUc,
  }) : super(CartState.initial()) {
    on<CartStarted>(_onStarted);
    on<CartRefreshed>(_onRefreshed);
    on<CartAddItemRequested>(_onAddItem);
    on<CartItemQuantityChanged>(_onChangeQty);
    on<CartItemRemoved>(_onRemoveItem);
    on<CartCleared>(_onClear);
    on<CartReset>(_onReset);

  }

  Future<void> _safeLoad(
    Emitter<CartState> emit, {
    bool showLoading = true,
  }) async {
    try {
      if (showLoading) {
        emit(
          state.copyWith(
            isLoading: true,
            errorMessage: null,
            lastMessage: null,
          ),
        );
      }
      final cart = await getMyCart();
      emit(state.copyWith(isLoading: false, cart: cart));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onReset(CartReset event, Emitter<CartState> emit) async {
    emit(CartState.initial());
  }


  Future<void> _onStarted(CartStarted event, Emitter<CartState> emit) async {
    await _safeLoad(emit);
  }

  Future<void> _onRefreshed(
    CartRefreshed event,
    Emitter<CartState> emit,
  ) async {
    await _safeLoad(emit, showLoading: false);
  }

  Future<void> _onAddItem(
    CartAddItemRequested event,
    Emitter<CartState> emit,
  ) async {
    try {
      emit(
        state.copyWith(isUpdating: true, errorMessage: null, lastMessage: null),
      );
      final cart = await addToCartUc(
        itemId: event.itemId,
        quantity: event.quantity,
      );
      emit(
        state.copyWith(
          isUpdating: false,
          cart: cart,
          lastMessage: 'cart_item_added', // will map to l10n in UI
        ),
      );
    } catch (e) {
      emit(state.copyWith(isUpdating: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onChangeQty(
    CartItemQuantityChanged event,
    Emitter<CartState> emit,
  ) async {
    try {
      emit(
        state.copyWith(isUpdating: true, errorMessage: null, lastMessage: null),
      );
      final cart = await updateCartItemUc(
        cartItemId: event.cartItemId,
        quantity: event.quantity,
      );
      emit(
        state.copyWith(
          isUpdating: false,
          cart: cart,
          lastMessage: 'cart_item_updated',
        ),
      );
    } catch (e) {
      emit(state.copyWith(isUpdating: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onRemoveItem(
    CartItemRemoved event,
    Emitter<CartState> emit,
  ) async {
    try {
      emit(
        state.copyWith(isUpdating: true, errorMessage: null, lastMessage: null),
      );
      final cart = await removeCartItemUc(cartItemId: event.cartItemId);
      emit(
        state.copyWith(
          isUpdating: false,
          cart: cart,
          lastMessage: 'cart_item_removed',
        ),
      );
    } catch (e) {
      emit(state.copyWith(isUpdating: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onClear(CartCleared event, Emitter<CartState> emit) async {
    try {
      emit(
        state.copyWith(isUpdating: true, errorMessage: null, lastMessage: null),
      );
      await clearCartUc();
      // reload empty cart
      final cart = await getMyCart();
      emit(
        state.copyWith(
          isUpdating: false,
          cart: cart,
          lastMessage: 'cart_cleared',
        ),
      );
    } catch (e) {
      emit(state.copyWith(isUpdating: false, errorMessage: e.toString()));
    }
  }
}
