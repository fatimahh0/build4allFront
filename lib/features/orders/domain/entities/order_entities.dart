class OrderItemMini {
  final String itemName;
  final String? imageUrl;
  final DateTime? startDatetime;
  final String? location;

  const OrderItemMini({
    required this.itemName,
    this.imageUrl,
    this.startDatetime,
    this.location,
  });
}

class OrderMini {
  final String? status; // ex: "PENDING"
  const OrderMini({this.status});
}

class OrderLine {
  final int id; // line id
  final String orderStatus; // ex: "Pending"
  final int quantity;
  final bool wasPaid;
  final OrderItemMini item;
  final OrderMini order;

  const OrderLine({
    required this.id,
    required this.orderStatus,
    required this.quantity,
    required this.wasPaid,
    required this.item,
    required this.order,
  });
}
