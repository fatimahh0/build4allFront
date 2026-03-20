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
    super.active,
    super.startAt,
    super.endAt,
  });

  factory HomeBannerModel.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v, [int fallback = 0]) {
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse('$v') ?? fallback;
    }

    DateTime? parseDt(dynamic v) {
      if (v == null) return null;
      try {
        return DateTime.parse(v.toString());
      } catch (_) {
        return null;
      }
    }

    bool parseBool(dynamic v) {
      if (v is bool) return v;
      if (v is num) return v != 0;
      final s = (v ?? '').toString().trim().toLowerCase();
      return s == 'true' || s == '1';
    }

    return HomeBannerModel(
      id: toInt(json['id']),
      imageUrl: (json['imageUrl'] ?? '').toString(),
      title: json['title']?.toString(),
      subtitle: json['subtitle']?.toString(),
      targetType: json['targetType']?.toString(),
      targetId: json['targetId'] == null ? null : toInt(json['targetId']),
      targetUrl: json['targetUrl']?.toString(),
      sortOrder: toInt(json['sortOrder']),
      active: parseBool(json['active'] ?? json['isActive']),
      startAt: parseDt(json['startAt']),
      endAt: parseDt(json['endAt']),
    );
  }
}