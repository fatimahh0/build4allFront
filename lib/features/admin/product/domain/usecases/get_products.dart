import '../entities/product.dart';
import '../repositories/product_repository.dart';

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
