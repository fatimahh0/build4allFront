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

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    try {
      final lastRole = await _roleStore.getRole();

      final adminToken = await _adminStore.getToken();
      final userToken = await _userStore.getToken();
      final userWasInactive = await _userStore.getWasInactive();

      final adminValid =
          adminToken != null &&
          adminToken.isNotEmpty &&
          !JwtUtils.isExpired(adminToken);

      final userValid =
          userToken != null &&
          userToken.isNotEmpty &&
          !JwtUtils.isExpired(userToken);

      // ✅ IMPORTANT: if wasInactive == true, we do NOT auto-login
      final userAutoValid = userValid && !userWasInactive;

      // cleanup expired
      if (adminToken != null && !adminValid) await _adminStore.clear();
      if (userToken != null && !userValid) await _userStore.clear();

      if (!mounted) return;

      // ✅ KEY FIX: whenever we will enter user flow, set global auth token
      if (userAutoValid) {
        g.setAuthToken(userToken!);
      }

      // both valid & no lastRole -> choose
      if (adminValid && userAutoValid && lastRole == null) {
        setState(() => _loading = false);
        await _askRoleAndGo(adminToken!, userToken!);
        return;
      }

      // prefer last role
      if (lastRole == 'admin' && adminValid) {
        _goAdmin();
        return;
      }
      if (lastRole == 'user' && userAutoValid) {
        _hydrateUserAndGo(userToken!);
        return;
      }

      // fallback priority
      if (adminValid) {
        _goAdmin();
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

  Future<void> _askRoleAndGo(String adminToken, String userToken) async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 6),
              const Text(
                'Continue as…',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.verified_user_outlined),
                title: const Text('Admin / Owner'),
                onTap: () => Navigator.pop(ctx, 'admin'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('User'),
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
      _goAdmin();
    } else if (choice == 'user') {
      await _roleStore.saveRole('user');

      // ✅ set global token before entering
      g.setAuthToken(userToken);

      _hydrateUserAndGo(userToken);
    } else {
      _goLogin();
    }
  }

  void _hydrateUserAndGo(String token) {
    // we don't need user object here for routing. token is enough for auth requests.
    context.read<AuthBloc>().add(
      AuthLoginHydrated(user: null, token: token, wasInactive: false),
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => MainShell(appConfig: widget.appConfig)),
    );
  }

  void _goAdmin() {
    Navigator.of(context).pushNamedAndRemoveUntil('/admin', (_) => false);
  }

  void _goLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => UserLoginScreen(appConfig: widget.appConfig),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return const Scaffold(body: SizedBox.shrink());
  }
}
