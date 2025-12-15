import 'package:build4front/core/network/api_fetch.dart';
import 'package:build4front/core/network/api_methods.dart';

class CheckoutApiService {
  final ApiFetch _fetch = ApiFetch();

  Future<Map<String, dynamic>> getMyCart() async {
    final res = await _fetch.fetch(HttpMethod.get, '/api/cart');
    return (res.data as Map<String, dynamic>);
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
    return (res.data as Map<String, dynamic>);
  }

  Future<List<dynamic>> getEnabledPaymentMethods() async {
    final res = await _fetch.fetch(
      HttpMethod.get,
      '/api/payment-methods/enabled',
    );
    return (res.data as List? ?? []);
  }

  // ✅ IMPORTANT: real endpoint you want
  Future<Map<String, dynamic>> checkout(Map<String, dynamic> body) async {
    final res = await _fetch.fetch(
      HttpMethod.post,
      '/api/orders/checkout',
      data: body,
    );
    return (res.data as Map<String, dynamic>);
  }


}
