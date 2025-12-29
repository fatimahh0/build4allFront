class AdminLoginResponse {
  final String token;
  final String role; // SUPER_ADMIN / OWNER / MANAGER
  final Map<String, dynamic> admin;

  // ✅ NEW: which AdminUserProject (AUP) this admin session belongs to
  final int? ownerProjectId;

  const AdminLoginResponse({
    required this.token,
    required this.role,
    required this.admin,
    this.ownerProjectId,
  });

  factory AdminLoginResponse.fromJson(Map<String, dynamic> j) {
    int? toInt(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString());
    }

    return AdminLoginResponse(
      token: (j['token'] ?? '').toString(),
      role: (j['role'] ?? '').toString(),
      admin: (j['admin'] as Map?)?.cast<String, dynamic>() ?? {},
      ownerProjectId: toInt(j['ownerProjectId']),
    );
  }
}
