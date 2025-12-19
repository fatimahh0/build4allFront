import '../../domain/entities/order_entities.dart';

DateTime? _tryParseDate(dynamic v) {
  if (v == null) return null;
  if (v is String && v.trim().isNotEmpty) {
    return DateTime.tryParse(v);
  }
  return null;
}

class OrderItemMiniModel {
  final String itemName;
  final String? imageUrl;
  final DateTime? startDatetime;
  final String? location;

  OrderItemMiniModel({
    required this.itemName,
    this.imageUrl,
    this.startDatetime,
    this.location,
  });

  factory OrderItemMiniModel.fromJson(Map<String, dynamic> json) {
    return OrderItemMiniModel(
      itemName: (json['itemName'] ?? '').toString(),
      imageUrl: json['imageUrl']?.toString(),
      startDatetime: _tryParseDate(json['startDatetime']),
      location: json['location']?.toString(),
    );
  }

  OrderItemMini toEntity() => OrderItemMini(
    itemName: itemName,
    imageUrl: imageUrl,
    startDatetime: startDatetime,
    location: location,
  );
}

class OrderMiniModel {
  final String? status;

  OrderMiniModel({this.status});

  factory OrderMiniModel.fromJson(Map<String, dynamic> json) {
    return OrderMiniModel(status: json['status']?.toString());
  }

  OrderMini toEntity() => OrderMini(status: status);
}

class OrderLineModel {
  final int id;
  final String orderStatus;
  final int quantity;
  final bool wasPaid;
  final OrderItemMiniModel item;
  final OrderMiniModel order;

  OrderLineModel({
    required this.id,
    required this.orderStatus,
    required this.quantity,
    required this.wasPaid,
    required this.item,
    required this.order,
  });

  factory OrderLineModel.fromJson(Map<String, dynamic> json) {
    return OrderLineModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      orderStatus: (json['orderStatus'] ?? '').toString(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      wasPaid: json['wasPaid'] == true,
      item: OrderItemMiniModel.fromJson(
        (json['item'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
      order: OrderMiniModel.fromJson(
        (json['order'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
    );
  }

  OrderLine toEntity() => OrderLine(
    id: id,
    orderStatus: orderStatus,
    quantity: quantity,
    wasPaid: wasPaid,
    item: item.toEntity(),
    order: order.toEntity(),
  );
}
