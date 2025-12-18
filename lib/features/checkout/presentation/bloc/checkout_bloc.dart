// lib/features/checkout/presentation/bloc/checkout_bloc.dart
import 'dart:convert';

import 'package:build4front/core/payments/stripe_payment_sheet.dart';
import 'package:build4front/features/checkout/data/services/checkout_api_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide PaymentMethod;

import 'package:build4front/core/config/env.dart';
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

  // -----------------------------
  // Helpers
  // -----------------------------

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

  double _itemsSubtotal(CheckoutCart cart) {
    return cart.items.fold<double>(0.0, (sum, it) => sum + (it.lineTotal));
  }

  double _safeTaxTotal(Object? taxObj) {
    if (taxObj == null) return 0.0;
    try {
      final t = taxObj as dynamic;

      final v1 = t.totalTax;
      if (v1 is num) return v1.toDouble();

      final v2 = t.taxTotal;
      if (v2 is num) return v2.toDouble();

      final v3 = t.total;
      if (v3 is num) return v3.toDouble();

      final v4 = t.amount;
      if (v4 is num) return v4.toDouble();

      return 0.0;
    } catch (_) {
      return 0.0;
    }
  }

  double _calcGrandTotal(CheckoutCart cart) {
    final subtotal = _itemsSubtotal(cart);
    final shipping = state.selectedQuote?.price ?? 0.0;
    final taxTotal = _safeTaxTotal(state.tax);
    return subtotal + shipping + taxTotal;
  }

  /// ✅ best-effort: get Map config from PaymentMethod without knowing exact field name
  Map<String, dynamic>? _extractConfigMap(PaymentMethod pm) {
    try {
      final d = pm as dynamic;

      final cfg =
          d.config ?? d.configJson ?? d.config_json ?? d.configMap ?? d.configJSON;

      if (cfg is Map) {
        return Map<String, dynamic>.from(cfg);
      }

      if (cfg is String && cfg.trim().startsWith('{')) {
        final decoded = jsonDecode(cfg);
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      }

      // sometimes backend returns "config_json" already decoded into "config"
      return null;
    } catch (_) {
      return null;
    }
  }

  String? _stripeAccountIdFromPaymentMethod(PaymentMethod pm) {
    final cfg = _extractConfigMap(pm);
    if (cfg == null) return null;

    final raw =
        cfg['stripeAccountId'] ??
        cfg['stripe_account_id'] ??
        cfg['accountId'] ??
        cfg['connectedAccountId'];

    final s = (raw ?? '').toString().trim();
    return s.isEmpty ? null : s;
  }

  /// ✅ fallback currency mapping until you wire GetCurrencyById inside this bloc
  /// (because backend needs currency code like "usd")
  String _currencyCodeFromId(int? id) {
    final cid = id ?? currencyId ?? int.tryParse(Env.currencyId);

    // Customize these IDs to match your DB.
    if (cid == 1) return 'usd'; // DOLLAR
    if (cid == 2) return 'eur';
    if (cid == 3) return 'gbp';

    return 'usd';
  }

  // -----------------------------
  // Load shipping + tax
  // -----------------------------
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

  // -----------------------------
  // Events
  // -----------------------------

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
      final pms = await getPaymentMethods();

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
      await _loadQuotesAndTax(cart, preferMethodId: state.selectedShippingMethodId);
    } catch (err) {
      emit(state.copyWith(error: err.toString()));
    }
  }

  Future<void> _onShippingSelected(
    CheckoutShippingSelected e,
    Emitter<CheckoutState> emit,
  ) async {
    emit(state.copyWith(selectedShippingMethodId: e.methodId, clearError: true));

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

  void _onPaymentSelected(CheckoutPaymentSelected e, Emitter<CheckoutState> emit) {
    emit(state.copyWith(selectedPaymentIndex: e.index, clearError: true));
  }

  Future<void> _onRefresh(
    CheckoutRefreshRequested e,
    Emitter<CheckoutState> emit,
  ) async {
    final cart = state.cart;
    if (cart == null || cart.isEmpty) return;

    try {
      await _loadQuotesAndTax(cart, preferMethodId: state.selectedShippingMethodId);
    } catch (err) {
      emit(state.copyWith(error: err.toString()));
    }
  }

  Future<void> _onPlaceOrder(
    CheckoutPlaceOrderPressed e,
    Emitter<CheckoutState> emit,
  ) async {
    // ✅ bloc-level spam guard (even if UI fires twice)
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

      // ✅ STRIPE FLOW (fixed contract)
      if (pmCode == 'STRIPE') {
        if (Env.stripePublishableKey.trim().isEmpty) {
          throw Exception('Stripe publishable key is missing');
        }

       // final stripeAccountId = _stripeAccountIdFromPaymentMethod(selectedPm);
        
        final stripeAccountId =
            _stripeAccountIdFromPaymentMethod(selectedPm) ??
            'acct_1SE4zQIqZeCbkulV'; // TEMP STATIC TEST
        if (stripeAccountId == null) {
          throw Exception(
            'Stripe not configured for this app (missing stripeAccountId in STRIPE config_json)',
          );
        }

        final currency = _currencyCodeFromId(currencyId);

        final grandTotal = _calcGrandTotal(cart);
        final priceToSend = double.parse(grandTotal.toStringAsFixed(2));

        final stripeApi = CheckoutApiService();



        final intent = await stripeApi.createIntent(
          price: priceToSend,
          currency: currency,
          stripeAccountId: stripeAccountId,
          metadata: {
            'ownerProjectId': ownerProjectId,
            'shippingMethodId': shipId,
            'coupon': state.coupon.trim(),
          },
        );

        final clientSecret = (intent['clientSecret'] ?? '').toString();
        final paymentIntentId = (intent['paymentIntentId'] ?? '').toString();

        if (clientSecret.isEmpty || paymentIntentId.isEmpty) {
          throw Exception('Stripe intent response missing clientSecret/paymentIntentId');
        }

        try {
          await StripePaymentSheet.pay(
            clientSecret: clientSecret,
            merchantName: Env.appName,
          );
        } on StripeException catch (se) {
          final msg = se.error.message ?? 'Stripe payment canceled';
          throw Exception(msg);
        }

        stripePaymentId = paymentIntentId; // ✅ pi_...
      }

      final lines = _linesFromCart(cart);

      final summary = await placeOrder(
        ownerProjectId: ownerProjectId,
        currencyId: (currencyId ?? int.tryParse(Env.currencyId) ?? 1),
        paymentMethod: pmCode,
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
