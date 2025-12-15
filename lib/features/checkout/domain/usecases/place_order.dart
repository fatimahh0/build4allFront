import 'package:build4front/features/checkout/data/models/checkout_summary_model.dart';
import 'package:build4front/features/checkout/domain/repositories/checkout_repository.dart';
import 'package:build4front/features/checkout/domain/entities/checkout_entities.dart';


class PlaceOrder {
  final CheckoutRepository repo;
  PlaceOrder(this.repo);

  Future<CheckoutSummaryModel> call({
    required int currencyId,
    required String paymentMethod,
    String? stripePaymentId,
    String? couponCode,
    required int shippingMethodId,
    required String shippingMethodName,
    required ShippingAddress shippingAddress,
    required List<CartLine> lines,
  }) {
    return repo.checkout(
      currencyId: currencyId,
      paymentMethod: paymentMethod,
      stripePaymentId: stripePaymentId,
      couponCode: couponCode,
      shippingMethodId: shippingMethodId,
      shippingMethodName: shippingMethodName,
      shippingAddress: shippingAddress,
      lines: lines,
    );
  }
}
