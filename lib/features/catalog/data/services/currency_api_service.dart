import 'package:build4front/core/network/api_fetch.dart';
import 'package:build4front/core/network/api_methods.dart' show HttpMethod;
import 'package:build4front/core/exceptions/app_exception.dart';
import 'package:build4front/core/exceptions/network_exception.dart';

class CurrencyApiService {
  final ApiFetch _fetch;

  CurrencyApiService({ApiFetch? fetch}) : _fetch = fetch ?? ApiFetch();

  static const String _base = '/api/currencies';

  Future<Map<String, dynamic>> getCurrencyById(int id) async {
    try {
      final r = await _fetch.fetch(HttpMethod.get, '$_base/$id');
      return _asMap(r.data);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to load currency by id', original: e);
    }
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    throw ServerException(
      'Invalid response format for currency',
      statusCode: 200,
    );
  }
}
