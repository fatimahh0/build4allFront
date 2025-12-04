import '../entities/category.dart';
import '../repositories/category_repository.dart';

class GetCategoriesByProject {
  final CategoryRepository repo;

  GetCategoriesByProject(this.repo);

  Future<List<Category>> call(int projectId) {
    return repo.getByProject(projectId);
  }
}
