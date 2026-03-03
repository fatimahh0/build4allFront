import 'package:build4front/core/exceptions/app_exception.dart';
import 'package:build4front/core/network/globals.dart' as g;
import 'package:build4front/features/auth/data/services/admin_token_store.dart';
import 'package:build4front/features/auth/data/services/auth_api_service.dart';
import 'package:build4front/features/auth/domain/entities/user_entity.dart';

class DualLoginResult {
  final bool adminOk;
  final bool userOk;

  final bool wasInactiveUser;
  final bool wasDeletedUser;
  final bool canRestoreDeletedUser;

  final String? adminToken;
  final String? adminRole;
  final Map<String, dynamic>? adminData;

  final UserEntity? userEntity;
  final String? userToken;

  final String? error;

  const DualLoginResult({
    required this.adminOk,
    required this.userOk,
    required this.wasInactiveUser,
    this.wasDeletedUser = false,
    this.canRestoreDeletedUser = false,
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

  DualLoginOrchestrator({
    required this.authApi,
    required this.adminStore,
  });

  String _stripBearer(String s) {
    final t = s.trim();
    if (t.toLowerCase().startsWith('bearer ')) return t.substring(7).trim();
    return t;
  }

  Future<DualLoginResult> login({
    required String identifier,
    required String password,
    required bool usePhoneForUser,
    required int ownerProjectLinkId,
  }) async {
    String? adminToken;
    String? adminRole;
    Map<String, dynamic>? adminData;

    UserEntity? userEntity;
    String? userToken;
    bool wasInactiveUser = false;

    bool wasDeletedUser = false;
    bool canRestoreDeletedUser = false;

    AppException? adminErr;
    AppException? userErr;

    // 1) ADMIN
    try {
      final adminRes = await authApi.adminLogin(
        usernameOrEmail: identifier,
        password: password,
        ownerProjectId: ownerProjectLinkId,
      );

      final cleanedToken = _stripBearer(adminRes.token);
      final cleanedRole = adminRes.role.trim();

      if (cleanedToken.isEmpty || cleanedRole.isEmpty) {
        throw AppException('Admin login returned empty token/role');
      }

      adminToken = cleanedToken;
      adminRole = cleanedRole;
      adminData = adminRes.admin;

      await adminStore.save(
        token: cleanedToken,
        role: cleanedRole,
        refreshToken: adminRes.refreshToken,
        tenantId: ownerProjectLinkId.toString(),
      );

      await const AdminTokenStore().debugDump();

      // make Dio use it immediately
      g.setAuthToken(cleanedToken);
    } catch (e) {
      adminErr = e is AppException ? e : AppException(e.toString());
    }

    // 2) USER
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

      wasInactiveUser = await authApi.getWasInactive();
      wasDeletedUser = await authApi.getWasDeletedUser();
      canRestoreDeletedUser = await authApi.getCanRestoreDeletedUser();
    } catch (e) {
      userErr = e is AppException ? e : AppException(e.toString());
      try {
        wasDeletedUser = await authApi.getWasDeletedUser();
        canRestoreDeletedUser = await authApi.getCanRestoreDeletedUser();
      } catch (_) {}
    }

    final adminOk = (adminToken ?? '').trim().isNotEmpty && (adminRole ?? '').trim().isNotEmpty;
    final userOk = userEntity != null;

    if (!adminOk && !userOk) {
      return DualLoginResult(
        adminOk: false,
        userOk: false,
        wasInactiveUser: false,
        wasDeletedUser: false,
        canRestoreDeletedUser: false,
        error: (userErr ?? adminErr)?.message ?? 'Login failed. Please try again.',
      );
    }

    return DualLoginResult(
      adminOk: adminOk,
      userOk: userOk,
      wasInactiveUser: userOk ? wasInactiveUser : false,
      wasDeletedUser: userOk ? wasDeletedUser : false,
      canRestoreDeletedUser: userOk ? canRestoreDeletedUser : false,
      adminToken: adminToken,
      adminRole: adminRole,
      adminData: adminData,
      userEntity: userEntity,
      userToken: userToken,
    );
  }
}