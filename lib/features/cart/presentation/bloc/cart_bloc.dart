// lib/features/cart/presentation/bloc/cart_bloc.dart
import 'package:dio/dio.dart';
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

  String _extractErrorMessage(Object error) {
    if (error is DioException) {
      final data = error.response?.data;

      if (data is Map<String, dynamic>) {
        final backendError = data['error'];
        final backendMessage = data['message'];

        if (backendError is String && backendError.trim().isNotEmpty) {
          return backendError.trim();
        }

        if (backendMessage is String && backendMessage.trim().isNotEmpty) {
          return backendMessage.trim();
        }
      }

      if (data is String && data.trim().isNotEmpty) {
        return data.trim();
      }

      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Request timed out. Please try again.';
        case DioExceptionType.connectionError:
          return 'Connection error. Please check your internet.';
        case DioExceptionType.badResponse:
          return 'Request failed. Please try again.';
        case DioExceptionType.cancel:
          return 'Request cancelled.';
        case DioExceptionType.badCertificate:
          return 'Security certificate error.';
        case DioExceptionType.unknown:
          return 'Something went wrong. Please try again.';
      }
    }

    return 'Something went wrong. Please try again.';
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

      emit(
        state.copyWith(
          isLoading: false,
          isUpdating: false,
          cart: cart,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          isUpdating: false,
          errorMessage: _extractErrorMessage(e),
        ),
      );
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
        state.copyWith(
          isUpdating: true,
          errorMessage: null,
          lastMessage: null,
        ),
      );

      final cart = await addToCartUc(
        itemId: event.itemId,
        quantity: event.quantity,
      );

      emit(
        state.copyWith(
          isUpdating: false,
          cart: cart,
          errorMessage: null,
          lastMessage: 'cart_item_added',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isUpdating: false,
          errorMessage: _extractErrorMessage(e),
          lastMessage: null,
        ),
      );

      await _safeLoad(emit, showLoading: false);
    }
  }

  Future<void> _onChangeQty(
    CartItemQuantityChanged event,
    Emitter<CartState> emit,
  ) async {
    try {
      emit(
        state.copyWith(
          isUpdating: true,
          errorMessage: null,
          lastMessage: null,
        ),
      );

      final cart = await updateCartItemUc(
        cartItemId: event.cartItemId,
        quantity: event.quantity,
      );

      emit(
        state.copyWith(
          isUpdating: false,
          cart: cart,
          errorMessage: null,
          lastMessage: 'cart_item_updated',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isUpdating: false,
          errorMessage: _extractErrorMessage(e),
          lastMessage: null,
        ),
      );

      await _safeLoad(emit, showLoading: false);
    }
  }

  Future<void> _onRemoveItem(
    CartItemRemoved event,
    Emitter<CartState> emit,
  ) async {
    try {
      emit(
        state.copyWith(
          isUpdating: true,
          errorMessage: null,
          lastMessage: null,
        ),
      );

      final cart = await removeCartItemUc(cartItemId: event.cartItemId);

      emit(
        state.copyWith(
          isUpdating: false,
          cart: cart,
          errorMessage: null,
          lastMessage: 'cart_item_removed',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isUpdating: false,
          errorMessage: _extractErrorMessage(e),
          lastMessage: null,
        ),
      );
    }
  }

  Future<void> _onClear(CartCleared event, Emitter<CartState> emit) async {
    try {
      emit(
        state.copyWith(
          isUpdating: true,
          errorMessage: null,
          lastMessage: null,
        ),
      );

      await clearCartUc();
      final cart = await getMyCart();

      emit(
        state.copyWith(
          isUpdating: false,
          cart: cart,
          errorMessage: null,
          lastMessage: 'cart_cleared',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isUpdating: false,
          errorMessage: _extractErrorMessage(e),
          lastMessage: null,
        ),
      );
    }
  }
}