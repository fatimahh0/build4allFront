class ItemType {
  final int id;
  final String name;
  final String? icon;
  final String? iconLib;
  final int? itemsCount;
  final int? categoryId; 

  const ItemType({
    required this.id,
    required this.name,
    this.icon,
    this.iconLib,
    this.itemsCount,
    this.categoryId,
  });
}
