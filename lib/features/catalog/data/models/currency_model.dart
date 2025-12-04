import '../../domain/entities/currency.dart';

class CurrencyModel {
  final int id;
  final String type;
  final String code;
  final String symbol;

  CurrencyModel({
    required this.id,
    required this.type,
    required this.code,
    required this.symbol,
  });

  factory CurrencyModel.fromJson(Map<String, dynamic> j) {
    // backend: CurrencyDTO or entity:
    // { "id": 1, "currencyType": "DOLLAR", "code": "USD", "symbol": "$" }
    return CurrencyModel(
      id: (j['id'] ?? 0) is int ? j['id'] as int : int.parse('${j['id']}'),
      type: (j['currencyType'] ?? j['type'] ?? '').toString(),
      code: (j['code'] ?? '').toString(),
      symbol: (j['symbol'] ?? '').toString(),
    );
  }

  Currency toEntity() =>
      Currency(id: id, type: type, code: code, symbol: symbol);
}
