import 'package:build4front/core/network/globals.dart' as authState;

import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../models/category_model.dart';
import '../services/category_api_service.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryApiService api;

  CategoryRepositoryImpl({required this.api});

  String _requireToken() {
    final t = (authState.token ?? '').trim();
    if (t.isEmpty) {
      throw Exception('Missing auth token');
    }
    return t;
  }

  @override
  Future<List<Category>> getByProject(int projectId) async {
    final token = _requireToken();
    final list = await api.getCategoriesByProject(
      projectId,
      authToken: token,
    );
    return list.map((m) => CategoryModel.fromJson(m).toEntity()).toList();
  }

  /// ✅ Tenant-safe list (recommended)
  /// Uses GET /api/admin/categories with Authorization
  @override
  Future<List<Category>> getAll() async {
    final token = _requireToken();

    // If you applied my "tenant-safe" api service:
    final list = await api.getCategoriesForTenant(
      authToken: token,
    );

    return list.map((m) => CategoryModel.fromJson(m).toEntity()).toList();
  }

  // ---------------- Optional: keep legacy methods ----------------
  // If your CategoryApiService still has getAllCategories(), you can temporarily do:
  //
  // final list = await api.getAllCategories(authToken: token);
  //
  // But long-term: prefer getCategoriesForTenant().
}
