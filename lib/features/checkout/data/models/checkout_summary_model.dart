// lib/features/checkout/data/models/checkout_summary_model.dart
//
// Checkout response returned by backend from POST /api/orders/checkout
//
// NEW FLOW (backend orchestrated):
// Backend returns:
// - paymentProviderCode (STRIPE/PAYPAL/CASH)
// - clientSecret (Stripe)
// - publishableKey (Stripe pk_...)
// - redirectUrl (PayPal)
// - paymentStatus
//
// We must parse these fields so CheckoutBloc can use them.

class CheckoutSummaryModel {
  final int orderId;
  final String? orderDate;

  final double itemsSubtotal;
  final double shippingTotal;
  final double itemTaxTotal;
  final double shippingTaxTotal;
  final double grandTotal;

  final String currencyCode;
  final String currencySymbol;

  final List<CheckoutLineSummaryModel> lines;

  final String? couponCode;
  final double? couponDiscount;

  // ✅ Payment fields returned by backend
  final int? paymentTransactionId;
  final String? paymentProviderCode; // STRIPE / PAYPAL / CASH
  final String? providerPaymentId;   // Stripe: pi_...
  final String? clientSecret;        // Stripe: pi_..._secret_...
  final String? publishableKey;      // ✅ Stripe: pk_...
  final String? redirectUrl;         // PayPal approval URL
  final String? paymentStatus;       // REQUIRES_PAYMENT_METHOD / PAID / ...

  CheckoutSummaryModel({
    required this.orderId,
    required this.orderDate,
    required this.itemsSubtotal,
    required this.shippingTotal,
    required this.itemTaxTotal,
    required this.shippingTaxTotal,
    required this.grandTotal,
    required this.currencyCode,
    required this.currencySymbol,
    required this.lines,
    this.couponCode,
    this.couponDiscount,
    this.paymentTransactionId,
    this.paymentProviderCode,
    this.providerPaymentId,
    this.clientSecret,
    this.publishableKey,
    this.redirectUrl,
    this.paymentStatus,
  });

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  static int? _toIntOrNull(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  factory CheckoutSummaryModel.fromJson(Map<String, dynamic> json) {
    return CheckoutSummaryModel(
      orderId: (json['orderId'] as num?)?.toInt() ?? 0,
      orderDate: json['orderDate']?.toString(),

      itemsSubtotal: _toDouble(json['itemsSubtotal']),
      shippingTotal: _toDouble(json['shippingTotal']),
      itemTaxTotal: _toDouble(json['itemTaxTotal']),
      shippingTaxTotal: _toDouble(json['shippingTaxTotal']),
      grandTotal: _toDouble(json['grandTotal']),

      currencyCode: (json['currencyCode'] ?? '').toString(),
      currencySymbol: (json['currencySymbol'] ?? '').toString(),

      lines: (json['lines'] as List? ?? [])
          .whereType<Map>()
          .map((e) => CheckoutLineSummaryModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),

      couponCode: json['couponCode']?.toString(),
      couponDiscount: json['couponDiscount'] == null ? null : _toDouble(json['couponDiscount']),

      // ✅ Payment mapping (matches your backend JSON)
      paymentTransactionId: _toIntOrNull(json['paymentTransactionId']),
      paymentProviderCode: (json['paymentProviderCode'] ?? json['providerCode'] ?? json['paymentMethod'])
          ?.toString(),
      providerPaymentId: (json['providerPaymentId'] ?? json['paymentIntentId'])?.toString(),
      clientSecret: (json['clientSecret'] ?? json['paymentIntentClientSecret'])?.toString(),

      // ✅ THIS is what you want (read pk_ from API)
      publishableKey: (json['publishableKey'] ?? json['stripePublishableKey'])?.toString(),

      redirectUrl: (json['redirectUrl'] ?? json['approvalUrl'])?.toString(),
      paymentStatus: (json['paymentStatus'] ?? json['status'])?.toString(),
    );
  }
}

class CheckoutLineSummaryModel {
  final int itemId;
  final String? itemName;
  final int quantity;
  final double unitPrice;

  // backend sends lineSubtotal (or lineTotal)
  final double lineSubtotal;

  CheckoutLineSummaryModel({
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.unitPrice,
    required this.lineSubtotal,
  });

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  factory CheckoutLineSummaryModel.fromJson(Map<String, dynamic> json) {
    return CheckoutLineSummaryModel(
      itemId: (json['itemId'] as num?)?.toInt() ?? 0,
      itemName: json['itemName']?.toString(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      unitPrice: _toDouble(json['unitPrice']),
      lineSubtotal: _toDouble(json['lineSubtotal'] ?? json['lineTotal']),
    );
  }
}
