import 'package:build4front/features/checkout/data/models/checkout_summary_model.dart';
import 'package:build4front/features/checkout/domain/entities/checkout_entities.dart';

class CheckoutState {
  final bool loading;
  final bool placing;

  final CheckoutCart? cart;

  final ShippingAddress address;

  final List<ShippingQuote> shippingQuotes;
  final int? selectedShippingMethodId;
  final ShippingQuote? selectedQuote;

  final TaxPreview? tax;

  final List<PaymentMethod> paymentMethods;
  final int? selectedPaymentIndex; // ✅ index

  final String coupon;

  final String? error;

  final int? orderId;
  final CheckoutSummaryModel? orderSummary;

  const CheckoutState({
    required this.loading,
    required this.placing,
    required this.cart,
    required this.address,
    required this.shippingQuotes,
    required this.selectedShippingMethodId,
    required this.selectedQuote,
    required this.tax,
    required this.paymentMethods,
    required this.selectedPaymentIndex,
    required this.coupon,
    required this.error,
    required this.orderId,
    required this.orderSummary,
  });

  factory CheckoutState.initial() {
    return CheckoutState(
      loading: false,
      placing: false,
      cart: null,
      address: const ShippingAddress(),
      shippingQuotes: const [],
      selectedShippingMethodId: null,
      selectedQuote: null,
      tax: null,
      paymentMethods: const [],
      selectedPaymentIndex: null, // ✅ no default
      coupon: '',
      error: null,
      orderId: null,
      orderSummary: null,
    );
  }

  CheckoutState copyWith({
    bool? loading,
    bool? placing,
    CheckoutCart? cart,
    ShippingAddress? address,
    List<ShippingQuote>? shippingQuotes,
    int? selectedShippingMethodId,
    ShippingQuote? selectedQuote,
    TaxPreview? tax,
    List<PaymentMethod>? paymentMethods,
    int? selectedPaymentIndex,
    String? coupon,
    String? error,
    bool clearError = false,
    int? orderId,
    bool clearOrderId = false,
    CheckoutSummaryModel? orderSummary,
    bool clearOrderSummary = false,
  }) {
    return CheckoutState(
      loading: loading ?? this.loading,
      placing: placing ?? this.placing,
      cart: cart ?? this.cart,
      address: address ?? this.address,
      shippingQuotes: shippingQuotes ?? this.shippingQuotes,
      selectedShippingMethodId:
          selectedShippingMethodId ?? this.selectedShippingMethodId,
      selectedQuote: selectedQuote ?? this.selectedQuote,
      tax: tax ?? this.tax,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      selectedPaymentIndex: selectedPaymentIndex ?? this.selectedPaymentIndex,
      coupon: coupon ?? this.coupon,
      error: clearError ? null : (error ?? this.error),
      orderId: clearOrderId ? null : (orderId ?? this.orderId),
      orderSummary: clearOrderSummary
          ? null
          : (orderSummary ?? this.orderSummary),
    );
  }
}
