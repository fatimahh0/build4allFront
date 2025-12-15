import 'package:build4front/features/items/domain/entities/item_summary.dart';
import 'package:build4front/features/items/domain/entities/item_kind_mapper.dart';

class ItemSummaryModel {
  final int id;
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final String? location;
  final DateTime? start;

  final num? price;
  final num? salePrice;
  final DateTime? saleStart;
  final DateTime? saleEnd;
  final num? effectivePrice;
  final bool onSale;

  final int? stock;
  final String? sku;

  final int? categoryId;

  ItemSummaryModel({
    required this.id,
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.location,
    this.start,
    this.price,
    this.salePrice,
    this.saleStart,
    this.saleEnd,
    this.effectivePrice,
    this.onSale = false,
    this.stock,
    this.sku,
    this.categoryId,
  });

  factory ItemSummaryModel.fromJson(Map<String, dynamic> j) {
    DateTime? _dt(dynamic v) => v == null ? null : DateTime.tryParse('$v');

    num? _num(dynamic v) {
      if (v == null) return null;
      if (v is num) return v;
      return num.tryParse('$v');
    }

    int? _intOrNull(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse('$v');
    }

    bool _bool(dynamic v) {
      if (v == null) return false;
      if (v is bool) return v;
      return '$v'.toLowerCase() == 'true';
    }

    return ItemSummaryModel(
      id: j['id'] is int ? j['id'] as int : int.parse('${j['id']}'),
      title: (j['itemName'] ?? j['name'] ?? '').toString(),
      subtitle: j['description']?.toString(),
      imageUrl: j['imageUrl']?.toString(),
      location: j['location']?.toString(),
      start: _dt(j['startDatetime']),
      price: _num(j['price']),
      salePrice: _num(j['salePrice']),
      saleStart: _dt(j['saleStart']),
      saleEnd: _dt(j['saleEnd']),
      effectivePrice: _num(j['effectivePrice']),
      onSale: _bool(j['onSale']),
      stock: _intOrNull(j['stock']),
      sku: j['sku']?.toString(),
      categoryId: _intOrNull(j['categoryId']),
    );
  }

  ItemSummary toEntity() {
    return ItemSummary(
      id: id,
      title: title,
      subtitle: subtitle,
      imageUrl: imageUrl,
      location: location,
      start: start,
      price: price,
      salePrice: salePrice,
      saleStart: saleStart,
      saleEnd: saleEnd,
      effectivePrice: effectivePrice,
      onSale: onSale,
      stock: stock,
      sku: sku,
      kind: currentItemKindFromEnv(),
      categoryId: categoryId,
    );
  }
}
