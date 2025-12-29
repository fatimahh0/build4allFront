class PaymentSummary {
  final double orderTotal;
  final double paidAmount;
  final double remainingAmount;
  final bool fullyPaid;
  final String paymentState; // PAID / PARTIAL / UNPAID

  const PaymentSummary({
    required this.orderTotal,
    required this.paidAmount,
    required this.remainingAmount,
    required this.fullyPaid,
    required this.paymentState,
  });
}

class OrderHeaderRow {
  final int id; // orderId
  final DateTime? orderDate;
  final double totalPrice;

  final String status; // PENDING...
  final String statusUi; // Pending...
  final int itemsCount;

  final bool fullyPaid;
  final PaymentSummary payment;

  // ✅ NEW from list API
  final String? phone;
  final String? addressLine;

  const OrderHeaderRow({
    required this.id,
    required this.orderDate,
    required this.totalPrice,
    required this.status,
    required this.statusUi,
    required this.itemsCount,
    required this.fullyPaid,
    required this.payment,
    this.phone,
    this.addressLine,
  });
}

class CurrencyMini {
  final String? code;
  final String? symbol;
  const CurrencyMini({this.code, this.symbol});
}

class UserMini {
  final int id;
  final String? username;
  final String? firstName;
  final String? lastName;

  const UserMini({
    required this.id,
    this.username,
    this.firstName,
    this.lastName,
  });

  String get fullName {
    final f = (firstName ?? '').trim();
    final l = (lastName ?? '').trim();
    final both = '$f $l'.trim();
    return both.isNotEmpty ? both : (username ?? '').trim();
  }
}

class ItemMiniDetails {
  final int id;
  final String itemName;
  final String? imageUrl;
  final String? location;
  final DateTime? startDatetime;

  const ItemMiniDetails({
    required this.id,
    required this.itemName,
    this.imageUrl,
    this.location,
    this.startDatetime,
  });
}

class OrderDetailsItem {
  final int orderItemId;
  final int quantity;
  final double price;
  final ItemMiniDetails item;
  final UserMini user;

  const OrderDetailsItem({
    required this.orderItemId,
    required this.quantity,
    required this.price,
    required this.item,
    required this.user,
  });
}

class OrderDetailsHeader {
  final int id;
  final DateTime? orderDate;
  final double totalPrice;

  final String status;
  final String statusUi;

  final String? paymentMethod;
  final CurrencyMini? currency;

  final String? shippingCity;
  final String? shippingPostalCode;

  // ✅ NEW
  final String? shippingPhone;
  final String? shippingAddress;

  final int? shippingMethodId;
  final String? shippingMethodName;
  final double? shippingTotal;
  final double? itemTaxTotal;
  final double? shippingTaxTotal;
  final String? couponCode;
  final double? couponDiscount;

  final bool fullyPaid;
  final PaymentSummary payment;

  const OrderDetailsHeader({
    required this.id,
    required this.orderDate,
    required this.totalPrice,
    required this.status,
    required this.statusUi,
    this.paymentMethod,
    this.currency,
    this.shippingCity,
    this.shippingPostalCode,
    this.shippingPhone,
    this.shippingAddress,
    this.shippingMethodId,
    this.shippingMethodName,
    this.shippingTotal,
    this.itemTaxTotal,
    this.shippingTaxTotal,
    this.couponCode,
    this.couponDiscount,
    required this.fullyPaid,
    required this.payment,
  });
}

class OrderDetailsResponse {
  final OrderDetailsHeader order;
  final int itemsCount;
  final List<OrderDetailsItem> items;

  const OrderDetailsResponse({
    required this.order,
    required this.itemsCount,
    required this.items,
  });
}
