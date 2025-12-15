import 'package:build4front/features/checkout/data/repositories/checkout_repository_impl.dart';
import 'package:build4front/features/checkout/data/services/checkout_api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4front/core/config/app_config.dart';
import 'package:build4front/core/config/env.dart';

import 'package:build4front/features/checkout/domain/repositories/checkout_repository.dart';


import 'package:build4front/features/checkout/domain/usecases/get_checkout_cart.dart';
import 'package:build4front/features/checkout/domain/usecases/get_payment_methods.dart';
import 'package:build4front/features/checkout/domain/usecases/get_shipping_quotes.dart';
import 'package:build4front/features/checkout/domain/usecases/preview_tax.dart';
import 'package:build4front/features/checkout/domain/usecases/place_order.dart';

import '../bloc/checkout_bloc.dart';
import 'checkout_screen.dart';

class CheckoutPage extends StatelessWidget {
  final AppConfig appConfig;
  final int? ownerProjectId;

  const CheckoutPage({super.key, required this.appConfig, this.ownerProjectId});

  @override
  Widget build(BuildContext context) {
    // fallback to Env if not passed
    final int ownerId =
        ownerProjectId ?? (int.tryParse(Env.ownerProjectLinkId) ?? 0);

    final int? currencyId = int.tryParse(Env.currencyId);

    // Data layer
    final CheckoutApiService api = CheckoutApiService();
    final CheckoutRepository repo = CheckoutRepositoryImpl(api);

    // Domain/usecases
    final getCart = GetCheckoutCart(repo);
    final getPms = GetPaymentMethods(repo);
    final getQuotes = GetShippingQuotes(repo);
    final tax = PreviewTax(repo);
    final place = PlaceOrder(repo);

    return BlocProvider(
      create: (_) => CheckoutBloc(
        getCart: getCart,
        getPaymentMethods: getPms,
        getShippingQuotes: getQuotes,
        previewTax: tax,
        placeOrder: place,
        ownerProjectId: ownerId,
        currencyId: currencyId,
      ),
      child: CheckoutScreen(appConfig: appConfig, ownerProjectId: ownerId),
    );
  }
}
