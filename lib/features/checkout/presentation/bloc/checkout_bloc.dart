import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4front/features/checkout/domain/entities/checkout_entities.dart';
import 'package:build4front/features/checkout/domain/usecases/get_checkout_cart.dart';
import 'package:build4front/features/checkout/domain/usecases/get_payment_methods.dart';
import 'package:build4front/features/checkout/domain/usecases/get_shipping_quotes.dart';
import 'package:build4front/features/checkout/domain/usecases/place_order.dart';
import 'package:build4front/features/checkout/domain/usecases/preview_tax.dart';

import 'checkout_event.dart';
import 'checkout_state.dart';

class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  final GetCheckoutCart getCart;
  final GetPaymentMethods getPaymentMethods;
  final GetShippingQuotes getShippingQuotes;
  final PreviewTax previewTax;
  final PlaceOrder placeOrder;

  final int ownerProjectId;
  final int? currencyId;

  CheckoutBloc({
    required this.getCart,
    required this.getPaymentMethods,
    required this.getShippingQuotes,
    required this.previewTax,
    required this.placeOrder,
    required this.ownerProjectId,
    required this.currencyId,
  }) : super(CheckoutState.initial()) {
    on<CheckoutStarted>(_onStarted);
    on<CheckoutAddressChanged>(_onAddressChanged);
    on<CheckoutShippingSelected>(_onShippingSelected);
    on<CheckoutCouponChanged>(_onCouponChanged);
    on<CheckoutPaymentSelected>(_onPaymentSelected);
    on<CheckoutRefreshRequested>(_onRefresh);
    on<CheckoutPlaceOrderPressed>(_onPlaceOrder);
  }

  List<CartLine> _linesFromCart(CheckoutCart cart) {
    return cart.items.where((x) => x.itemId != 0 && x.quantity > 0).map((x) {
      final effectiveUnit = (x.lineTotal > 0 && x.quantity > 0)
          ? (x.lineTotal / x.quantity)
          : x.unitPrice;

      return CartLine(
        itemId: x.itemId,
        quantity: x.quantity,
        unitPrice: effectiveUnit,
      );
    }).toList();
  }

  Future<void> _loadQuotesAndTax(
    CheckoutCart cart,
    CheckoutState s, {
    int? preferMethodId,
  }) async {
    final lines = _linesFromCart(cart);

    final quotes = await getShippingQuotes(
      ownerProjectId: ownerProjectId,
      address: s.address,
      lines: lines,
    );

    ShippingQuote? chosen;
    if (quotes.isNotEmpty) {
      chosen = quotes.firstWhere(
        (q) => q.methodId != null && q.methodId == preferMethodId,
        orElse: () => quotes.first,
      );
    }

    final tax = await previewTax(
      ownerProjectId: ownerProjectId,
      address: s.address,
      lines: lines,
      shippingTotal: chosen?.price ?? 0.0,
    );

    emit(
      s.copyWith(
        shippingQuotes: quotes,
        selectedShippingMethodId: chosen?.methodId,
        selectedQuote: chosen,
        tax: tax,
      ),
    );
  }

  Future<void> _onStarted(
    CheckoutStarted e,
    Emitter<CheckoutState> emit,
  ) async {
    emit(
      state.copyWith(
        loading: true,
        clearError: true,
        clearOrderId: true,
        clearOrderSummary: true,
      ),
    );

    try {
      final cart = await getCart();

      // ✅ DB only (no fallback CASH)
      final pms = await getPaymentMethods();

      // ✅ no default payment selection
      final prevIndex = state.selectedPaymentIndex;
      final nextIndex =
          (prevIndex != null && prevIndex >= 0 && prevIndex < pms.length)
          ? prevIndex
          : null;

      emit(
        state.copyWith(
          cart: cart,
          paymentMethods: pms,
          selectedPaymentIndex: nextIndex,
          loading: false,
          clearError: true,
        ),
      );

      final s = state;

      if (!cart.isEmpty) {
        await _loadQuotesAndTax(
          cart,
          s,
          preferMethodId: s.selectedShippingMethodId,
        );
      }
    } catch (err) {
      emit(state.copyWith(loading: false, error: err.toString()));
    }
  }

  Future<void> _onAddressChanged(
    CheckoutAddressChanged e,
    Emitter<CheckoutState> emit,
  ) async {
    emit(state.copyWith(address: e.address, clearError: true));

    final cart = state.cart;
    if (cart == null || cart.isEmpty) return;

    try {
      await _loadQuotesAndTax(
        cart,
        state,
        preferMethodId: state.selectedShippingMethodId,
      );
    } catch (err) {
      emit(state.copyWith(error: err.toString()));
    }
  }

  Future<void> _onShippingSelected(
    CheckoutShippingSelected e,
    Emitter<CheckoutState> emit,
  ) async {
    emit(
      state.copyWith(selectedShippingMethodId: e.methodId, clearError: true),
    );

    final cart = state.cart;
    if (cart == null || cart.isEmpty) return;

    try {
      await _loadQuotesAndTax(cart, state, preferMethodId: e.methodId);
    } catch (err) {
      emit(state.copyWith(error: err.toString()));
    }
  }

  void _onCouponChanged(CheckoutCouponChanged e, Emitter<CheckoutState> emit) {
    emit(state.copyWith(coupon: e.coupon, clearError: true));
  }

  void _onPaymentSelected(
    CheckoutPaymentSelected e,
    Emitter<CheckoutState> emit,
  ) {
    emit(state.copyWith(selectedPaymentIndex: e.index, clearError: true));
  }

  Future<void> _onRefresh(
    CheckoutRefreshRequested e,
    Emitter<CheckoutState> emit,
  ) async {
    final cart = state.cart;
    if (cart == null || cart.isEmpty) return;

    try {
      await _loadQuotesAndTax(
        cart,
        state,
        preferMethodId: state.selectedShippingMethodId,
      );
    } catch (err) {
      emit(state.copyWith(error: err.toString()));
    }
  }

  Future<void> _onPlaceOrder(
    CheckoutPlaceOrderPressed e,
    Emitter<CheckoutState> emit,
  ) async {
    final cart = state.cart;
    if (cart == null || cart.isEmpty) {
      emit(state.copyWith(error: 'Cart is empty'));
      return;
    }

    final idx = state.selectedPaymentIndex;
    if (idx == null || idx < 0 || idx >= state.paymentMethods.length) {
      emit(state.copyWith(error: 'Select a payment method'));
      return;
    }

    final pm = state.paymentMethods[idx].code.trim();
    if (pm.isEmpty) {
      emit(state.copyWith(error: 'Payment method code is missing'));
      return;
    }

    final addr = state.address;
    if (addr.countryId == null) {
      emit(state.copyWith(error: 'Select a country'));
      return;
    }
    if (addr.regionId == null) {
      emit(state.copyWith(error: 'Select a region'));
      return;
    }
    if ((addr.city ?? '').trim().isEmpty) {
      emit(state.copyWith(error: 'Enter city'));
      return;
    }
    if ((addr.postalCode ?? '').trim().isEmpty) {
      emit(state.copyWith(error: 'Enter postal code'));
      return;
    }

    final quote = state.selectedQuote;
    final shipId = quote?.methodId ?? state.selectedShippingMethodId;
    final shipName = quote?.methodName ?? 'Shipping';

    if (state.shippingQuotes.isNotEmpty && shipId == null) {
      emit(state.copyWith(error: 'Select a shipping method'));
      return;
    }
    if (shipId == null) {
      emit(state.copyWith(error: 'Shipping method is missing'));
      return;
    }

    emit(state.copyWith(placing: true, clearError: true));

    try {
      String? stripePaymentId;

      if (pm.toUpperCase() == 'STRIPE') {
        throw Exception('Stripe not wired yet');
      }

      final lines = _linesFromCart(cart);

      final summary = await placeOrder(
        currencyId: currencyId ?? 1,
        paymentMethod: pm,
        couponCode: state.coupon.trim().isEmpty ? null : state.coupon.trim(),
        stripePaymentId: stripePaymentId,
        shippingMethodId: shipId,
        shippingMethodName: shipName,
        shippingAddress: addr,
        lines: lines,
      );

      emit(
        state.copyWith(
          placing: false,
          orderId: summary.orderId,
          orderSummary: summary,
          clearError: true,
        ),
      );
    } catch (err) {
      emit(state.copyWith(placing: false, error: err.toString()));
    }
  }
}
