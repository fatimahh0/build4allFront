import 'package:build4front/features/checkout/domain/entities/checkout_entities.dart';

abstract class CheckoutEvent {
  const CheckoutEvent();
}

class CheckoutStarted extends CheckoutEvent {
  const CheckoutStarted();
}

class CheckoutAddressChanged extends CheckoutEvent {
  final ShippingAddress address;
  const CheckoutAddressChanged(this.address);
}

class CheckoutShippingSelected extends CheckoutEvent {
  final int? methodId;
  const CheckoutShippingSelected(this.methodId);
}

class CheckoutCouponChanged extends CheckoutEvent {
  final String coupon;
  const CheckoutCouponChanged(this.coupon);
}

class CheckoutPaymentSelected extends CheckoutEvent {
  final int index; // ✅ index not code
  const CheckoutPaymentSelected(this.index);
}

class CheckoutRefreshRequested extends CheckoutEvent {
  const CheckoutRefreshRequested();
}

class CheckoutPlaceOrderPressed extends CheckoutEvent {
  const CheckoutPlaceOrderPressed();
}
