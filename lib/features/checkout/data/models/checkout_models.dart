class CheckoutCartModel {
  final int cartId;
  final String status;
  final double totalPrice;
  final String? currencySymbol;
  final List<CheckoutCartItemModel> items;

  CheckoutCartModel({
    required this.cartId,
    required this.status,
    required this.totalPrice,
    required this.items,
    this.currencySymbol,
  });

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  factory CheckoutCartModel.fromJson(Map<String, dynamic> json) {
    return CheckoutCartModel(
      cartId: (json['cartId'] as num?)?.toInt() ?? 0,
      status: (json['status'] ?? '').toString(),
      totalPrice: _toDouble(json['totalPrice']),
      currencySymbol: json['currencySymbol']?.toString(),
      items: (json['items'] as List? ?? [])
          .map((e) => CheckoutCartItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class CheckoutCartItemModel {
  final int cartItemId;
  final int itemId;
  final String? itemName;
  final String? imageUrl;
  final int quantity;

  /// ✅ we will store the SELLING unit price here (if backend provides it)
  final double unitPrice;

  /// ✅ total for the line (should match selling * qty)
  final double lineTotal;

  CheckoutCartItemModel({
    required this.cartItemId,
    required this.itemId,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
    this.itemName,
    this.imageUrl,
  });

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  factory CheckoutCartItemModel.fromJson(Map<String, dynamic> json) {
    final qty = (json['quantity'] as num?)?.toInt() ?? 0;

    // base unit price (often original price)
    final baseUnit = _toDouble(json['unitPrice']);

    // ✅ try common “selling/effective” keys (depends on your backend)
    final effectiveUnit = _toDouble(
      json['effectiveUnitPrice'] ??
          json['sellingUnitPrice'] ??
          json['discountedUnitPrice'] ??
          json['finalUnitPrice'] ??
          json['displayUnitPrice'],
    );

    // choose selling if exists, else base
    final unit = (effectiveUnit > 0) ? effectiveUnit : baseUnit;

    // line total from backend (if provided)
    final backendLine = _toDouble(
      json['lineTotal'] ??
          json['lineSubtotal'] ??
          json['total'] ??
          json['subtotal'],
    );

    // if backend didn't send a correct line total, compute from unit*qty
    final computedLine = (backendLine > 0) ? backendLine : (unit * qty);

    return CheckoutCartItemModel(
      cartItemId: (json['cartItemId'] as num?)?.toInt() ?? 0,
      itemId: (json['itemId'] as num?)?.toInt() ?? 0,
      itemName: json['itemName']?.toString(),
      imageUrl: json['imageUrl']?.toString(),
      quantity: qty,
      unitPrice: unit,
      lineTotal: computedLine,
    );
  }
}

class ShippingQuoteModel {
  final int? methodId;
  final String methodName;
  final double price;
  final String? currencySymbol;

  ShippingQuoteModel({
    required this.methodName,
    required this.price,
    this.methodId,
    this.currencySymbol,
  });

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  factory ShippingQuoteModel.fromJson(Map<String, dynamic> json) {
    return ShippingQuoteModel(
      methodId: (json['methodId'] as num?)?.toInt(),
      methodName: (json['methodName'] ?? '').toString(),
      price: _toDouble(json['price']),
      currencySymbol: json['currencySymbol']?.toString(),
    );
  }
}

class TaxPreviewModel {
  final double itemsTaxTotal;
  final double shippingTaxTotal;
  final double totalTax;

  TaxPreviewModel({
    required this.itemsTaxTotal,
    required this.shippingTaxTotal,
    required this.totalTax,
  });

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  factory TaxPreviewModel.fromJson(Map<String, dynamic> json) {
    final items = _toDouble(json['itemsTaxTotal']);
    final ship = _toDouble(json['shippingTaxTotal']);
    final total = _toDouble(json['totalTax']);
    return TaxPreviewModel(
      itemsTaxTotal: items,
      shippingTaxTotal: ship,
      totalTax: total == 0 ? (items + ship) : total,
    );
  }
}

class PaymentMethodModel {
  final int? id;
  final String code; // we will use NAME as CODE
  final String name;
  final bool enabled;

  PaymentMethodModel({
    this.id,
    required this.code,
    required this.name,
    required this.enabled,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> j) {
    String pick(dynamic v) => (v ?? '').toString().trim();

    final name = pick(j['name'] ?? j['label']);
    final code = pick(
      j['code'] ?? j['paymentMethod'] ?? j['method'] ?? name,
    ).toUpperCase();

    final enabled = (j['enabled'] is bool) ? (j['enabled'] as bool) : true;

    return PaymentMethodModel(
      id: (j['id'] as num?)?.toInt(),
      name: name.isEmpty ? code : name,
      code: code.isEmpty ? name.toUpperCase() : code,
      enabled: enabled,
    );
  }
}
