import 'package:equatable/equatable.dart';

enum CouponDiscountType { percent, fixed, freeShipping }

class Coupon extends Equatable {
  final int id;
  final int ownerProjectId;
  final String code;
  final String? description;
  final CouponDiscountType discountType;
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

  const Coupon({
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

  Coupon copyWith({
    int? id,
    int? ownerProjectId,
    String? code,
    String? description,
    CouponDiscountType? discountType,
    double? discountValue,
    int? maxUses,
    int? usedCount,
    int? remainingUses,
    double? minOrderAmount,
    double? maxDiscountAmount,
    DateTime? startsAt,
    DateTime? expiresAt,
    bool? active,
    bool? started,
    bool? expired,
    bool? usageLimitReached,
    bool? currentlyValid,
    String? status,
  }) {
    return Coupon(
      id: id ?? this.id,
      ownerProjectId: ownerProjectId ?? this.ownerProjectId,
      code: code ?? this.code,
      description: description ?? this.description,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      maxUses: maxUses ?? this.maxUses,
      usedCount: usedCount ?? this.usedCount,
      remainingUses: remainingUses ?? this.remainingUses,
      minOrderAmount: minOrderAmount ?? this.minOrderAmount,
      maxDiscountAmount: maxDiscountAmount ?? this.maxDiscountAmount,
      startsAt: startsAt ?? this.startsAt,
      expiresAt: expiresAt ?? this.expiresAt,
      active: active ?? this.active,
      started: started ?? this.started,
      expired: expired ?? this.expired,
      usageLimitReached: usageLimitReached ?? this.usageLimitReached,
      currentlyValid: currentlyValid ?? this.currentlyValid,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
        id,
        ownerProjectId,
        code,
        description,
        discountType,
        discountValue,
        maxUses,
        usedCount,
        remainingUses,
        minOrderAmount,
        maxDiscountAmount,
        startsAt,
        expiresAt,
        active,
        started,
        expired,
        usageLimitReached,
        currentlyValid,
        status,
      ];
}