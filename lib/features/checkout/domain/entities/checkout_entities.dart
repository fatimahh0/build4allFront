class CheckoutCart {
  final int cartId;
  final String status;
  final double totalPrice;
  final String? currencySymbol;
  final List<CheckoutCartItem> items;

  const CheckoutCart({
    required this.cartId,
    required this.status,
    required this.totalPrice,
    required this.items,
    this.currencySymbol,
  });

  bool get isEmpty => items.isEmpty;
}

class CheckoutCartItem {
  final int cartItemId;
  final int itemId;
  final String? itemName;
  final String? imageUrl;
  final int quantity;
  final double unitPrice;
  final double lineTotal;

  const CheckoutCartItem({
    required this.cartItemId,
    required this.itemId,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
    this.itemName,
    this.imageUrl,
  });
}

class CartLine {
  final int itemId;
  final int quantity;
  final double unitPrice;

  const CartLine({
    required this.itemId,
    required this.quantity,
    required this.unitPrice,
  });
}

class ShippingAddress {
  final int? countryId;
  final int? regionId;
  final String? city;
  final String? postalCode;

  const ShippingAddress({
    this.countryId,
    this.regionId,
    this.city,
    this.postalCode,
  });

  ShippingAddress copyWith({
    int? countryId,
    int? regionId,
    String? city,
    String? postalCode,
  }) {
    return ShippingAddress(
      countryId: countryId ?? this.countryId,
      regionId: regionId ?? this.regionId,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
    );
  }
}

class ShippingQuote {
  final int? methodId;
  final String methodName;
  final double price;
  final String? currencySymbol;

  const ShippingQuote({
    required this.methodName,
    required this.price,
    this.methodId,
    this.currencySymbol,
  });
}

class TaxPreview {
  final double itemsTaxTotal;
  final double shippingTaxTotal;
  final double totalTax;

  const TaxPreview({
    required this.itemsTaxTotal,
    required this.shippingTaxTotal,
    required this.totalTax,
  });
}

class PaymentMethod {
  final String code;
  final String name;

  const PaymentMethod({required this.code, required this.name});

  factory PaymentMethod.fromJson(Map<String, dynamic> j) {
    final nested = j['method'];

    String pick(dynamic v) => (v ?? '').toString().trim();

    final rawCode = pick(
      j['code'] ??
          j['methodCode'] ??
          j['paymentCode'] ??
          j['payment_method_code'] ??
          j['payment_method'] ??
          (nested is Map ? nested['code'] : null),
    );

    final rawName = pick(
      j['name'] ??
          j['label'] ??
          j['paymentName'] ??
          j['payment_method_name'] ??
          (nested is Map ? nested['name'] : null),
    );

    final code = rawCode.toUpperCase();
    final name = rawName.isEmpty ? (code.isEmpty ? 'Unknown' : code) : rawName;

    return PaymentMethod(code: code, name: name);
  }

  Map<String, dynamic> toJson() => {'code': code, 'name': name};

  PaymentMethod copyWith({String? code, String? name}) {
    return PaymentMethod(code: code ?? this.code, name: name ?? this.name);
  }
}
