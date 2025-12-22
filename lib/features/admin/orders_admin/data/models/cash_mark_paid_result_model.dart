class CashMarkPaidResult {
  final int orderId;
  final String provider;
  final String status;
  final double amount;
  final String currency;

  CashMarkPaidResult({
    required this.orderId,
    required this.provider,
    required this.status,
    required this.amount,
    required this.currency,
  });

  factory CashMarkPaidResult.fromJson(Map<String, dynamic> json) {
    double _d(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    return CashMarkPaidResult(
      orderId: (json['orderId'] as num).toInt(),
      provider: (json['provider'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      amount: _d(json['amount']),
      currency: (json['currency'] ?? '').toString(),
    );
  }
}
