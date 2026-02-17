import 'dart:collection';

import 'package:build4front/features/catalog/data/services/currency_api_service.dart';

class CurrencySymbolCache {
  final CurrencyApiService api;
  final Future<String?> Function() getToken;

  final Map<int, String> _symbolById = {};

  CurrencySymbolCache({
    required this.api,
    required this.getToken,
  });

  Map<int, String> get snapshot => UnmodifiableMapView(_symbolById);

  Future<String?> getSymbol(int id) async {
    if (id <= 0) return null;

    final cached = _symbolById[id];
    if (cached != null && cached.trim().isNotEmpty) return cached;

    final token = await getToken();
    if (token == null || token.trim().isEmpty) return null;

    final data = await api.getCurrencyById(id, authToken: token);
    final sym = (data['symbol'] ?? '').toString().trim();

    if (sym.isNotEmpty) _symbolById[id] = sym;
    return sym.isNotEmpty ? sym : null;
  }

  Future<void> warmUp(Iterable<int> ids) async {
    for (final id in ids.toSet()) {
      await getSymbol(id);
    }
  }
}
