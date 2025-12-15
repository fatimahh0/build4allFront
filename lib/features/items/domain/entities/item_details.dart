class ItemAttribute {
  final String code;
  final String value;
  const ItemAttribute({required this.code, required this.value});
}

class ItemDetails {
  final int id;
  final String name;
  final String? description;
  final String? imageUrl;

  final num? price;
  final num? salePrice;
  final DateTime? saleStart;
  final DateTime? saleEnd;
  final num? effectivePrice;
  final bool onSale;

  final int? stock;
  final String? sku;

  final bool taxable;
  final String? taxClass;

  final num? weightKg;
  final num? widthCm;
  final num? heightCm;
  final num? lengthCm;

  final List<ItemAttribute> attributes;

  const ItemDetails({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.price,
    this.salePrice,
    this.saleStart,
    this.saleEnd,
    this.effectivePrice,
    this.onSale = false,
    this.stock,
    this.sku,
    this.taxable = false,
    this.taxClass,
    this.weightKg,
    this.widthCm,
    this.heightCm,
    this.lengthCm,
    this.attributes = const [],
  });

  bool get isSaleActiveNow {
    if (!onSale) return false;
    final now = DateTime.now();

    if (saleStart == null && saleEnd == null) return true;
    if (saleStart != null && saleEnd == null) return !now.isBefore(saleStart!);
    if (saleStart == null && saleEnd != null) return !now.isAfter(saleEnd!);

    return !now.isBefore(saleStart!) && !now.isAfter(saleEnd!);
  }

  num? get displayPrice {
    if (isSaleActiveNow) {
      return effectivePrice ?? salePrice ?? price;
    }
    return price;
  }

  num? get oldPriceIfDiscounted {
    final cur = displayPrice;
    if (!isSaleActiveNow) return null;
    if (price == null || cur == null) return null;
    if (price! <= cur) return null;
    return price;
  }
}
