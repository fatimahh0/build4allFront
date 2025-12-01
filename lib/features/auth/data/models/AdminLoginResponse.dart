class AdminLoginResponse {
  final String token;
  final String role; // SUPER_ADMIN / OWNER / MANAGER
  final Map<String, dynamic> admin;

  const AdminLoginResponse({
    required this.token,
    required this.role,
    required this.admin,
  });
}
