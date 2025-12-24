import 'package:build4front/features/items/domain/entities/item_details.dart';

class ItemDetailsModel {
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

  ItemDetailsModel({
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

  factory ItemDetailsModel.fromJson(Map<String, dynamic> j) {
    DateTime? _dt(dynamic v) => v == null ? null : DateTime.tryParse('$v');


num? _parseNum(dynamic v) {
      if (v == null) return null;
      if (v is num) return v;

      final s = '$v'.trim();
      if (s.isEmpty) return null;

      final i = int.tryParse(s);
      if (i != null) return i;

      final d = double.tryParse(s);
      if (d != null) return d;

      return double.tryParse(s.replaceAll(',', '.'));
    }


    bool _bool(dynamic v) {
      if (v == null) return false;
      if (v is bool) return v;
      return '$v'.toLowerCase() == 'true';
    }

    int? _int(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse('$v');
    }

    final attrsRaw = (j['attributes'] as List?) ?? const [];
    final attrs = attrsRaw.map((e) {
      final m = Map<String, dynamic>.from(e as Map);
      return ItemAttribute(
        code: (m['code'] ?? '').toString(),
        value: (m['value'] ?? '').toString(),
      );
    }).toList();

    return ItemDetailsModel(
      id: j['id'] is int ? j['id'] as int : int.parse('${j['id']}'),
      name: (j['name'] ?? j['itemName'] ?? '').toString(),
      description: j['description']?.toString(),
      imageUrl: j['imageUrl']?.toString(),
      price: _parseNum(j['price']),
      salePrice: _parseNum(j['salePrice']),
      saleStart: _dt(j['saleStart']),
      saleEnd: _dt(j['saleEnd']),
      effectivePrice: _parseNum(j['effectivePrice']),
      onSale: _bool(j['onSale']),
      stock: _int(j['stock']),
      sku: j['sku']?.toString(),
      taxable: _bool(j['taxable']),
      taxClass: j['taxClass']?.toString(),
      weightKg: _parseNum(j['weightKg']),
      widthCm: _parseNum(j['widthCm']),
      heightCm: _parseNum(j['heightCm']),
      lengthCm: _parseNum(j['lengthCm']),
      attributes: attrs,
    );
  }

  ItemDetails toEntity() {
    return ItemDetails(
      id: id,
      name: name,
      description: description,
      imageUrl: imageUrl,
      price: price,
      salePrice: salePrice,
      saleStart: saleStart,
      saleEnd: saleEnd,
      effectivePrice: effectivePrice,
      onSale: onSale,
      stock: stock,
      sku: sku,
      taxable: taxable,
      taxClass: taxClass,
      weightKg: weightKg,
      widthCm: widthCm,
      heightCm: heightCm,
      lengthCm: lengthCm,
      attributes: attributes,
    );
  }
}
