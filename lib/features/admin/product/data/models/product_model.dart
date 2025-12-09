import '../../domain/entities/product.dart';

class ProductModel extends Product {
  ProductModel({
    required super.id,
    required super.ownerProjectId,
    super.itemTypeId,
    super.currencyId,
    super.categoryId,
    required super.name,
    super.description,
    required super.price,
    super.stock,
    required super.status,
    super.imageUrl,
    super.sku,
    required super.productType,
    required super.virtualProduct,
    required super.downloadable,
    super.downloadUrl,
    super.externalUrl,
    super.buttonText,
    super.salePrice,
    super.saleStart,
    super.saleEnd,
    required super.effectivePrice,
    required super.onSale,
    required super.attributes,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final attrsList =
        (json['attributes'] as List<dynamic>?)
            ?.map((e) => (e as Map).cast<String, dynamic>())
            .toList() ??
        [];

    final attrsMap = <String, String>{};
    for (final attr in attrsList) {
      final code = attr['code']?.toString();
      final value = attr['value']?.toString();
      if (code != null && value != null) {
        attrsMap[code] = value;
      }
    }

    return ProductModel(
      id: (json['id'] as num).toInt(),
      ownerProjectId: (json['ownerProjectId'] as num).toInt(),
      itemTypeId: (json['itemTypeId'] as num?)?.toInt(),
      currencyId: (json['currencyId'] as num?)?.toInt(),
      categoryId: (json['categoryId'] as num?)?.toInt(),
      name: (json['name'] ?? '').toString(),
      description: json['description'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      stock: (json['stock'] as num?)?.toInt(),
      status: (json['status'] ?? 'Upcoming').toString(),
      imageUrl: json['imageUrl'] as String?,
      sku: json['sku'] as String?,
      productType: (json['productType'] ?? 'SIMPLE').toString(),
      virtualProduct: json['virtualProduct'] as bool? ?? false,
      downloadable: json['downloadable'] as bool? ?? false,
      downloadUrl: json['downloadUrl'] as String?,
      externalUrl: json['externalUrl'] as String?,
      buttonText: json['buttonText'] as String?,
      salePrice: (json['salePrice'] as num?)?.toDouble(),
      saleStart: json['saleStart'] != null
          ? DateTime.tryParse(json['saleStart'].toString())
          : null,
      saleEnd: json['saleEnd'] != null
          ? DateTime.tryParse(json['saleEnd'].toString())
          : null,
      effectivePrice:
          (json['effectivePrice'] as num?)?.toDouble() ??
          (json['price'] as num?)?.toDouble() ??
          0.0,
      onSale: json['onSale'] as bool? ?? false,
      attributes: attrsMap,
    );
  }
}
