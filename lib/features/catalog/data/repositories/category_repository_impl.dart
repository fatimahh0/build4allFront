import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../models/category_model.dart';
import '../services/category_api_service.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryApiService api;

  CategoryRepositoryImpl({required this.api});

  @override
  Future<List<Category>> getByProject(int projectId) async {
    final list = await api.getCategoriesByProject(projectId);
    return list.map((m) => CategoryModel.fromJson(m).toEntity()).toList();
  }

  @override
  Future<List<Category>> getAll() async {
    final list = await api.getAllCategories();
    return list.map((m) => CategoryModel.fromJson(m).toEntity()).toList();
  }
}
