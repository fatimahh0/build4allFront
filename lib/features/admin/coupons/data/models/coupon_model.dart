import 'package:build4front/features/admin/coupons/domain/entities/coupon.dart';

class CouponModel {
  final int id;
  final int ownerProjectId;
  final String code;
  final String? description;
  final String discountType;
  final double discountValue;
  final int? maxUses;
  final int usedCount;
  final int? remainingUses;
  final double? minOrderAmount;
  final double? maxDiscountAmount;
  final DateTime? startsAt;
  final DateTime? expiresAt;
  final bool active;

  // computed admin info
  final bool started;
  final bool expired;
  final bool usageLimitReached;
  final bool currentlyValid;
  final String status;

  const CouponModel({
    required this.id,
    required this.ownerProjectId,
    required this.code,
    required this.description,
    required this.discountType,
    required this.discountValue,
    required this.maxUses,
    required this.usedCount,
    required this.remainingUses,
    required this.minOrderAmount,
    required this.maxDiscountAmount,
    required this.startsAt,
    required this.expiresAt,
    required this.active,
    required this.started,
    required this.expired,
    required this.usageLimitReached,
    required this.currentlyValid,
    required this.status,
  });

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      id: (json['id'] ?? 0) as int,
      ownerProjectId: (json['ownerProjectId'] ?? 0) as int,
      code: (json['code'] ?? '') as String,
      description: json['description'] as String?,
      discountType: (json['discountType'] ?? 'PERCENT') as String,
      discountValue: (json['discountValue'] as num?)?.toDouble() ?? 0.0,
      maxUses: json['maxUses'] as int?,
      usedCount: (json['usedCount'] ?? 0) as int,
      remainingUses: json['remainingUses'] as int?,
      minOrderAmount: (json['minOrderAmount'] as num?)?.toDouble(),
      maxDiscountAmount: (json['maxDiscountAmount'] as num?)?.toDouble(),
      startsAt: json['startsAt'] != null
          ? DateTime.parse(json['startsAt'] as String)
          : null,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
      active: (json['active'] ?? true) as bool,
      started: (json['started'] ?? true) as bool,
      expired: (json['expired'] ?? false) as bool,
      usageLimitReached: (json['usageLimitReached'] ?? false) as bool,
      currentlyValid: (json['currentlyValid'] ?? false) as bool,
      status: (json['status'] ?? 'ACTIVE') as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerProjectId': ownerProjectId,
      'code': code,
      'description': description,
      'discountType': discountType,
      'discountValue': discountValue,
      'maxUses': maxUses,
      'minOrderAmount': minOrderAmount,
      'maxDiscountAmount': maxDiscountAmount,
      'startsAt': startsAt?.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'active': active,
    };
  }

  Coupon toEntity() {
    CouponDiscountType mapType(String raw) {
      switch (raw.toUpperCase()) {
        case 'FIXED':
          return CouponDiscountType.fixed;
        case 'FREE_SHIPPING':
          return CouponDiscountType.freeShipping;
        case 'PERCENT':
        default:
          return CouponDiscountType.percent;
      }
    }

    return Coupon(
      id: id,
      ownerProjectId: ownerProjectId,
      code: code,
      description: description,
      discountType: mapType(discountType),
      discountValue: discountValue,
      maxUses: maxUses,
      usedCount: usedCount,
      remainingUses: remainingUses,
      minOrderAmount: minOrderAmount,
      maxDiscountAmount: maxDiscountAmount,
      startsAt: startsAt,
      expiresAt: expiresAt,
      active: active,
      started: started,
      expired: expired,
      usageLimitReached: usageLimitReached,
      currentlyValid: currentlyValid,
      status: status,
    );
  }

  static CouponModel fromEntity(Coupon c) {
    String mapType(CouponDiscountType t) {
      switch (t) {
        case CouponDiscountType.percent:
          return 'PERCENT';
        case CouponDiscountType.fixed:
          return 'FIXED';
        case CouponDiscountType.freeShipping:
          return 'FREE_SHIPPING';
      }
    }

    return CouponModel(
      id: c.id,
      ownerProjectId: c.ownerProjectId,
      code: c.code,
      description: c.description,
      discountType: mapType(c.discountType),
      discountValue: c.discountValue,
      maxUses: c.maxUses,
      usedCount: c.usedCount,
      remainingUses: c.remainingUses,
      minOrderAmount: c.minOrderAmount,
      maxDiscountAmount: c.maxDiscountAmount,
      startsAt: c.startsAt,
      expiresAt: c.expiresAt,
      active: c.active,
      started: c.started,
      expired: c.expired,
      usageLimitReached: c.usageLimitReached,
      currentlyValid: c.currentlyValid,
      status: c.status,
    );
  }
}