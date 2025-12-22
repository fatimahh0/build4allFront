import '../../domain/entities/admin_order_entities.dart';

DateTime? _tryParseDate(dynamic v) {
  if (v == null) return null;
  if (v is String && v.trim().isNotEmpty) return DateTime.tryParse(v);
  return null;
}

double _toDouble(dynamic v) {
  if (v == null) return 0.0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0.0;
}

int _toInt(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? 0;
}

class PaymentSummaryModel {
  final double orderTotal;
  final double paidAmount;
  final double remainingAmount;
  final bool fullyPaid;
  final String paymentState;

  PaymentSummaryModel({
    required this.orderTotal,
    required this.paidAmount,
    required this.remainingAmount,
    required this.fullyPaid,
    required this.paymentState,
  });

  factory PaymentSummaryModel.fromJson(Map<String, dynamic> json) {
    return PaymentSummaryModel(
      orderTotal: _toDouble(json['orderTotal']),
      paidAmount: _toDouble(json['paidAmount']),
      remainingAmount: _toDouble(json['remainingAmount']),
      fullyPaid: json['fullyPaid'] == true,
      paymentState: (json['paymentState'] ?? '').toString(),
    );
  }

  PaymentSummary toEntity() => PaymentSummary(
    orderTotal: orderTotal,
    paidAmount: paidAmount,
    remainingAmount: remainingAmount,
    fullyPaid: fullyPaid,
    paymentState: paymentState,
  );
}

class OrderHeaderRowModel {
  final int id;
  final DateTime? orderDate;
  final double totalPrice;
  final String status;
  final String statusUi;
  final int itemsCount;
  final bool fullyPaid;
  final PaymentSummaryModel payment;

  OrderHeaderRowModel({
    required this.id,
    required this.orderDate,
    required this.totalPrice,
    required this.status,
    required this.statusUi,
    required this.itemsCount,
    required this.fullyPaid,
    required this.payment,
  });

  factory OrderHeaderRowModel.fromJson(Map<String, dynamic> json) {
    return OrderHeaderRowModel(
      id: _toInt(json['id']),
      orderDate: _tryParseDate(json['orderDate']),
      totalPrice: _toDouble(json['totalPrice']),
      status: (json['status'] ?? '').toString(),
      statusUi: (json['statusUi'] ?? '').toString(),
      itemsCount: _toInt(json['itemsCount']),
      fullyPaid: json['fullyPaid'] == true,
      payment: PaymentSummaryModel.fromJson(
        (json['payment'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
    );
  }

  OrderHeaderRow toEntity() => OrderHeaderRow(
    id: id,
    orderDate: orderDate,
    totalPrice: totalPrice,
    status: status,
    statusUi: statusUi,
    itemsCount: itemsCount,
    fullyPaid: fullyPaid,
    payment: payment.toEntity(),
  );
}

class CurrencyMiniModel {
  final String? code;
  final String? symbol;

  CurrencyMiniModel({this.code, this.symbol});

  factory CurrencyMiniModel.fromJson(Map<String, dynamic> json) {
    return CurrencyMiniModel(
      code: json['code']?.toString(),
      symbol: json['symbol']?.toString(),
    );
  }

  CurrencyMini toEntity() => CurrencyMini(code: code, symbol: symbol);
}

class UserMiniModel {
  final int id;
  final String? username;
  final String? firstName;
  final String? lastName;

  UserMiniModel({
    required this.id,
    this.username,
    this.firstName,
    this.lastName,
  });

  factory UserMiniModel.fromJson(Map<String, dynamic> json) {
    return UserMiniModel(
      id: _toInt(json['id']),
      username: json['username']?.toString(),
      firstName: json['firstName']?.toString(),
      lastName: json['lastName']?.toString(),
    );
  }

  UserMini toEntity() => UserMini(
    id: id,
    username: username,
    firstName: firstName,
    lastName: lastName,
  );
}

class ItemMiniDetailsModel {
  final int id;
  final String itemName;
  final String? imageUrl;
  final String? location;
  final DateTime? startDatetime;

  ItemMiniDetailsModel({
    required this.id,
    required this.itemName,
    this.imageUrl,
    this.location,
    this.startDatetime,
  });

  factory ItemMiniDetailsModel.fromJson(Map<String, dynamic> json) {
    return ItemMiniDetailsModel(
      id: _toInt(json['id']),
      itemName: (json['itemName'] ?? '').toString(),
      imageUrl: json['imageUrl']?.toString(),
      location: json['location']?.toString(),
      startDatetime: _tryParseDate(json['startDatetime']),
    );
  }

  ItemMiniDetails toEntity() => ItemMiniDetails(
    id: id,
    itemName: itemName,
    imageUrl: imageUrl,
    location: location,
    startDatetime: startDatetime,
  );
}

class OrderDetailsItemModel {
  final int orderItemId;
  final int quantity;
  final double price;
  final ItemMiniDetailsModel item;
  final UserMiniModel user;

  OrderDetailsItemModel({
    required this.orderItemId,
    required this.quantity,
    required this.price,
    required this.item,
    required this.user,
  });

  factory OrderDetailsItemModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailsItemModel(
      orderItemId: _toInt(json['orderItemId']),
      quantity: _toInt(json['quantity']),
      price: _toDouble(json['price']),
      item: ItemMiniDetailsModel.fromJson(
        (json['item'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
      user: UserMiniModel.fromJson(
        (json['user'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
    );
  }

  OrderDetailsItem toEntity() => OrderDetailsItem(
    orderItemId: orderItemId,
    quantity: quantity,
    price: price,
    item: item.toEntity(),
    user: user.toEntity(),
  );
}

class OrderDetailsHeaderModel {
  final int id;
  final DateTime? orderDate;
  final double totalPrice;

  final String status;
  final String statusUi;

  final String? paymentMethod;
  final CurrencyMiniModel? currency;

  final String? shippingCity;
  final String? shippingPostalCode;
  final int? shippingMethodId;
  final String? shippingMethodName;
  final double? shippingTotal;
  final double? itemTaxTotal;
  final double? shippingTaxTotal;
  final String? couponCode;
  final double? couponDiscount;

  final bool fullyPaid;
  final PaymentSummaryModel payment;

  OrderDetailsHeaderModel({
    required this.id,
    required this.orderDate,
    required this.totalPrice,
    required this.status,
    required this.statusUi,
    this.paymentMethod,
    this.currency,
    this.shippingCity,
    this.shippingPostalCode,
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

  factory OrderDetailsHeaderModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailsHeaderModel(
      id: _toInt(json['id']),
      orderDate: _tryParseDate(json['orderDate']),
      totalPrice: _toDouble(json['totalPrice']),
      status: (json['status'] ?? '').toString(),
      statusUi: (json['statusUi'] ?? '').toString(),
      paymentMethod: json['paymentMethod']?.toString(),
      currency: (json['currency'] is Map)
          ? CurrencyMiniModel.fromJson(
              (json['currency'] as Map).cast<String, dynamic>(),
            )
          : null,
      shippingCity: json['shippingCity']?.toString(),
      shippingPostalCode: json['shippingPostalCode']?.toString(),
      shippingMethodId: json['shippingMethodId'] == null
          ? null
          : _toInt(json['shippingMethodId']),
      shippingMethodName: json['shippingMethodName']?.toString(),
      shippingTotal: json['shippingTotal'] == null
          ? null
          : _toDouble(json['shippingTotal']),
      itemTaxTotal: json['itemTaxTotal'] == null
          ? null
          : _toDouble(json['itemTaxTotal']),
      shippingTaxTotal: json['shippingTaxTotal'] == null
          ? null
          : _toDouble(json['shippingTaxTotal']),
      couponCode: json['couponCode']?.toString(),
      couponDiscount: json['couponDiscount'] == null
          ? null
          : _toDouble(json['couponDiscount']),
      fullyPaid: json['fullyPaid'] == true,
      payment: PaymentSummaryModel.fromJson(
        (json['payment'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
    );
  }

  OrderDetailsHeader toEntity() => OrderDetailsHeader(
    id: id,
    orderDate: orderDate,
    totalPrice: totalPrice,
    status: status,
    statusUi: statusUi,
    paymentMethod: paymentMethod,
    currency: currency?.toEntity(),
    shippingCity: shippingCity,
    shippingPostalCode: shippingPostalCode,
    shippingMethodId: shippingMethodId,
    shippingMethodName: shippingMethodName,
    shippingTotal: shippingTotal,
    itemTaxTotal: itemTaxTotal,
    shippingTaxTotal: shippingTaxTotal,
    couponCode: couponCode,
    couponDiscount: couponDiscount,
    fullyPaid: fullyPaid,
    payment: payment.toEntity(),
  );
}

class OrderDetailsResponseModel {
  final OrderDetailsHeaderModel order;
  final int itemsCount;
  final List<OrderDetailsItemModel> items;

  OrderDetailsResponseModel({
    required this.order,
    required this.itemsCount,
    required this.items,
  });

  factory OrderDetailsResponseModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailsResponseModel(
      order: OrderDetailsHeaderModel.fromJson(
        (json['order'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
      itemsCount: _toInt(json['itemsCount']),
      items: (json['items'] is List)
          ? (json['items'] as List)
                .whereType<Map>()
                .map(
                  (m) =>
                      OrderDetailsItemModel.fromJson(m.cast<String, dynamic>()),
                )
                .toList()
          : const [],
    );
  }

  OrderDetailsResponse toEntity() => OrderDetailsResponse(
    order: order.toEntity(),
    itemsCount: itemsCount,
    items: items.map((e) => e.toEntity()).toList(),
  );
}
