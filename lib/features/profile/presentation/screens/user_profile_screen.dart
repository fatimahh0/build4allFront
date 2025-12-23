import 'package:build4front/app/app_router.dart';
import 'package:build4front/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:build4front/features/cart/presentation/bloc/cart_event.dart';
import 'package:build4front/features/profile/presentation/screens/privacy_policy_screen.dart';
import 'package:build4front/features/profile_edit/presentation/screens/edit_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4front/l10n/app_localizations.dart';
import 'package:build4front/core/network/globals.dart' as g;
import 'package:build4front/core/utils/jwt_utils.dart';
import 'package:build4front/features/auth/data/services/auth_token_store.dart';

// ✅ Auth bloc patch imports
import 'package:build4front/features/auth/presentation/login/bloc/auth_bloc.dart';
import 'package:build4front/features/auth/presentation/login/bloc/auth_event.dart';

import 'package:build4front/features/profile/presentation/bloc/user_profile_bloc.dart';
import 'package:build4front/features/profile/presentation/bloc/user_profile_event.dart';
import 'package:build4front/features/profile/presentation/bloc/user_profile_state.dart';

import 'package:build4front/features/profile/presentation/widgets/user_profile_header.dart';
import 'package:build4front/features/profile/presentation/widgets/deactivate_user_dialog.dart';

class UserProfileScreen extends StatefulWidget {
  final String token;
  final int userId;
  final void Function(Locale) onChangeLocale;
  final VoidCallback onLogout;

  const UserProfileScreen({
    super.key,
    required this.token,
    required this.userId,
    required this.onChangeLocale,
    required this.onLogout,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with WidgetsBindingObserver {
  final AuthTokenStore _store = const AuthTokenStore();

  bool _hydrating = true;

  String _effectiveToken = '';
  int _effectiveUserId = 0;

  String _lastToken = '';
  int _lastUserId = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _hydrateSession();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _resetSessionUi() {
    // ✅ wipe cart UI state (does NOT delete server cart)
    context.read<CartBloc>().add(const CartReset());

    // optional: reset other blocs if you have them (orders, favorites, etc.)
    // context.read<OrdersBloc>().add(const OrdersReset());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _hydrateSession();
    }
  }

  String _firstNonEmpty(List<String> values) {
    for (final v in values) {
      final s = v.trim();
      if (s.isNotEmpty) return s;
    }
    return '';
  }

  String _stripBearer(String t) {
    final s = t.trim();
    if (s.toLowerCase().startsWith('bearer ')) return s.substring(7).trim();
    return s;
  }

  Future<void> _hydrateSession() async {
    setState(() => _hydrating = true);

    final tWidget = widget.token.trim();
    final tGlobal = g.readAuthToken().trim();
    final tStored = (await _store.getToken())?.trim() ?? '';

    final tokenFull = _firstNonEmpty([tWidget, tGlobal, tStored]);
    final tokenRaw = _stripBearer(tokenFull);

    int id = widget.userId;

    if (id <= 0 && tokenRaw.isNotEmpty) {
      id = JwtUtils.userIdFromToken(tokenRaw) ?? 0;
    }

    if (id <= 0) {
      final storedId = await _store.getUserId();
      if (storedId > 0) id = storedId;
    }

    if (id <= 0) {
      final uj = await _store.getUserJson();
      final v = uj?['id'];
      if (v is num) id = v.toInt();
      if (v is String) id = int.tryParse(v.trim()) ?? 0;
    }

    if (tokenFull.isNotEmpty) {
      g.setAuthToken(tokenFull);
    }

    if (!mounted) return;

    setState(() {
      _effectiveToken = tokenRaw;
      _effectiveUserId = id;
      _hydrating = false;
    });

    _kickLoadIfNeeded();
  }

  void _kickLoadIfNeeded() {
    final token = _effectiveToken.trim();
    final id = _effectiveUserId;

    if (token.isEmpty || id <= 0) return;
    if (token == _lastToken && id == _lastUserId) return;

    _lastToken = token;
    _lastUserId = id;

    context.read<UserProfileBloc>().add(LoadUserProfile(token, id));
  }

  void _goToLogin(BuildContext context) {
    _resetSessionUi();
    widget.onLogout();
    Navigator.pushNamedAndRemoveUntil(context, AppRouter.startup, (_) => false);
  }

  /// ✅ Patch AuthBloc from the profile dto we already have (most reliable).
  void _patchAuthFromProfileDto(dynamic userDto) {
    // userDto is state.user from UserProfileLoaded (your ProfileUserDto most likely)
    // We read only fields we know exist in your dto.
    try {
      final firstName = (userDto.firstName as String?)?.trim();
      final lastName = (userDto.lastName as String?)?.trim();
      final username = (userDto.username as String?)?.trim(); // if exists
      final profileUrl = (userDto.profileImageUrl as String?)
          ?.trim(); // your dto uses this
      final isPublic = (userDto.publicProfile as bool?);
      final statusName = (userDto.statusName as String?)?.trim();

      context.read<AuthBloc>().add(
        AuthUserPatched(
          firstName: firstName,
          lastName: lastName,
          username: username,
          profilePictureUrl: profileUrl,
          isPublicProfile: isPublic,
          status: statusName,
        ),
      );
    } catch (_) {
      // If dto shape differs, no crash. We still refresh profile UI anyway.
    }
  }

  // ✅ go to edit + refresh after pop + PATCH AuthBloc so HomeHeader updates
  Future<void> _goToEditProfile(
    BuildContext context,
    int ownerProjectLinkId,
  ) async {
    // We don't rely on return value. Some edit screens return nothing.
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(
          userId: _effectiveUserId,
          token: _effectiveToken,
          ownerProjectLinkId: ownerProjectLinkId,
        ),
      ),
    );

    if (!mounted) return;

    // ✅ refresh profile screen data
    context.read<UserProfileBloc>().add(
      LoadUserProfile(_effectiveToken, _effectiveUserId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;

    if (_hydrating) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_effectiveToken.isEmpty || _effectiveUserId <= 0) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline, size: 48),
                const SizedBox(height: 12),
                Text(
                  tr.profileLoginRequired,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => _goToLogin(context),
                  icon: const Icon(Icons.login),
                  label: Text(tr.login),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return BlocConsumer<UserProfileBloc, UserProfileState>(
      listener: (context, state) {
        // ✅ When profile reloads after edit, patch AuthBloc immediately
        if (state is UserProfileLoaded) {
          _patchAuthFromProfileDto(state.user);
        }
      },
      builder: (context, state) {
        if (state is UserProfileLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is UserProfileError) {
          final theme = Theme.of(context);
          final msg = state.message.toLowerCase();

          final loginRequired =
              msg.contains('unauthorized') ||
              msg.contains('401') ||
              msg.contains('please log in') ||
              msg.contains('please login');

          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      loginRequired
                          ? Icons.lock_outline
                          : Icons.person_off_outlined,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      loginRequired ? tr.sessionExpired : tr.profile_load_error,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: loginRequired
                          ? () => _goToLogin(context)
                          : () => context.read<UserProfileBloc>().add(
                              LoadUserProfile(
                                _effectiveToken,
                                _effectiveUserId,
                              ),
                            ),
                      icon: Icon(loginRequired ? Icons.login : Icons.refresh),
                      label: Text(loginRequired ? tr.login : tr.retry),
                    ),
                    const SizedBox(height: 8),
                    if (state.message.isNotEmpty)
                      Text(
                        state.message,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }

        if (state is UserProfileLoaded) {
          final user = state.user;
          final theme = Theme.of(context);

          // ✅ ownerProjectLinkId from profile dto
          final ownerId = user.ownerProjectLinkId;

          return Scaffold(
            backgroundColor: theme.colorScheme.background,
            appBar: AppBar(),
            body: SafeArea(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                children: [
                  UserProfileHeader(user: user),
                  const SizedBox(height: 16),

                  _tile(
                    context,
                    icon: Icons.edit,
                    title: tr.editProfileTitle,
                    onTap: () => _goToEditProfile(context, ownerId),
                  ),

                  _tile(
                    context,
                    icon: Icons.language,
                    title: tr.language,
                    onTap: () => _showLanguageSelector(context),
                  ),

                  _tile(
                    context,
                    icon: Icons.receipt_long_outlined,
                    title: tr.ordersTitle,
                    onTap: () =>
                        Navigator.pushNamed(context, AppRouter.myOrders),
                  ),

                  _tile(
                    context,
                    icon: Icons.privacy_tip,
                    title: tr.privacy_policy_title,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PrivacyPolicyScreen(),
                        ),
                      );
                    },
                  ),

                  _tile(
                    context,
                    icon: Icons.logout,
                    title: tr.logout,
                    onTap: () => _confirmLogout(context),
                  ),

                  const SizedBox(height: 8),

                  ExpansionTile(
                    leading: const Icon(Icons.settings),
                    title: Text(tr.manageAccount),
                    children: [
                      _tile(
                        context,
                        icon: Icons.visibility,
                        title: (user.isPublicProfile ?? true)
                            ? tr.profileMakePrivate
                            : tr.profileMakePublic,
                        onTap: () => context.read<UserProfileBloc>().add(
                          ToggleVisibilityPressed(
                            _effectiveToken,
                            !(user.isPublicProfile ?? true),
                          ),
                        ),
                      ),
                      _tile(
                        context,
                        icon: Icons.power_settings_new,
                        title: tr.setInactive,
                        onTap: () async {
                          final ok = await showDialog<bool>(
                            context: context,
                            barrierDismissible: false,
                            builder: (ctx) => DeactivateUserDialog(
                              token: _effectiveToken,
                              userId: _effectiveUserId,
                            ),
                          );
                          if (ok == true) {
                            _resetSessionUi();
                            widget.onLogout();
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }

        // if bloc didn't load yet, trigger it once
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _kickLoadIfNeeded(),
        );
        return const Scaffold(body: SizedBox.shrink());
      },
    );
  }

  Widget _tile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon),
          title: Text(title),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),

        const Divider(height: 1),
      ],
    );
  }

  void _showLanguageSelector(BuildContext context) {
    final tr = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              onTap: () {
                Navigator.pop(ctx);
                widget.onChangeLocale(const Locale('en'));
              },
            ),
            ListTile(
              title: const Text('Français'),
              onTap: () {
                Navigator.pop(ctx);
                widget.onChangeLocale(const Locale('fr'));
              },
            ),
            ListTile(
              title: const Text('العربية'),
              onTap: () {
                Navigator.pop(ctx);
                widget.onChangeLocale(const Locale('ar'));
              },
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                tr.language_note,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final tr = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr.logout),
        content: Text(tr.profileLogoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              tr.cancel,
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(tr.confirm),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _resetSessionUi();
      widget.onLogout();
    }
  }
}
