import 'package:build4front/features/checkout/data/models/checkout_summary_model.dart';

import '../entities/checkout_entities.dart';

abstract class CheckoutRepository {
  Future<CheckoutCart> getMyCart();

  Future<List<ShippingQuote>> getShippingQuotes({
    required int ownerProjectId,
    required ShippingAddress address,
    required List<CartLine> lines,
  });

  Future<TaxPreview> previewTax({
    required int ownerProjectId,
    required ShippingAddress address,
    required List<CartLine> lines,
    required double shippingTotal,
  });

  Future<List<PaymentMethod>> getEnabledPaymentMethods();

  Future<CheckoutSummaryModel> checkout({
    required int currencyId,
    required String paymentMethod,
    String? stripePaymentId,
    String? couponCode,
    required int shippingMethodId,
    required String shippingMethodName,
    required ShippingAddress shippingAddress,
    required List<CartLine> lines,
  });
}
