class InvoiceData {
  final int orderId;
  final String orderCode;
  final String orderDateText;

  final String currencySymbol;

  final String paymentProvider;
  final String paymentStatus;
  final String providerReference;
  final String paymentMethod;

  final String customerName;
  final String customerPhone;
  final String customerEmail;

  final String addressLine;
  final String city;
  final String postalCode;
  final String shippingMethodName;

  final double itemsSubtotal;
  final double shippingTotal;
  final double itemTaxTotal;
  final double shippingTaxTotal;
  final String couponCode;
  final double couponDiscount;
  final double grandTotal;

  final List<InvoiceLineData> lines;

  const InvoiceData({
    required this.orderId,
    required this.orderCode,
    required this.orderDateText,
    required this.currencySymbol,
    required this.paymentProvider,
    required this.paymentStatus,
    required this.providerReference,
    required this.paymentMethod,
    required this.customerName,
    required this.customerPhone,
    required this.customerEmail,
    required this.addressLine,
    required this.city,
    required this.postalCode,
    required this.shippingMethodName,
    required this.itemsSubtotal,
    required this.shippingTotal,
    required this.itemTaxTotal,
    required this.shippingTaxTotal,
    required this.couponCode,
    required this.couponDiscount,
    required this.grandTotal,
    required this.lines,
  });
}

class InvoiceLineData {
  final String itemName;
  final int quantity;
  final double unitPrice;
  final double lineSubtotal;

  const InvoiceLineData({
    required this.itemName,
    required this.quantity,
    required this.unitPrice,
    required this.lineSubtotal,
  });
}