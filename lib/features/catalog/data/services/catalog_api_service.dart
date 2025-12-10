import 'package:dio/dio.dart';
import 'package:build4front/core/network/globals.dart' as g;

import '../models/country_model.dart';
import '../models/region_model.dart';

class CatalogApiService {
  final Dio _dio;

  CatalogApiService({Dio? dio}) : _dio = dio ?? g.dio();

  Options _opts(String? token) {
    if (token == null || token.trim().isEmpty) {
      return Options(); // no auth header
    }
    final normalized = token.startsWith('Bearer ') ? token : 'Bearer $token';
    return Options(headers: {'Authorization': normalized});
  }

  Future<List<CountryModel>> listCountries({String? authToken}) async {
    final res = await _dio.get('/api/countries', options: _opts(authToken));

    final data = (res.data as List?) ?? [];
    final list =
        data
            .map(
              (e) => CountryModel.fromJson((e as Map).cast<String, dynamic>()),
            )
            .where((c) => c.active)
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));

    return list;
  }

  Future<List<RegionModel>> listRegions({String? authToken}) async {
    final res = await _dio.get('/api/regions', options: _opts(authToken));

    final data = (res.data as List?) ?? [];
    final list =
        data
            .map(
              (e) => RegionModel.fromJson((e as Map).cast<String, dynamic>()),
            )
            .where((r) => r.active)
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));

    return list;
  }
}
