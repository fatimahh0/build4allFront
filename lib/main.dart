import 'package:build4front/debug/debug_config_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'package:build4front/app/app.dart';
import 'package:build4front/core/config/env.dart';
import 'package:build4front/core/network/globals.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  makeDefaultDio(Env.apiBaseUrl);

  try {
    if (Env.stripePublishableKey.isNotEmpty) {
      Stripe.publishableKey = Env.stripePublishableKey;
      await Stripe.instance.applySettings();
    } else {
      debugPrint("Stripe publishable key is missing (STRIPE_PUBLISHABLE_KEY).");
    }
  } catch (e) {
    debugPrint("Stripe init failed: $e");
  }

  runApp(const DebugConfigBanner(child: Build4AllFrontApp()));
}
