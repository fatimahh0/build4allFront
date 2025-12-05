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

  /// NEW: backend category id (ProductResponse.categoryId for e-commerce)
  final int? categoryId;

  ItemSummaryModel({
    required this.id,
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.location,
    this.start,
    this.price,
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

    return ItemSummaryModel(
      id: j['id'] is int ? j['id'] as int : int.parse('${j['id']}'),
      // for activities we used itemName, for products we use name
      title: (j['itemName'] ?? j['name'] ?? '').toString(),
      subtitle: j['description']?.toString(),
      imageUrl: j['imageUrl']?.toString(),
      location: j['location']?.toString(),
      start: _dt(j['startDatetime']),
      price: _num(j['price'] ?? j['effectivePrice']),
      // 🔥 NEW: read categoryId if backend sends it (ProductResponse has it)
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
      kind: currentItemKindFromEnv(),
      categoryId: categoryId,
    );
  }
}
