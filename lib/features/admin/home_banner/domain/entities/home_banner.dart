class HomeBanner {
  final int id;
  final String imageUrl;
  final String? title;
  final String? subtitle;
  final String? targetType; // PRODUCT | CATEGORY | URL | NONE
  final int? targetId;
  final String? targetUrl;
  final int sortOrder;
  final DateTime? startAt;
  final DateTime? endAt;

  const HomeBanner({
    required this.id,
    required this.imageUrl,
    this.title,
    this.subtitle,
    this.targetType,
    this.targetId,
    this.targetUrl,
    required this.sortOrder,
    this.startAt,
    this.endAt,
  });
}
