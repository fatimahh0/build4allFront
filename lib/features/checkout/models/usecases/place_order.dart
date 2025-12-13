import '../entities/checkout_entities.dart';
import '../repositories/checkout_repository.dart';

class PlaceOrder {
  final CheckoutRepository repo;
  PlaceOrder(this.repo);

  Future<int> call({
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
