import '../../domain/entities/item_type.dart';

class ItemTypeModel {
  final int id;
  final String name;
  final String? icon;
  final String? iconLib;
  final int? itemsCount;
  final int? categoryId; // 🔴 NEW

  ItemTypeModel({
    required this.id,
    required this.name,
    this.icon,
    this.iconLib,
    this.itemsCount,
    this.categoryId,
  });

  static int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse('$v');
  }

  factory ItemTypeModel.fromJson(Map<String, dynamic> j) {
    // label: displayName > name
    final label = (j['displayName'] ?? j['name'] ?? '').toString().trim();

    // backward-compatible counts
    final rawCount =
        j['activitiesCount'] ??
        j['itemsCount'] ??
        j['count'] ??
        j['total'] ??
        j['items_count'] ??
        j['activities_count'];

    return ItemTypeModel(
      id: _asInt(j['id']) ?? 0,
      name: label,
      icon: j['icon']?.toString(),
      iconLib: j['iconLibrary']?.toString() ?? j['iconLib']?.toString(),
      itemsCount: _asInt(rawCount),
      categoryId: _asInt(j['categoryId']),
    );
  }

  ItemType toEntity() => ItemType(
    id: id,
    name: name,
    icon: icon,
    iconLib: iconLib,
    itemsCount: itemsCount,
    categoryId: categoryId,
  );
}
