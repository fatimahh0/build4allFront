import 'package:build4front/core/exceptions/app_exception.dart';
import 'package:build4front/features/auth/data/services/admin_token_store.dart';
import 'package:build4front/features/auth/data/services/auth_api_service.dart';
import 'package:build4front/features/auth/domain/entities/user_entity.dart';

class DualLoginResult {
  final bool adminOk;
  final bool userOk;

  final String? adminToken;
  final String? adminRole;
  final Map<String, dynamic>? adminData;

  final UserEntity? userEntity;
  final String? userToken;

  final String? error;

  const DualLoginResult({
    required this.adminOk,
    required this.userOk,
    this.adminToken,
    this.adminRole,
    this.adminData,
    this.userEntity,
    this.userToken,
    this.error,
  });

  bool get both => adminOk && userOk;
  bool get none => !adminOk && !userOk;
}

class DualLoginOrchestrator {
  final AuthApiService authApi;
  final AdminTokenStore adminStore;

  DualLoginOrchestrator({required this.authApi, required this.adminStore});

  Future<DualLoginResult> login({
    required String
    identifier, // email or phone (for user), email/username (for admin)
    required String password,
    required bool usePhoneForUser, // true → try user/phone endpoint
    required int ownerProjectLinkId,
  }) async {
    String? adminToken;
    String? adminRole;
    Map<String, dynamic>? adminData;

    UserEntity? userEntity;
    String? userToken;

    AppException? adminErr;
    AppException? userErr;

    // 1) Try ADMIN/OWNER/MANAGER
    try {
      final adminRes = await authApi.adminLogin(
        usernameOrEmail: identifier,
        password: password,
      );
      adminToken = adminRes.token;
      adminRole = adminRes.role;
      adminData = adminRes.admin;
      await adminStore.save(token: adminToken!, role: adminRole!);
    } catch (e) {
      adminErr = e is AppException ? e : AppException(e.toString());
    }

    // 2) Try USER
    try {
      final user = usePhoneForUser
          ? await authApi.loginWithPhone(
              phoneNumber: identifier,
              password: password,
              ownerProjectLinkId: ownerProjectLinkId,
            )
          : await authApi.loginWithEmail(
              email: identifier,
              password: password,
              ownerProjectLinkId: ownerProjectLinkId,
            );
      userEntity = user;
      userToken = await authApi.getSavedToken();
    } catch (e) {
      userErr = e is AppException ? e : AppException(e.toString());
    }

    final adminOk = adminToken != null && adminRole != null;
    final userOk = userEntity != null;

    if (!adminOk && !userOk) {
      return DualLoginResult(
        adminOk: false,
        userOk: false,
        error:
            (userErr ?? adminErr)?.message ?? 'Login failed. Please try again.',
      );
    }

    return DualLoginResult(
      adminOk: adminOk,
      userOk: userOk,
      adminToken: adminToken,
      adminRole: adminRole,
      adminData: adminData,
      userEntity: userEntity,
      userToken: userToken,
    );
  }
}
