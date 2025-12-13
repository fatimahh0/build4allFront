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

  factory CheckoutCartModel.fromJson(Map<String, dynamic> json) {
    return CheckoutCartModel(
      cartId: (json['cartId'] as num?)?.toInt() ?? 0,
      status: (json['status'] ?? '').toString(),
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
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
  final double unitPrice;
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

  factory CheckoutCartItemModel.fromJson(Map<String, dynamic> json) {
    final qty = (json['quantity'] as num?)?.toInt() ?? 0;
    final unit = (json['unitPrice'] as num?)?.toDouble() ?? 0.0;

    return CheckoutCartItemModel(
      cartItemId: (json['cartItemId'] as num?)?.toInt() ?? 0,
      itemId: (json['itemId'] as num?)?.toInt() ?? 0,
      itemName: json['itemName']?.toString(),
      imageUrl: json['imageUrl']?.toString(),
      quantity: qty,
      unitPrice: unit,
      lineTotal: (json['lineTotal'] as num?)?.toDouble() ?? (unit * qty),
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

  factory ShippingQuoteModel.fromJson(Map<String, dynamic> json) {
    return ShippingQuoteModel(
      methodId: (json['methodId'] as num?)?.toInt(),
      methodName: (json['methodName'] ?? '').toString(),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
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

  factory TaxPreviewModel.fromJson(Map<String, dynamic> json) {
    final items = (json['itemsTaxTotal'] as num?)?.toDouble() ?? 0.0;
    final ship = (json['shippingTaxTotal'] as num?)?.toDouble() ?? 0.0;
    final total = (json['totalTax'] as num?)?.toDouble() ?? (items + ship);
    return TaxPreviewModel(
      itemsTaxTotal: items,
      shippingTaxTotal: ship,
      totalTax: total,
    );
  }
}

class PaymentMethodModel {
  final String code;
  final String name;

  PaymentMethodModel({required this.code, required this.name});

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    final code = (json['code'] ?? json['paymentMethod'] ?? json['method'] ?? '')
        .toString();
    final name = (json['name'] ?? json['label'] ?? code).toString();
    return PaymentMethodModel(code: code, name: name);
  }
}
