import 'package:build4front/features/cart/domain/entities/cart_entity.dart';
import 'package:build4front/features/cart/domain/usecases/add_to_cart.dart';
import 'package:build4front/features/cart/domain/usecases/clear_cart.dart';
import 'package:build4front/features/cart/domain/usecases/get_cart.dart';
import 'package:build4front/features/cart/domain/usecases/remove_cart_item.dart';
import 'package:build4front/features/cart/domain/usecases/update_cart_item.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cart_event.dart';
import 'cart_state.dart';



class CartBloc extends Bloc<CartEvent, CartState> {
  final GetCart getCart;
  final AddToCart addToCart;
  final UpdateCartItem updateCartItem;
  final RemoveCartItem removeCartItem;
  final ClearCart clearCart;

  CartBloc({
    required this.getCart,
    required this.addToCart,
    required this.updateCartItem,
    required this.removeCartItem,
    required this.clearCart,
  }) : super(CartState.initial()) {
    on<CartLoadRequested>(_onLoad);
    on<CartAddItemRequested>(_onAddItem);
    on<CartUpdateItemRequested>(_onUpdateItem);
    on<CartRemoveItemRequested>(_onRemoveItem);
    on<CartClearRequested>(_onClear);
  }

  Future<void> _onLoad(CartLoadRequested event, Emitter<CartState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final cartEntity = await getCart();
      emit(state.copyWith(isLoading: false, cart: cartEntity, error: null));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e));
    }
  }

  Future<void> _onAddItem(
    CartAddItemRequested event,
    Emitter<CartState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final updated = await addToCart(
        itemId: event.itemId,
        quantity: event.quantity,
      );
      emit(state.copyWith(isLoading: false, cart: updated, error: null));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e));
    }
  }

  Future<void> _onUpdateItem(
    CartUpdateItemRequested event,
    Emitter<CartState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final updated = await updateCartItem(
        cartItemId: event.cartItemId,
        quantity: event.quantity,
      );
      emit(state.copyWith(isLoading: false, cart: updated, error: null));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e));
    }
  }

  Future<void> _onRemoveItem(
    CartRemoveItemRequested event,
    Emitter<CartState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final updated = await removeCartItem(cartItemId: event.cartItemId);
      emit(state.copyWith(isLoading: false, cart: updated, error: null));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e));
    }
  }

  Future<void> _onClear(
    CartClearRequested event,
    Emitter<CartState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      await clearCart();
      emit(
        state.copyWith(
          isLoading: false,
          cart: const CartEntity(
            id: 0,
            items: [],
            itemsSubtotal: 0,
            currencySymbol: '',
          ),
          error: null,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e));
    }
  }
}
