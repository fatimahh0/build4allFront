import '../entities/category.dart';
import '../repositories/category_repository.dart';

class GetAllCategories {
  final CategoryRepository repo;

  GetAllCategories(this.repo);

  Future<List<Category>> call() {
    return repo.getAll();
  }
}
