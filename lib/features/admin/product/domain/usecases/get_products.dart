import 'package:build4front/features/admin/product/domain/entities/product.dart';
import 'package:build4front/features/admin/product/domain/repositories/product_repository.dart';


class GetProducts {
  final ProductRepository repo;

  GetProducts(this.repo);

  Future<List<Product>> call({
    required int ownerProjectId,
    int? itemTypeId,
    int? categoryId,
  }) {
    return repo.getProducts(
      ownerProjectId: ownerProjectId,
      itemTypeId: itemTypeId,
      categoryId: categoryId,
    );
  }
}
