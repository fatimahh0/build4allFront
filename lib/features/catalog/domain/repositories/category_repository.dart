import '../entities/category.dart';

abstract class CategoryRepository {
  Future<List<Category>> getByProject(int projectId);


  Future<List<Category>> getAll();
}
