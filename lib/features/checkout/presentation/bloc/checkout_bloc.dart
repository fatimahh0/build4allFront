// lib/features/checkout/presentation/bloc/checkout_bloc.dart
//
// CheckoutBloc
// ------------
// This bloc drives the whole Checkout flow:
// 1) Load cart + payment methods
// 2) Load shipping quotes + tax preview
// 3) Place order (POST /api/orders/checkout)
// 4) If provider == STRIPE -> backend returns:
//      - clientSecret (pi_..._secret_...)
//      - publishableKey (pk_...)
//    Then we initialize Stripe dynamically and show PaymentSheet.
//
// IMPORTANT (Multi-tenant Build4All):
// - We DO NOT read Stripe publishable key from Env anymore.
// - publishableKey is returned by backend per order/tenant,
//   so each ownerProject can have its own Stripe config safely.

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
  final PreviewTax previewTax;

  /// NEW backend flow:
  /// This calls POST /api/orders/checkout and returns CheckoutSummaryModel
  final PlaceOrder placeOrder;

  /// Tenant scope (generated app)
  final int ownerProjectId;

  /// Optional currency selection (fallback to Env.currencyId)
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

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Convert cart items into checkout lines for backend.
  /// We send: itemId, quantity, unitPrice (selling price).
  ///
  /// Why compute "effectiveUnit"?
  /// - Sometimes backend returns a lineTotal which already includes discounts.
  /// - To ensure backend and frontend are consistent, we compute unit = lineTotal/qty
  ///   if lineTotal exists; otherwise use unitPrice.
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

  /// Tax preview object type may vary (dynamic mapping).
  /// This function safely tries multiple field names.
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

  /// Stripe Connect destination account id (acct_...) can be stored in payment method config.
  /// Backend can store it under different keys; we try several.
  String? _stripeAccountIdFromPaymentMethod(PaymentMethod pm) {
    final cfg = pm.configMap;
    if (cfg == null) return null;

    final raw =
        cfg['stripeAccountId'] ??
        cfg['stripe_account_id'] ??
        cfg['accountId'] ??
        cfg['connectedAccountId'] ??
        cfg['destinationAccountId'];

    final s = (raw ?? '').toString().trim();
    return s.isEmpty ? null : s;
  }

  // ---------------------------------------------------------------------------
  // Load shipping quotes + tax preview (re-run when address/shipping changes)
  // ---------------------------------------------------------------------------

  Future<void> _loadQuotesAndTax(
    CheckoutCart cart, {
    int? preferMethodId,
  }) async {
    final lines = _linesFromCart(cart);

    // 1) Shipping quotes
    final quotes = await getShippingQuotes(
      ownerProjectId: ownerProjectId,
      address: state.address,
      lines: lines,
    );

    // Choose the preferred shipping method if available
    ShippingQuote? chosen;
    if (quotes.isNotEmpty) {
      final pref = preferMethodId ?? state.selectedShippingMethodId;
      chosen = quotes.firstWhere(
        (q) => q.methodId != null && q.methodId == pref,
        orElse: () => quotes.first,
      );
    }

    // 2) Tax preview (needs shipping total)
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

  // ---------------------------------------------------------------------------
  // Events
  // ---------------------------------------------------------------------------

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
      // Load cart and payment methods
      final cart = await getCart();
      final pms = await getPaymentMethods();

      // Keep previously selected payment index (if still valid)
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

      // Load shipping/tax if cart is not empty
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
      state.copyWith(selectedShippingMethodId: e.methodId, clearError: true),
    );

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

  // ---------------------------------------------------------------------------
  // ✅ NEW checkout + payment flow (backend orchestrated)
  // ---------------------------------------------------------------------------

  Future<void> _onPlaceOrder(
    CheckoutPlaceOrderPressed e,
    Emitter<CheckoutState> emit,
  ) async {
    // Prevent double clicks
    if (state.placing) return;

    final cart = state.cart;
    if (cart == null || cart.isEmpty) {
      emit(state.copyWith(error: 'Cart is empty'));
      return;
    }

    // Payment method validation
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

    // Shipping address validation (backend also validates)
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

    //  postalCode OPTIONAL: do not block checkout if empty
    // backend will receive null from the form when empty

    // Shipping method validation
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

    // ✅ IMPORTANT CHANGE:
    // We DO NOT validate Stripe publishableKey from Env anymore.
    // In multi-tenant mode, backend returns publishableKey (pk_...) per checkout order.
    // We validate pk_ AFTER we receive the checkout response.

    emit(state.copyWith(placing: true, clearError: true));

    try {
      // Build checkout lines
      final lines = _linesFromCart(cart);

      // Stripe Connect destination account (acct_...) if configured in PaymentMethod.configMap
      final destinationAccountId = (pmCode == 'STRIPE')
          ? _stripeAccountIdFromPaymentMethod(selectedPm)
          : null;

      // 1) Call backend checkout ONCE:
      //    - creates Order + OrderItems
      //    - starts payment session (Stripe PaymentIntent / etc.)
      //    - returns CheckoutSummaryModel including:
      //        clientSecret + publishableKey (Stripe)
      final CheckoutSummaryModel summary = await placeOrder(
        ownerProjectId: ownerProjectId,
        currencyId: (currencyId ?? int.tryParse(Env.currencyId) ?? 1),
        paymentMethod: pmCode,
        couponCode: state.coupon.trim().isEmpty ? null : state.coupon.trim(),

        // NEW flow: always null; backend creates/starts payment
        stripePaymentId: null,

        // Optional Stripe Connect
        destinationAccountId: destinationAccountId,

        // Shipping + address
        shippingMethodId: shipId,
        shippingMethodName: shipName,
        shippingAddress: addr,

        // Lines
        lines: lines,
      );

      // 2) Choose provider:
      // Backend uses paymentProviderCode. If missing, fallback to selected pmCode.
      final provider = (summary.paymentProviderCode ?? pmCode)
          .toString()
          .trim()
          .toUpperCase();

      if (provider == 'STRIPE') {
        // ✅ Stripe requires both clientSecret + publishableKey
        final clientSecret = (summary.clientSecret ?? '').toString().trim();
        final publishableKey = (summary.publishableKey ?? '').toString().trim();

        if (clientSecret.isEmpty) {
          throw Exception('Checkout did not return Stripe clientSecret');
        }
        if (publishableKey.isEmpty) {
          throw Exception(
            'Checkout did not return Stripe publishableKey (pk_...)',
          );
        }

        try {
          // ✅ Multi-tenant Stripe:
          // Apply publishable key dynamically (pk_...) then show PaymentSheet.
          await StripePaymentSheet.pay(
            publishableKey: publishableKey,
            clientSecret: clientSecret,
            merchantName: Env.appName,
          );
        } on StripeException catch (se) {
          // User canceled or payment failed
          final msg = se.error.message ?? 'Stripe payment canceled';
          throw Exception(msg);
        }
      }

      // PAYPAL: backend may return redirectUrl (not handled here to keep code minimal)
      // if (provider == 'PAYPAL') { launchUrl(summary.redirectUrl) ... }

      // CASH: no client action required

      // 3) Emit success -> UI can navigate to OrderDetails
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
