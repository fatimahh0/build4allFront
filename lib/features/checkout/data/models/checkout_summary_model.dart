class CheckoutSummaryModel {
  final int orderId;
  final String? orderDate;

  final double itemsSubtotal;
  final double shippingTotal;
  final double itemTaxTotal;
  final double shippingTaxTotal;
  final double grandTotal;

  final String currencyCode;
  final String currencySymbol;

  final List<CheckoutLineSummaryModel> lines;

  final String? couponCode;
  final double? couponDiscount;

  CheckoutSummaryModel({
    required this.orderId,
    required this.orderDate,
    required this.itemsSubtotal,
    required this.shippingTotal,
    required this.itemTaxTotal,
    required this.shippingTaxTotal,
    required this.grandTotal,
    required this.currencyCode,
    required this.currencySymbol,
    required this.lines,
    this.couponCode,
    this.couponDiscount,
  });

  CheckoutSummaryModel copyWith({
    List<CheckoutLineSummaryModel>? lines,
    String? couponCode,
    double? couponDiscount,
  }) {
    return CheckoutSummaryModel(
      orderId: orderId,
      orderDate: orderDate,
      itemsSubtotal: itemsSubtotal,
      shippingTotal: shippingTotal,
      itemTaxTotal: itemTaxTotal,
      shippingTaxTotal: shippingTaxTotal,
      grandTotal: grandTotal,
      currencyCode: currencyCode,
      currencySymbol: currencySymbol,
      lines: lines ?? this.lines,
      couponCode: couponCode ?? this.couponCode,
      couponDiscount: couponDiscount ?? this.couponDiscount,
    );
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  factory CheckoutSummaryModel.fromJson(Map<String, dynamic> json) {
    return CheckoutSummaryModel(
      orderId: (json['orderId'] as num).toInt(),
      orderDate: json['orderDate']?.toString(),
      itemsSubtotal: _toDouble(json['itemsSubtotal']),
      shippingTotal: _toDouble(json['shippingTotal']),
      itemTaxTotal: _toDouble(json['itemTaxTotal']),
      shippingTaxTotal: _toDouble(json['shippingTaxTotal']),
      grandTotal: _toDouble(json['grandTotal']),
      currencyCode: (json['currencyCode'] ?? '').toString(),
      currencySymbol: (json['currencySymbol'] ?? '').toString(),
      lines: (json['lines'] as List? ?? [])
          .map(
            (e) => CheckoutLineSummaryModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      couponCode: json['couponCode']?.toString(),
      couponDiscount: json['couponDiscount'] == null
          ? null
          : _toDouble(json['couponDiscount']),
    );
  }
}

class CheckoutLineSummaryModel {
  final int itemId;
  final String? itemName; // backend can send null
  final int quantity;
  final double unitPrice;

  // backend sends lineSubtotal
  final double lineSubtotal;

  CheckoutLineSummaryModel({
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.unitPrice,
    required this.lineSubtotal,
  });

  CheckoutLineSummaryModel copyWith({String? itemName, double? lineSubtotal}) {
    return CheckoutLineSummaryModel(
      itemId: itemId,
      itemName: itemName ?? this.itemName,
      quantity: quantity,
      unitPrice: unitPrice,
      lineSubtotal: lineSubtotal ?? this.lineSubtotal,
    );
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  factory CheckoutLineSummaryModel.fromJson(Map<String, dynamic> json) {
    return CheckoutLineSummaryModel(
      itemId: (json['itemId'] as num).toInt(),
      itemName: json['itemName']?.toString(),
      quantity: (json['quantity'] as num).toInt(),
      unitPrice: _toDouble(json['unitPrice']),
      lineSubtotal: _toDouble(json['lineSubtotal'] ?? json['lineTotal']),
    );
  }
}
