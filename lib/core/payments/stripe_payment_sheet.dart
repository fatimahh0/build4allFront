import 'package:flutter_stripe/flutter_stripe.dart';

class StripePaymentSheet {
  static Future<void> pay({
    required String clientSecret,
    String merchantName = 'Build4All',
  }) async {
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: merchantName,
      ),
    );

    await Stripe.instance.presentPaymentSheet();
  }
}
