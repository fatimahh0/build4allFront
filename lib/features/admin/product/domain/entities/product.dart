class Product {
  final int id;
  final int ownerProjectId;
  final int? itemTypeId;
  final int? currencyId;
  final int? categoryId;

  final String name;
  final String? description;
  final double price;
  final int? stock;
  final String status;
  final String? imageUrl;

  final String? sku;
  final String productType; // SIMPLE / VARIABLE / GROUPED / EXTERNAL

  final bool virtualProduct;
  final bool downloadable;
  final String? downloadUrl;
  final String? externalUrl;
  final String? buttonText;

  final double? salePrice;
  final DateTime? saleStart;
  final DateTime? saleEnd;

  final double effectivePrice;
  final bool onSale;

  final Map<String, String> attributes; // code -> value

  Product({
    required this.id,
    required this.ownerProjectId,
    this.itemTypeId,
    this.currencyId,
    this.categoryId,
    required this.name,
    this.description,
    required this.price,
    this.stock,
    required this.status,
    this.imageUrl,
    this.sku,
    required this.productType,
    required this.virtualProduct,
    required this.downloadable,
    this.downloadUrl,
    this.externalUrl,
    this.buttonText,
    this.salePrice,
    this.saleStart,
    this.saleEnd,
    required this.effectivePrice,
    required this.onSale,
    required this.attributes,
  });
}
