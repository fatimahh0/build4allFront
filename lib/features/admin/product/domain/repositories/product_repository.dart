import 'package:build4front/features/admin/product/domain/entities/product.dart';


abstract class ProductRepository {
  Future<List<Product>> getProducts({
    required int ownerProjectId,
    int? itemTypeId,
    int? categoryId,
  });

  Future<List<Product>> getNewArrivals({
    required int ownerProjectId,
    int? days,
  });

  Future<List<Product>> getBestSellers({
    required int ownerProjectId,
    int? limit,
  });

  Future<List<Product>> getDiscounted({required int ownerProjectId});

  Future<Product> getById(int id);

  Future<Product> createProduct({
    required int ownerProjectId,
    required int itemTypeId,
    required int? currencyId,
    required String name,
    String? description,
    required double price,
    int? stock,
    String? status,
    String? imageUrl,
    String? sku,
    String productType,
    bool virtualProduct,
    bool downloadable,
    String? downloadUrl,
    String? externalUrl,
    String? buttonText,
    double? salePrice,
    DateTime? saleStart,
    DateTime? saleEnd,
    Map<String, String>? attributes,
  });

  Future<Product> updateProduct(
    int id, {
    String? name,
    String? description,
    double? price,
    int? stock,
    String? status,
    String? imageUrl,
    String? sku,
    String? productType,
    bool? virtualProduct,
    bool? downloadable,
    String? downloadUrl,
    String? externalUrl,
    String? buttonText,
    double? salePrice,
    DateTime? saleStart,
    DateTime? saleEnd,
    Map<String, String>? attributes,
  });

  Future<void> deleteProduct(int id);
}
