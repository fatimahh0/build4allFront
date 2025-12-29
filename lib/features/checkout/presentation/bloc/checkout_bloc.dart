import 'package:build4front/features/checkout/domain/usecases/get_last_shipping_address.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide PaymentMethod;

import 'package:build4front/core/config/env.dart';
import 'package:build4front/core/payments/stripe_payment_sheet.dart';

import 'package:build4front/features/checkout/data/models/checkout_summary_model.dart';
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
  final GetLastShippingAddress getLastShippingAddress;
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
    required this.getLastShippingAddress,

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

  String? _stripeAccountIdFromPaymentMethod(PaymentMethod pm) {
    final cfg = pm.configMap;
    if (cfg == null) return null;

    final raw = cfg['stripeAccountId'] ??
        cfg['stripe_account_id'] ??
        cfg['accountId'] ??
        cfg['connectedAccountId'] ??
        cfg['destinationAccountId'];

    final s = (raw ?? '').toString().trim();
    return s.isEmpty ? null : s;
  }

  Future<void> _loadQuotesAndTax(
    CheckoutCart cart, {
    int? preferMethodId,
  }) async {
    final lines = _linesFromCart(cart);

    final quotes = await getShippingQuotes(
      ownerProjectId: ownerProjectId,
      address: state.address,
      lines: lines,
    );

    ShippingQuote? chosen;
    if (quotes.isNotEmpty) {
      final pref = preferMethodId ?? state.selectedShippingMethodId;
      chosen = quotes.firstWhere(
        (q) => q.methodId != null && q.methodId == pref,
        orElse: () => quotes.first,
      );
    }

    final tax = await previewTax(
      ownerProjectId: ownerProjectId,
      address: state.address,
      lines: lines,
      shippingTotal: chosen?.price ?? 0.0,
    );

    emit(
      state.copyWith(
        shippingQuotes: quotes,
        selectedShippingMethodId: chosen?.methodId,
        selectedQuote: chosen,
        tax: tax,
        clearError: true,
      ),
    );
  }

  Future<void> _onStarted(
    CheckoutStarted e,
    Emitter<CheckoutState> emit,
  ) async {
    emit(state.copyWith(
      loading: true,
      clearError: true,
      clearOrderId: true,
      clearOrderSummary: true,
    ));

    try {
      final cart = await getCart();
      final pms = await getPaymentMethods();

      // ✅ NEW: prefill address from backend
      ShippingAddress lastAddr = const ShippingAddress();
      try {
        lastAddr = await getLastShippingAddress();
      } catch (_) {
        // ignore - keep empty
      }

      final prevIndex = state.selectedPaymentIndex;
      final nextIndex =
          (prevIndex != null && prevIndex >= 0 && prevIndex < pms.length)
              ? prevIndex
              : null;

      // ✅ IMPORTANT: emit address BEFORE quotes/tax
      emit(state.copyWith(
        cart: cart,
        paymentMethods: pms,
        selectedPaymentIndex: nextIndex,
        address: lastAddr,
        loading: false,
        clearError: true,
      ));

      if (!cart.isEmpty) {
        await _loadQuotesAndTax(
          cart,
          preferMethodId: state.selectedShippingMethodId,
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
        state.copyWith(selectedShippingMethodId: e.methodId, clearError: true));

    final cart = state.cart;
    if (cart == null || cart.isEmpty) return;

    try {
      await _loadQuotesAndTax(cart, preferMethodId: e.methodId);
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
    if (state.placing) return;

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

    final selectedPm = state.paymentMethods[idx];
    final pmCode = selectedPm.code.trim().toUpperCase();
    if (pmCode.isEmpty) {
      emit(state.copyWith(error: 'Payment method code is missing'));
      return;
    }

    final addr = state.address;

    // ✅ REQUIRED (as before)
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

    // ✅ NEW REQUIRED shipping fields (because backend added them)
    if ((addr.addressLine ?? '').trim().isEmpty) {
      emit(state.copyWith(error: 'Enter address'));
      return;
    }
    if ((addr.phone ?? '').trim().isEmpty) {
      emit(state.copyWith(error: 'Enter phone'));
      return;
    }

    // postalCode optional

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
      final lines = _linesFromCart(cart);

      final destinationAccountId = (pmCode == 'STRIPE')
          ? _stripeAccountIdFromPaymentMethod(selectedPm)
          : null;

      final CheckoutSummaryModel summary = await placeOrder(
        ownerProjectId: ownerProjectId,
        currencyId: (currencyId ?? int.tryParse(Env.currencyId) ?? 1),
        paymentMethod: pmCode,
        couponCode: state.coupon.trim().isEmpty ? null : state.coupon.trim(),
        stripePaymentId: null,
        destinationAccountId: destinationAccountId,
        shippingMethodId: shipId,
        shippingMethodName: shipName,
        shippingAddress: addr,
        lines: lines,
      );

      final provider = (summary.paymentProviderCode ?? pmCode)
          .toString()
          .trim()
          .toUpperCase();

      if (provider == 'STRIPE') {
        final clientSecret = (summary.clientSecret ?? '').toString().trim();
        final publishableKey = (summary.publishableKey ?? '').toString().trim();

        if (clientSecret.isEmpty) {
          throw Exception('Checkout did not return Stripe clientSecret');
        }
        if (publishableKey.isEmpty) {
          throw Exception(
              'Checkout did not return Stripe publishableKey (pk_...)');
        }

        try {
          await StripePaymentSheet.pay(
            publishableKey: publishableKey,
            clientSecret: clientSecret,
            merchantName: Env.appName,
          );
        } on StripeException catch (se) {
          final msg = se.error.message ?? 'Stripe payment canceled';
          throw Exception(msg);
        }
      }

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
