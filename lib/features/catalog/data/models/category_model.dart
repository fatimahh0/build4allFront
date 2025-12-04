import '../../domain/entities/category.dart';

class CategoryModel {
  final int id;
  final String name;
  final String? iconName;
  final String? iconLibrary;

  CategoryModel({
    required this.id,
    required this.name,
    this.iconName,
    this.iconLibrary,
  });

  static int _asInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse('$v') ?? 0;
  }

  factory CategoryModel.fromJson(Map<String, dynamic> j) {
    return CategoryModel(
      id: _asInt(j['id']),
      name: (j['name'] ?? '').toString().trim(),
      iconName: j['iconName']?.toString(),
      iconLibrary: j['iconLibrary']?.toString(),
    );
  }

  Category toEntity() => Category(
    id: id,
    name: name,
    iconName: iconName,
    iconLibrary: iconLibrary,
  );
}
