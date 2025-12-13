import 'package:build4front/features/checkout/models/entities/checkout_entities.dart';

class CheckoutState {
  final bool loading;
  final bool placing;

  final CheckoutCart? cart;
  final ShippingAddress address;

  final List<PaymentMethod> paymentMethods;
  final String? selectedPaymentCode;

  final List<ShippingQuote> shippingQuotes;
  final int? selectedShippingMethodId;
  final ShippingQuote? selectedQuote;

  final TaxPreview? tax;
  final String coupon;

  final String? error;

  // ✅ success signal
  final int? orderId;

  const CheckoutState({
    required this.loading,
    required this.placing,
    required this.address,
    required this.paymentMethods,
    required this.shippingQuotes,
    required this.coupon,
    this.cart,
    this.selectedPaymentCode,
    this.selectedShippingMethodId,
    this.selectedQuote,
    this.tax,
    this.error,
    this.orderId,
  });

  factory CheckoutState.initial() => const CheckoutState(
    loading: true,
    placing: false,
    cart: null,
    address: ShippingAddress(),
    paymentMethods: [],
    selectedPaymentCode: null,
    shippingQuotes: [],
    selectedShippingMethodId: null,
    selectedQuote: null,
    tax: null,
    coupon: '',
    error: null,
    orderId: null,
  );

  CheckoutState copyWith({
    bool? loading,
    bool? placing,
    CheckoutCart? cart,
    ShippingAddress? address,
    List<PaymentMethod>? paymentMethods,
    String? selectedPaymentCode,
    List<ShippingQuote>? shippingQuotes,
    int? selectedShippingMethodId,
    ShippingQuote? selectedQuote,
    TaxPreview? tax,
    String? coupon,
    String? error,
    bool clearError = false,
    int? orderId,
    bool clearOrderId = false,
  }) {
    return CheckoutState(
      loading: loading ?? this.loading,
      placing: placing ?? this.placing,
      cart: cart ?? this.cart,
      address: address ?? this.address,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      selectedPaymentCode: selectedPaymentCode ?? this.selectedPaymentCode,
      shippingQuotes: shippingQuotes ?? this.shippingQuotes,
      selectedShippingMethodId:
          selectedShippingMethodId ?? this.selectedShippingMethodId,
      selectedQuote: selectedQuote ?? this.selectedQuote,
      tax: tax ?? this.tax,
      coupon: coupon ?? this.coupon,
      error: clearError ? null : (error ?? this.error),
      orderId: clearOrderId ? null : (orderId ?? this.orderId),
    );
  }
}
