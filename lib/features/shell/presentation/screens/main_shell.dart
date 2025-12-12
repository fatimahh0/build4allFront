// lib/features/shell/presentation/screens/main_shell.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/config/home_config.dart';

import 'package:build4front/l10n/app_localizations.dart';

// Home + Explore
import '../../../home/presentation/screens/home_screen.dart';
import '../../../home/presentation/screens/placeholder_screen.dart';
import '../../../explore/presentation/screens/explore_screen.dart';

// Auth
import 'package:build4front/features/auth/presentation/login/bloc/auth_bloc.dart';
import 'package:build4front/features/auth/presentation/login/bloc/auth_state.dart';
import 'package:build4front/features/auth/data/repository/auth_repository_impl.dart';
import 'package:build4front/features/auth/presentation/login/screens/user_login_screen.dart';

// Profile screen
import 'package:build4front/features/profile/presentation/screens/user_profile_screen.dart';

// Profile feature wiring (service → repo → usecases → bloc)
import 'package:build4front/features/profile/presentation/bloc/user_profile_bloc.dart';
import 'package:build4front/features/profile/presentation/bloc/user_profile_event.dart';
import 'package:build4front/features/profile/presentation/bloc/user_profile_state.dart';
import 'package:build4front/features/profile/domain/usecases/get_user_profile.dart';
import 'package:build4front/features/profile/domain/usecases/toggle_user_visibility.dart';
import 'package:build4front/features/profile/domain/usecases/update_user_status.dart';
import 'package:build4front/features/profile/data/services/user_profile_service.dart';
import 'package:build4front/features/profile/data/repositories/user_profile_repository_impl.dart';

// ✅ Cart screen
import 'package:build4front/features/cart/presentation/screens/cart_screen.dart';

class MainShell extends StatefulWidget {
  final AppConfig appConfig;

  const MainShell({super.key, required this.appConfig});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  late final List<NavItemView> _tabs;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    // Build tabs from appConfig.navigation
    final navItems = widget.appConfig.navigation;

    // Ensure there's at least one tab
    if (navItems.isEmpty) {
      _tabs = [
        NavItemView(id: 'home', label: 'Home', icon: Icons.home_rounded),
      ];
    } else {
      _tabs = navItems
          .map(
            (n) => NavItemView(
              id: n.id,
              label: n.label,
              icon: _mapIconName(n.icon),
            ),
          )
          .toList();
    }

    // Home sections config (from dynamic HOME_JSON_B64 or defaults)
    final homeSections = HomeConfigLoader.loadSections(widget.appConfig);

    // Map each tab id → actual screen
    _pages = _tabs.map((tab) {
      switch (tab.id) {
        case 'home':
          return HomeScreen(
            appConfig: widget.appConfig,
            sections: homeSections,
          );

        case 'explore':
          return ExploreScreen(appConfig: widget.appConfig);

        case 'cart': // ✅ Cart tab
          return const CartScreen();

        case 'profile':
          // Profile tab wrapper (no appConfig passed here anymore)
          return const _ProfileTabShell();

        // later: map 'items', 'orders', 'chat', ... to real screens
        default:
          return PlaceholderScreen(title: tab.label);
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;

    final body = IndexedStack(index: _currentIndex, children: _pages);

    // If there is only ONE tab, do NOT show BottomNavigationBar
    if (_tabs.length < 2) {
      return Scaffold(body: body);
    }

    // Normal case: 2+ tabs → show bottom navigation
    return Scaffold(
      body: body,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: c.primary,
        unselectedItemColor: c.onSurface.withOpacity(0.6),
        showUnselectedLabels: true,
        items: _tabs
            .map(
              (t) =>
                  BottomNavigationBarItem(icon: Icon(t.icon), label: t.label),
            )
            .toList(),
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

 IconData _mapIconName(String name) {
    switch (name.toLowerCase()) {
      case 'home':
        return Icons.home_rounded;

      case 'search':
      case 'explore':
        return Icons.search_rounded;

      // ✅ profile
      case 'user':
      case 'person':
      case 'profile':
        return Icons.person_rounded;

      // ✅ cart
      case 'bag':
      case 'cart':
      case 'shopping_cart':
      case 'shopping-bag':
      case 'shopping_bag':
        return Icons.shopping_bag_rounded;

      case 'ticket':
        return Icons.confirmation_num_rounded;

      case 'chat':
        return Icons.chat_bubble_outline_rounded;

      default:
        return Icons
            .help_outline_rounded;
    }
  }

}

class NavItemView {
  final String id;
  final String label;
  final IconData icon;

  NavItemView({required this.id, required this.label, required this.icon});
}

/// ===============================
///  Profile tab wrapper
/// ===============================
///
/// - Reads AuthBloc to get user / isLoggedIn
/// - Provides UserProfileBloc (service → repo → usecases → bloc)
/// - Shows login hint if user not logged in
///
class _ProfileTabShell extends StatelessWidget {
  const _ProfileTabShell();

  /// Centralized logout:
  /// - clear user token from secure storage + globals
  /// - navigate back to UserLoginScreen and clear navigation stack
  Future<void> _handleLogout(BuildContext context) async {
    final authRepo = context.read<AuthRepositoryImpl>();

    // 1) clear user token (+ global header)
    await authRepo.api.clearAuth();
    debugPrint('🔓 Auth cleared: token removed from storage and globals');

    // 2) rebuild AppConfig from env for the login screen
    final appConfig = AppConfig.fromEnv();

    // 3) navigate to login and remove all previous routes
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => UserLoginScreen(appConfig: appConfig)),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final user = authState.user;
    final token = authState.token;
    final tr = AppLocalizations.of(context)!;

    // -----------------------
    // 1. Not logged in
    // -----------------------
    if (!authState.isLoggedIn || user == null || token == null) {
      return Scaffold(body: Center(child: Text(tr.profile_login_required)));
    }

    // -----------------------
    // 2. Provide Service → Repo → Bloc
    // -----------------------
    return RepositoryProvider<UserProfileService>(
      create: (_) => UserProfileService(),
      child: Builder(
        builder: (context) {
          final service = context.read<UserProfileService>();
          final repo = UserProfileRepositoryImpl(service);

          return MultiBlocProvider(
            providers: [
              BlocProvider<UserProfileBloc>(
                create: (_) => UserProfileBloc(
                  getUser: GetUserProfile(repo),
                  toggleVisibility: ToggleUserVisibility(repo),
                  updateStatus: UpdateUserStatus(repo),
                )..add(LoadUserProfile(token, user.id)), // auto load profile
              ),
            ],
            child: UserProfileScreen(
              token: token,
              userId: user.id,
              onChangeLocale: (_) {
                // wire locale switching later if needed
              },
              onLogout: () => _handleLogout(context), // ✅ REAL LOGOUT
            ),
          );
        },
      ),
    );
  }
}
