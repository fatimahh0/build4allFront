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
}
