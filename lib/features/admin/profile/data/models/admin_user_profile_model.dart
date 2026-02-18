import '../../domain/entities/admin_user_profile.dart';

class AdminUserProfileModel extends AdminUserProfile {
  const AdminUserProfileModel({
    required super.adminId,
    required super.username,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.phoneNumber,
    required super.role,
    required super.businessId,
    required super.notifyItemUpdates,
    required super.notifyUserFeedback,
    required super.createdAt,
    required super.updatedAt,
  });

  factory AdminUserProfileModel.fromJson(Map<String, dynamic> j) {
    int asInt(dynamic v, {int fallback = 0}) {
      if (v == null) return fallback;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString()) ?? fallback;
    }

    int? asIntNullable(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString());
    }

    bool? asBool(dynamic v) {
      if (v == null) return null;
      if (v is bool) return v;
      final s = v.toString().toLowerCase().trim();
      if (s == 'true') return true;
      if (s == 'false') return false;
      return null;
    }

    String asStr(dynamic v) => (v ?? '').toString();
    String? asStrNullable(dynamic v) {
      if (v == null) return null;
      final s = v.toString();
      return s.trim().isEmpty ? null : s;
    }

    return AdminUserProfileModel(
      adminId: asInt(j['adminId']),
      username: asStr(j['username']),
      firstName: asStr(j['firstName']),
      lastName: asStr(j['lastName']),
      email: asStr(j['email']),
      phoneNumber: asStr(j['phoneNumber']),
      role: asStr(j['role']),
      businessId: asIntNullable(j['businessId']),
      notifyItemUpdates: asBool(j['notifyItemUpdates']),
      notifyUserFeedback: asBool(j['notifyUserFeedback']),
      createdAt: asStrNullable(j['createdAt']),
      updatedAt: asStrNullable(j['updatedAt']),
    );
  }
}
