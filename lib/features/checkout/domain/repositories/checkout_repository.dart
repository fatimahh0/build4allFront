import 'package:build4front/features/checkout/data/models/checkout_summary_model.dart';
import '../entities/checkout_entities.dart';

abstract class CheckoutRepository {
  Future<CheckoutCart> getMyCart();
  Future<List<PaymentMethod>> getEnabledPaymentMethods();

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

  /// ✅ UPDATED:
  /// destinationAccountId is optional and used only for Stripe Connect.
  Future<CheckoutSummaryModel> checkout({
    required int ownerProjectId,
    required int currencyId,
    required String paymentMethod,

    /// OLD flow field (keep optional for backward compatibility, but NEW flow sends null)
    String? stripePaymentId,

    String? couponCode,
    required int shippingMethodId,
    required String shippingMethodName,
    required ShippingAddress shippingAddress,
    required List<CartLine> lines,

    /// ✅ NEW: Stripe Connect destination account (acct_...)
    String? destinationAccountId,
  });
}
