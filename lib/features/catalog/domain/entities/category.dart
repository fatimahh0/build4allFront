class Category {
  final int id;
  final String name;
  final String? iconName;
  final String? iconLibrary;

  const Category({
    required this.id,
    required this.name,
    this.iconName,
    this.iconLibrary,
  });
}
