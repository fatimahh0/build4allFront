class AdminLoginResponse {
  final String token;
  final String refreshToken;
  final String role; // SUPER_ADMIN / OWNER / MANAGER
  final Map<String, dynamic> admin;

  // which AUP / tenant this session belongs to (optional)
  final int? ownerProjectId;

  const AdminLoginResponse({
    required this.token,
    required this.refreshToken,
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

    // ✅ Support wrapped payload: { message, data: {...} }
    Map<String, dynamic> data = j;
    final d1 = j['data'];
    if (d1 is Map) {
      data = Map<String, dynamic>.from(d1 as Map);

      // Sometimes nested again: { message, data: { data: {...} } }
      final d2 = data['data'];
      if (d2 is Map) {
        data = Map<String, dynamic>.from(d2 as Map);
      }
    }

    String pickToken(Map<String, dynamic> m) {
      return (m['token'] ??
              m['accessToken'] ??
              m['jwt'] ??
              m['access_token'] ??
              '')
          .toString();
    }

    String pickRefresh(Map<String, dynamic> m) {
      return (m['refreshToken'] ??
              m['refresh_token'] ??
              m['refresh'] ??
              '')
          .toString();
    }

    String pickRole(Map<String, dynamic> m) {
      return (m['role'] ?? m['adminRole'] ?? m['type'] ?? '').toString();
    }

    Map<String, dynamic> pickAdmin(Map<String, dynamic> m) {
      final a = m['admin'] ?? m['user'] ?? m['owner'] ?? m['profile'];
      return (a is Map) ? Map<String, dynamic>.from(a as Map) : <String, dynamic>{};
    }

    return AdminLoginResponse(
      token: pickToken(data),
      refreshToken: pickRefresh(data),
      role: pickRole(data),
      admin: pickAdmin(data),
      ownerProjectId: toInt(data['ownerProjectId'] ?? j['ownerProjectId']),
    );
  }
}