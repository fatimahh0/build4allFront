// lib/features/cart/data/models/cart_item_model.dart
class CartItemModel {
  final int cartItemId;
  final int itemId;
  final String itemName;
  final String? imageUrl;
  final int quantity;
  final double unitPrice;
  final double lineTotal;

  final int? availableStock;
  final bool outOfStock;
  final bool quantityExceedsStock;
  final int? maxAllowedQuantity;
  final bool disabled;
  final String? blockingReason;

  // ✅ NEW
  final bool isUpcoming;
  final String? statusCode;
  final String? statusName;

  const CartItemModel({
    required this.cartItemId,
    required this.itemId,
    required this.itemName,
    required this.imageUrl,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
    required this.availableStock,
    required this.outOfStock,
    required this.quantityExceedsStock,
    required this.maxAllowedQuantity,
    required this.disabled,
    required this.blockingReason,
    required this.isUpcoming,
    required this.statusCode,
    required this.statusName,
  });

  static int? _readInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  static double _readDouble(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '') ?? 0.0;
  }

  static bool _readBool(dynamic v) {
    if (v is bool) return v;
    if (v is num) return v != 0;
    final s = (v ?? '').toString().trim().toLowerCase();
    return s == 'true' || s == '1' || s == 'yes';
  }

  static String? _readString(dynamic v) {
    final s = (v ?? '').toString().trim();
    return s.isEmpty ? null : s;
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final nestedItem = json['item'] is Map<String, dynamic>
        ? json['item'] as Map<String, dynamic>
        : null;

    final rawStatusCode = _readString(
      json['statusCode'] ??
          json['itemStatusCode'] ??
          nestedItem?['statusCode'],
    );

    final rawStatusName = _readString(
      json['statusName'] ??
          json['itemStatusName'] ??
          nestedItem?['statusName'],
    );

    final rawIsUpcoming = _readBool(
      json['isUpcoming'] ??
          json['upcoming'] ??
          json['comingSoon'] ??
          nestedItem?['isUpcoming'] ??
          nestedItem?['upcoming'] ??
          nestedItem?['comingSoon'],
    );

    final normalizedCode = (rawStatusCode ?? '').trim().toUpperCase();
    final normalizedName = (rawStatusName ?? '').trim().toUpperCase();
    final reason = _readString(json['blockingReason']);

    final inferredUpcoming = rawIsUpcoming ||
        normalizedCode == 'UPCOMING' ||
        normalizedName == 'UPCOMING' ||
        normalizedCode == 'COMING_SOON' ||
        normalizedName == 'COMING_SOON' ||
        normalizedName == 'COMING SOON' ||
        ((reason ?? '').toLowerCase().contains('coming soon'));

    return CartItemModel(
      cartItemId: _readInt(json['cartItemId'] ?? json['id']) ?? 0,
      itemId: _readInt(json['itemId'] ?? nestedItem?['id']) ?? 0,
      itemName: _readString(json['itemName'] ?? nestedItem?['name']) ?? '',
      imageUrl: _readString(json['imageUrl'] ?? nestedItem?['imageUrl']),
      quantity: _readInt(json['quantity']) ?? 0,
      unitPrice: _readDouble(json['unitPrice']),
      lineTotal: _readDouble(json['lineTotal']),
      availableStock: _readInt(json['availableStock']),
      outOfStock: _readBool(json['outOfStock']),
      quantityExceedsStock: _readBool(json['quantityExceedsStock']),
      maxAllowedQuantity: _readInt(json['maxAllowedQuantity']),
      disabled: _readBool(json['disabled']),
      blockingReason: reason,

      // ✅ NEW
      isUpcoming: inferredUpcoming,
      statusCode: rawStatusCode,
      statusName: rawStatusName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cartItemId': cartItemId,
      'itemId': itemId,
      'itemName': itemName,
      'imageUrl': imageUrl,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'lineTotal': lineTotal,
      'availableStock': availableStock,
      'outOfStock': outOfStock,
      'quantityExceedsStock': quantityExceedsStock,
      'maxAllowedQuantity': maxAllowedQuantity,
      'disabled': disabled,
      'blockingReason': blockingReason,

      // ✅ NEW
      'isUpcoming': isUpcoming,
      'statusCode': statusCode,
      'statusName': statusName,
    };
  }
}