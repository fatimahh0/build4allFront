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

  factory HomeBanner.fromJson(Map<String, dynamic> json) {
    return HomeBanner(
      id: (json['id'] as num).toInt(),
      imageUrl: json['imageUrl'] as String,
      title: json['title'] as String?,
      subtitle: json['subtitle'] as String?,
      targetType: json['targetType'] as String?,
      targetId: json['targetId'] != null
          ? (json['targetId'] as num).toInt()
          : null,
      targetUrl: json['targetUrl'] as String?,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      startAt: json['startAt'] != null
          ? DateTime.parse(json['startAt'] as String)
          : null,
      endAt: json['endAt'] != null
          ? DateTime.parse(json['endAt'] as String)
          : null,
    );
  }
}
