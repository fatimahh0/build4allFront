import 'dart:convert';

enum ProductTypeDto { simple, variable, grouped, external }

String productTypeDtoToApi(ProductTypeDto t) {
  switch (t) {
    case ProductTypeDto.simple:
      return 'SIMPLE';
    case ProductTypeDto.variable:
      return 'VARIABLE';
    case ProductTypeDto.grouped:
      return 'GROUPED';
    case ProductTypeDto.external:
      return 'EXTERNAL';
  }
}

class AttributeValueDto {
  final String code;
  final String value;

  AttributeValueDto({required this.code, required this.value});

  Map<String, dynamic> toJson() => {'code': code, 'value': value};
}

class CreateProductRequest {
  /// aup_id
  final int ownerProjectId;

  /// OPTIONAL – advanced mode: explicit item type
  final int? itemTypeId;

  /// OPTIONAL – simple mode: only category
  final int? categoryId;

  final int? currencyId;

  final String name;
  final String? description;
  final double price;
  final int? stock;
  final String? status; // backend will default to "Upcoming" if null

  final String? imageUrl;
  final String? sku;
  final ProductTypeDto productType;

  final bool virtualProduct;
  final bool downloadable;
  final String? downloadUrl;
  final String? externalUrl;
  final String? buttonText;

  final double? salePrice;
  final String? saleStart; // e.g. 2025-12-03T00:00:00
  final String? saleEnd;

  final List<AttributeValueDto> attributes;

  CreateProductRequest({
    required this.ownerProjectId,
    this.itemTypeId,
    this.categoryId,
    this.currencyId,
    required this.name,
    this.description,
    required this.price,
    this.stock,
    this.status,
    this.imageUrl,
    this.sku,
    required this.productType,
    this.virtualProduct = false,
    this.downloadable = false,
    this.downloadUrl,
    this.externalUrl,
    this.buttonText,
    this.salePrice,
    this.saleStart,
    this.saleEnd,
    this.attributes = const [],
  }) : assert(
         itemTypeId != null || categoryId != null,
         'Either itemTypeId or categoryId must be provided',
       );

  Map<String, dynamic> toJson() {
    return {
      'ownerProjectId': ownerProjectId,
      if (itemTypeId != null) 'itemTypeId': itemTypeId,
      if (categoryId != null) 'categoryId': categoryId,
      'currencyId': currencyId,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'status': status,
      'imageUrl': imageUrl,
      'sku': sku,
      'productType': productTypeDtoToApi(productType),
      'virtualProduct': virtualProduct,
      'downloadable': downloadable,
      'downloadUrl': downloadUrl,
      'externalUrl': externalUrl,
      'buttonText': buttonText,
      'salePrice': salePrice,
      'saleStart': saleStart,
      'saleEnd': saleEnd,
      if (attributes.isNotEmpty)
        'attributes': attributes.map((e) => e.toJson()).toList(),
    };
  }

  String toJsonString() => jsonEncode(toJson());
}
