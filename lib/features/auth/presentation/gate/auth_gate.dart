// lib/features/auth/presentation/gate/auth_gate.dart
import 'package:build4front/core/config/env.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4front/core/config/app_config.dart';
import 'package:build4front/core/utils/jwt_utils.dart';
import 'package:build4front/core/network/globals.dart' as g;

import 'package:build4front/features/auth/data/services/admin_token_store.dart';
import 'package:build4front/features/auth/data/services/auth_token_store.dart';
import 'package:build4front/features/auth/data/services/session_role_store.dart';

import 'package:build4front/features/auth/presentation/login/bloc/auth_bloc.dart';
import 'package:build4front/features/auth/presentation/login/bloc/auth_event.dart';

import 'package:build4front/features/auth/presentation/login/screens/user_login_screen.dart';
import 'package:build4front/features/shell/presentation/screens/main_shell.dart';

import 'package:build4front/l10n/app_localizations.dart';

class AuthGate extends StatefulWidget {
  final AppConfig appConfig;
  const AuthGate({super.key, required this.appConfig});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _roleStore = SessionRoleStore();
  final _adminStore = AdminTokenStore();
  final _userStore = AuthTokenStore();

  bool _loading = true;

  bool _appBlocked = false;
  String _blockReason = '';
  String _serverBlockMessage = '';

  @override
  void initState() {
    super.initState();
    _boot();
  }

  // ---------- helpers ----------
  String _stripBearer(String? t) {
    final v = (t ?? '').trim();
    if (v.toLowerCase().startsWith('bearer ')) return v.substring(7).trim();
    return v;
  }

  /// ✅ TENANT must be ownerProjectLinkId (AUP link id)
  String _currentTenantId() => (Env.ownerProjectLinkId ?? '').trim();

  Future<void> _logoutAll() async {
    await _userStore.clear();
    await _adminStore.clear();
    await _roleStore.clear();
    g.setAuthToken('');
  }

  Future<void> _enforceTenantMatchOrLogout() async {
    final current = _currentTenantId();
    if (current.isEmpty) return; // fail-open if not configured

    final savedUser = (await _userStore.getTenantId())?.trim() ?? '';
    final savedAdmin = (await _adminStore.getTenantId())?.trim() ?? '';

    final mismatchUser = savedUser.isNotEmpty && savedUser != current;
    final mismatchAdmin = savedAdmin.isNotEmpty && savedAdmin != current;

    if (mismatchUser || mismatchAdmin) {
      await _logoutAll();
    }
  }

  /* ========================= Public app access check ========================= */

  Future<bool> _checkPublicAppAccess() async {
    // ✅ MUST be tenant link id (ownerProjectLinkId)
    final linkId = int.tryParse(_currentTenantId());
    if (linkId == null) return true; // fail-open

    try {
      final res = await g.dio().get('/api/public/app-access/$linkId');
      final data = (res.data is Map)
          ? Map<String, dynamic>.from(res.data as Map)
          : <String, dynamic>{};

      final allowed = data['allowed'] == true;

      if (!allowed) {
        if (!mounted) return false;
        setState(() {
          _appBlocked = true;
          _blockReason = (data['reason'] ?? '').toString();
          _serverBlockMessage = (data['message'] ?? '').toString();
          _loading = false;
        });
        return false;
      }

      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 410) {
        final raw = e.response?.data;
        final data = (raw is Map) ? Map<String, dynamic>.from(raw) : <String, dynamic>{};

        if (!mounted) return false;
        setState(() {
          _appBlocked = true;
          _blockReason = (data['reason'] ?? 'APP_NOT_AVAILABLE').toString();
          _serverBlockMessage = (data['message'] ?? '').toString();
          _loading = false;
        });
        return false;
      }
      return true; // fail-open on network problems
    } catch (_) {
      return true;
    }
  }

  /* ========================= Refresh helpers ========================= */

  Future<String?> _tryRefreshUserIfNeeded({
    required String? tokenStored,
    required bool userWasInactive,
  }) async {
    if (userWasInactive) return null;

    final refresh = (await _userStore.getRefreshToken())?.trim() ?? '';
    if (refresh.isEmpty) return null;

    final raw = _stripBearer(tokenStored);
    if (raw.isNotEmpty && !JwtUtils.isExpired(raw)) return raw;

    try {
      final res = await g.dio().post('/api/auth/refresh', data: {'refreshToken': refresh});
      final data = (res.data is Map) ? Map<String, dynamic>.from(res.data as Map) : <String, dynamic>{};

      final newAccess = _stripBearer((data['token'] ?? '').toString());
      final newRefresh = (data['refreshToken'] ?? '').toString().trim();
      if (newAccess.isEmpty || newRefresh.isEmpty) return null;

      await _userStore.saveToken(
        token: newAccess,
        wasInactive: false,
        refreshToken: newRefresh,
        tenantId: _currentTenantId(),
      );

      return newAccess;
    } catch (_) {
      await _userStore.clear();
      return null;
    }
  }

  Future<String?> _tryRefreshAdminIfNeeded({required String? tokenStored}) async {
    final refresh = (await _adminStore.getRefreshToken())?.trim() ?? '';
    if (refresh.isEmpty) return null;

    final raw = _stripBearer(tokenStored);
    if (raw.isNotEmpty && !JwtUtils.isExpired(raw)) return raw;

    try {
      final res = await g.dio().post('/api/auth/refresh', data: {'refreshToken': refresh});
      final data = (res.data is Map) ? Map<String, dynamic>.from(res.data as Map) : <String, dynamic>{};

      final newAccess = _stripBearer((data['token'] ?? '').toString());
      final newRefresh = (data['refreshToken'] ?? '').toString().trim();
      if (newAccess.isEmpty || newRefresh.isEmpty) return null;

      final role = (await _adminStore.getRole()) ?? '';

      await _adminStore.save(
        token: newAccess,
        role: role,
        refreshToken: newRefresh,
        tenantId: _currentTenantId(),
      );

      return newAccess;
    } catch (_) {
      await _adminStore.clear();
      return null;
    }
  }

  /* ========================= Boot ========================= */

  Future<void> _boot() async {
    try {
      final canOpen = await _checkPublicAppAccess();
      if (!canOpen) return;

      await _enforceTenantMatchOrLogout();

      final lastRole = await _roleStore.getRole();

      final adminStored = (await _adminStore.getToken())?.trim();
      final userStored = (await _userStore.getToken())?.trim();
      final userWasInactive = await _userStore.getWasInactive();

      final adminToken = await _tryRefreshAdminIfNeeded(tokenStored: adminStored);
      final userToken = await _tryRefreshUserIfNeeded(
        tokenStored: userStored,
        userWasInactive: userWasInactive,
      );

      final adminValid = adminToken != null && adminToken.isNotEmpty && !JwtUtils.isExpired(adminToken);
      final userValid = userToken != null && userToken.isNotEmpty && !JwtUtils.isExpired(userToken);
      final userAutoValid = userValid && !userWasInactive;

      if (!adminValid) await _adminStore.clear();
      if (!userValid) await _userStore.clear();

      if (!mounted) return;

      // BOTH valid and no last role -> ask
      if (adminValid && userAutoValid && (lastRole == null || lastRole.trim().isEmpty)) {
        setState(() => _loading = false);
        await _askRoleAndGo(adminToken!, userToken!);
        return;
      }

      // prefer last role
      if (lastRole == 'admin' && adminValid) {
        _goAdminWithToken(adminToken!);
        return;
      }
      if (lastRole == 'user' && userAutoValid) {
        _hydrateUserAndGo(userToken!);
        return;
      }

      // fallback priority
      if (adminValid) {
        _goAdminWithToken(adminToken!);
        return;
      }
      if (userAutoValid) {
        _hydrateUserAndGo(userToken!);
        return;
      }

      _goLogin();
    } catch (_) {
      if (!mounted) return;
      _goLogin();
    }
  }

  /* ========================= Routing ========================= */

  Future<void> _askRoleAndGo(String adminToken, String userToken) async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final bl10n = AppLocalizations.of(ctx)!;
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 6),
              Text(
                bl10n.authGateContinueAs,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.verified_user_outlined),
                title: Text(bl10n.authGateRoleAdminOwner),
                onTap: () => Navigator.pop(ctx, 'admin'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(bl10n.authGateRoleUser),
                onTap: () => Navigator.pop(ctx, 'user'),
              ),
            ],
          ),
        );
      },
    );

    if (!mounted) return;

    if (choice == 'admin') {
      await _roleStore.saveRole('admin');
      _goAdminWithToken(adminToken);
      return;
    }
    if (choice == 'user') {
      await _roleStore.saveRole('user');
      _hydrateUserAndGo(userToken);
      return;
    }

    _goLogin();
  }

  void _hydrateUserAndGo(String rawJwt) {
    g.setAuthToken(rawJwt);

    context.read<AuthBloc>().add(
          AuthLoginHydrated(user: null, token: rawJwt, wasInactive: false),
        );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => MainShell(appConfig: widget.appConfig)),
    );
  }

  void _goAdminWithToken(String rawJwt) {
    g.setAuthToken(rawJwt);
    Navigator.of(context).pushNamedAndRemoveUntil('/admin', (_) => false);
  }

  void _goLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => UserLoginScreen(appConfig: widget.appConfig),
      ),
    );
  }

  /* ========================= Blocked UI helpers ========================= */

  String _titleForReason(AppLocalizations l10n, String reason) {
    switch (reason) {
      case 'APP_DELETED':
        return l10n.appAccessTitleDeleted;
      case 'APP_EXPIRED':
        return l10n.appAccessTitleExpired;
      default:
        return l10n.appAccessTitleUnavailable;
    }
  }

  String _messageForReason(AppLocalizations l10n, String reason) {
    switch (reason) {
      case 'APP_DELETED':
        return l10n.appAccessMessageDeleted;
      case 'APP_EXPIRED':
        return l10n.appAccessMessageExpired;
      default:
        return l10n.appAccessMessageUnavailable;
    }
  }

  IconData _iconForReason(String reason) {
    switch (reason) {
      case 'APP_DELETED':
        return Icons.block_rounded;
      case 'APP_EXPIRED':
        return Icons.timer_off_rounded;
      default:
        return Icons.no_accounts_rounded;
    }
  }

  Widget _buildBlockedFullScreen() {
    final l10n = AppLocalizations.of(context)!;
    final title = _titleForReason(l10n, _blockReason);
    final message = _messageForReason(l10n, _blockReason);
    final icon = _iconForReason(_blockReason);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(24),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 20,
                      spreadRadius: 0,
                      offset: Offset(0, 8),
                      color: Color(0x1A000000),
                    ),
                  ],
                  border: Border.all(
                    color: Theme.of(context).dividerColor.withOpacity(0.25),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(radius: 34, child: Icon(icon, size: 34)),
                    const SizedBox(height: 16),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l10n.appAccessOwnerDisabledHint,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.75),
                      ),
                    ),
                    if (_serverBlockMessage.isNotEmpty &&
                        _serverBlockMessage.trim().toLowerCase() != message.trim().toLowerCase()) ...[
                      const SizedBox(height: 10),
                      Text(
                        _serverBlockMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.65),
                        ),
                      ),
                    ],
                    if (_blockReason.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: Theme.of(context).dividerColor.withOpacity(0.12),
                        ),
                        child: Text(
                          _blockReason,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          if (!mounted) return;
                          setState(() {
                            _loading = true;
                            _appBlocked = false;
                            _blockReason = '';
                            _serverBlockMessage = '';
                          });
                          await _boot();
                        },
                        icon: const Icon(Icons.refresh_rounded),
                        label: Text(l10n.appAccessRetry),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_appBlocked) return _buildBlockedFullScreen();

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return const Scaffold(body: SizedBox.shrink());
  }
}