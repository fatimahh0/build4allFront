// lib/features/catalog/domain/entities/item_type.dart

class ItemType {
  final int id;
  final String name;
  final String? icon;
  final String? iconLib;
  final int? itemsCount;

  const ItemType({
    required this.id,
    required this.name,
    this.icon,
    this.iconLib,
    this.itemsCount,
  });
}
