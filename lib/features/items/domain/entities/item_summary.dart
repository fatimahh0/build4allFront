enum ItemKind { activity, product, service, unknown }

class ItemSummary {
  final int id;
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final String? location;
  final DateTime? start;
  final num? price;
  final ItemKind kind;

  /// NEW: category id of this item (for filtering chips)
  final int? categoryId;

  const ItemSummary({
    required this.id,
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.location,
    this.start,
    this.price,
    this.kind = ItemKind.unknown,
    this.categoryId,
  });
}
