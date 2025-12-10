import '../../domain/entities/home_banner.dart';

class HomeBannerModel extends HomeBanner {
  const HomeBannerModel({
    required super.id,
    required super.imageUrl,
    super.title,
    super.subtitle,
    super.targetType,
    super.targetId,
    super.targetUrl,
    required super.sortOrder,
    super.startAt,
    super.endAt,
  });

  factory HomeBannerModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDt(dynamic v) {
      if (v == null) return null;
      try {
        return DateTime.parse(v.toString());
      } catch (_) {
        return null;
      }
    }

    return HomeBannerModel(
      id: (json['id'] as num).toInt(),
      imageUrl: (json['imageUrl'] ?? '').toString(),
      title: json['title']?.toString(),
      subtitle: json['subtitle']?.toString(),
      targetType: json['targetType']?.toString(),
      targetId: json['targetId'] == null
          ? null
          : (json['targetId'] as num).toInt(),
      targetUrl: json['targetUrl']?.toString(),
      sortOrder: (json['sortOrder'] ?? 0 as num).toInt(),
      startAt: parseDt(json['startAt']),
      endAt: parseDt(json['endAt']),
    );
  }
}
