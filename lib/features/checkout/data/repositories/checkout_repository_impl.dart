import 'package:build4front/features/checkout/models/entities/checkout_entities.dart';
import 'package:build4front/features/checkout/models/repositories/checkout_repository.dart';

import '../services/checkout_api_service.dart';
import '../models/checkout_models.dart';

class CheckoutRepositoryImpl implements CheckoutRepository {
  final CheckoutApiService api;
  CheckoutRepositoryImpl(this.api);

  @override
  Future<CheckoutCart> getMyCart() async {
    final json = await api.getMyCart();
    final model = CheckoutCartModel.fromJson(json);

    return CheckoutCart(
      cartId: model.cartId,
      status: model.status,
      totalPrice: model.totalPrice,
      currencySymbol: model.currencySymbol,
      items: model.items
          .map(
            (i) => CheckoutCartItem(
              cartItemId: i.cartItemId,
              itemId: i.itemId,
              itemName: i.itemName,
              imageUrl: i.imageUrl,
              quantity: i.quantity,
              unitPrice: i.unitPrice,
              lineTotal: i.lineTotal,
            ),
          )
          .toList(),
    );
  }

  // ✅ Your ShippingAddress does NOT have shippingMethodId
  // So we only serialize the fields that exist.
  Map<String, dynamic> _addressToJson(ShippingAddress a) => {
    'countryId': a.countryId,
    'regionId': a.regionId,
    'city': a.city,
    'postalCode': a.postalCode,
  };

  Map<String, dynamic> _lineToJson(CartLine l) => {
    'itemId': l.itemId,
    'quantity': l.quantity,
    'unitPrice': l.unitPrice,
  };

  @override
  Future<List<ShippingQuote>> getShippingQuotes({
    required int ownerProjectId,
    required ShippingAddress address,
    required List<CartLine> lines,
  }) async {
    final body = {
      'ownerProjectId': ownerProjectId,
      'address': _addressToJson(address),
      'lines': lines.map(_lineToJson).toList(),
    };

    final list = await api.getShippingQuotes(body);

    return list
        .map((e) => ShippingQuoteModel.fromJson(e as Map<String, dynamic>))
        .map(
          (m) => ShippingQuote(
            methodId: m.methodId,
            methodName: m.methodName,
            price: m.price,
            currencySymbol: m.currencySymbol,
          ),
        )
        .toList();
  }

  @override
  Future<TaxPreview> previewTax({
    required int ownerProjectId,
    required ShippingAddress address,
    required List<CartLine> lines,
    required double shippingTotal,
  }) async {
    final body = {
      'ownerProjectId': ownerProjectId,
      'address': _addressToJson(address),
      'lines': lines.map(_lineToJson).toList(),
      'shippingTotal': shippingTotal,
    };

    final json = await api.previewTax(body);
    final model = TaxPreviewModel.fromJson(json);

    return TaxPreview(
      itemsTaxTotal: model.itemsTaxTotal,
      shippingTaxTotal: model.shippingTaxTotal,
      totalTax: model.totalTax,
    );
  }

  @override
  Future<List<PaymentMethod>> getEnabledPaymentMethods() async {
    final list = await api.getEnabledPaymentMethods();
    return list
        .map((e) => PaymentMethodModel.fromJson(e as Map<String, dynamic>))
        .map((m) => PaymentMethod(code: m.code, name: m.name))
        .toList();
  }

  @override
  Future<int> checkout({
    required int currencyId,
    required String paymentMethod,
    String? stripePaymentId,
    String? couponCode,
    required int shippingMethodId,
    required String shippingMethodName,
    required ShippingAddress shippingAddress,
    required List<CartLine> lines,
  }) async {
    final body = <String, dynamic>{
      'currencyId': currencyId,
      'paymentMethod': paymentMethod,

      // ✅ backend needs this at root
      'shippingMethodId': shippingMethodId,

      // ✅ backend needs this inside shippingAddress too (based on your Postman/log)
      'shippingAddress': {
        ..._addressToJson(shippingAddress),
        'shippingMethodId': shippingMethodId,
        'shippingMethodName': shippingMethodName,
      },

      'lines': lines.map(_lineToJson).toList(),
    };

    final c = (couponCode ?? '').trim();
    if (c.isNotEmpty) body['couponCode'] = c;

    final s = (stripePaymentId ?? '').trim();
    if (s.isNotEmpty) body['stripePaymentId'] = s;

    final json = await api.checkout(body);

    final rawId = (json['orderId'] ?? json['id']);
    return (rawId as num).toInt();
  }
}
