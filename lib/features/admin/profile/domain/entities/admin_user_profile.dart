class AdminUserProfile {
  final int adminId;
  final String username;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String role;
  final int? businessId;

  final bool? notifyItemUpdates;
  final bool? notifyUserFeedback;

  final String? createdAt;
  final String? updatedAt;

  const AdminUserProfile({
    required this.adminId,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.role,
    required this.businessId,
    required this.notifyItemUpdates,
    required this.notifyUserFeedback,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullName {
    final fn = firstName.trim();
    final ln = lastName.trim();
    return [fn, ln].where((e) => e.isNotEmpty).join(' ').trim();
  }
}
