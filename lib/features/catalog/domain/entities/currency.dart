class Currency {
  final int id;
  final String type; // "DOLLAR", "EURO", "CAD"...
  final String code; // "USD", "EUR", "CAD"...
  final String symbol; // "$", "€", "C$"

  const Currency({
    required this.id,
    required this.type,
    required this.code,
    required this.symbol,
  });
}
