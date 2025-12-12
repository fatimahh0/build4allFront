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
  final double? minOrderAmount;
  final double? maxDiscountAmount;
  final DateTime? startsAt;
  final DateTime? expiresAt;
  final bool active;

  const Coupon({
    required this.id,
    required this.ownerProjectId,
    required this.code,
    required this.description,
    required this.discountType,
    required this.discountValue,
    required this.maxUses,
    required this.minOrderAmount,
    required this.maxDiscountAmount,
    required this.startsAt,
    required this.expiresAt,
    required this.active,
  });

  Coupon copyWith({
    int? id,
    int? ownerProjectId,
    String? code,
    String? description,
    CouponDiscountType? discountType,
    double? discountValue,
    int? maxUses,
    double? minOrderAmount,
    double? maxDiscountAmount,
    DateTime? startsAt,
    DateTime? expiresAt,
    bool? active,
  }) {
    return Coupon(
      id: id ?? this.id,
      ownerProjectId: ownerProjectId ?? this.ownerProjectId,
      code: code ?? this.code,
      description: description ?? this.description,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      maxUses: maxUses ?? this.maxUses,
      minOrderAmount: minOrderAmount ?? this.minOrderAmount,
      maxDiscountAmount: maxDiscountAmount ?? this.maxDiscountAmount,
      startsAt: startsAt ?? this.startsAt,
      expiresAt: expiresAt ?? this.expiresAt,
      active: active ?? this.active,
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
    minOrderAmount,
    maxDiscountAmount,
    startsAt,
    expiresAt,
    active,
  ];
}
