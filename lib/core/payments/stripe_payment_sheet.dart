// lib/core/payments/stripe_payment_sheet.dart
//
// Stripe PaymentSheet helper.
//
// Why we do it this way:
// - In multi-tenant Build4All, each ownerProject can have its own Stripe keys.
// - Backend returns publishableKey (pk_...) and clientSecret per checkout.
// - So we initialize Stripe right before presenting the PaymentSheet.

import 'package:flutter_stripe/flutter_stripe.dart';

class StripePaymentSheet {
  static String? _lastPk; // remember the last applied pk_ to avoid redundant applySettings()

  static Future<void> pay({
    required String publishableKey,
    required String clientSecret,
    required String merchantName,
  }) async {
    final pk = publishableKey.trim();
    final cs = clientSecret.trim();

    if (pk.isEmpty) {
      throw Exception('Stripe publishableKey is missing (pk_...)');
    }
    if (cs.isEmpty) {
      throw Exception('Stripe clientSecret is missing');
    }

    // ✅ Multi-tenant: update Stripe publishable key if it changed.
    if (_lastPk != pk) {
      Stripe.publishableKey = pk;
      await Stripe.instance.applySettings();
      _lastPk = pk;
    }

    // 1) Init PaymentSheet with PaymentIntent client secret
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: cs,
        merchantDisplayName: merchantName,
      ),
    );

    // 2) Present PaymentSheet
    await Stripe.instance.presentPaymentSheet();
  }
}
