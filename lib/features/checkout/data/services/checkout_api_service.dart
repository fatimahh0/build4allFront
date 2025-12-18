// lib/features/checkout/data/services/checkout_api_service.dart
import 'package:build4front/core/network/api_fetch.dart';
import 'package:build4front/core/network/api_methods.dart';

class CheckoutApiService {
  final ApiFetch _fetch = ApiFetch();

  Future<Map<String, dynamic>> getMyCart() async {
    final res = await _fetch.fetch(HttpMethod.get, '/api/cart');
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<List<dynamic>> getShippingQuotes(Map<String, dynamic> body) async {
    final res = await _fetch.fetch(
      HttpMethod.post,
      '/api/shipping/available-methods',
      data: body,
    );
    return (res.data as List? ?? []);
  }

  Future<Map<String, dynamic>> previewTax(Map<String, dynamic> body) async {
    final res = await _fetch.fetch(
      HttpMethod.post,
      '/api/tax/preview',
      data: body,
    );
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<List<dynamic>> getEnabledPaymentMethods() async {
    final res = await _fetch.fetch(
      HttpMethod.get,
      '/api/payment-methods/enabled',
    );
    return (res.data as List? ?? []);
  }

  Future<Map<String, dynamic>> checkout(Map<String, dynamic> body) async {
    final res = await _fetch.fetch(
      HttpMethod.post,
      '/api/orders/checkout',
      data: body,
    );
    return Map<String, dynamic>.from(res.data as Map);
  }

  /// backend expects: price, currency, stripeAccountId
 Future<Map<String, dynamic>> createIntent({
    required double price,
    required String currency, // "usd"
    required String stripeAccountId, // "acct_..."
    Map<String, dynamic>? metadata,
  }) async {
    final data = <String, dynamic>{
      'price': price,
      'currency': currency,
      'stripeAccountId': stripeAccountId,
      if (metadata != null) 'metadata': metadata,
    };

    final res = await _fetch.fetch(
      HttpMethod.post,
      '/api/payments/create-intent',
      data: data,
    );

    return Map<String, dynamic>.from(res.data as Map);
  }

}
