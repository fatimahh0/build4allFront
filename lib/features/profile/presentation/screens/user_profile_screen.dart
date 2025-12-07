// lib/features/profile/presentation/screens/user_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4front/l10n/app_localizations.dart';

import 'package:build4front/features/profile/presentation/bloc/user_profile_bloc.dart';
import 'package:build4front/features/profile/presentation/bloc/user_profile_event.dart';
import 'package:build4front/features/profile/presentation/bloc/user_profile_state.dart';

import 'package:build4front/features/profile/presentation/widgets/user_profile_header.dart';
import 'package:build4front/features/profile/presentation/widgets/deactivate_user_dialog.dart';

class UserProfileScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;

    // ensure load (simple + dirty but fine for now)
    context.read<UserProfileBloc>().add(LoadUserProfile(token, userId));

    return BlocBuilder<UserProfileBloc, UserProfileState>(
      builder: (context, state) {
        if (state is UserProfileLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is UserProfileError) {
          final theme = Theme.of(context);
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.person_off_outlined, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      tr.profile_load_error,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () => context.read<UserProfileBloc>().add(
                        LoadUserProfile(token, userId),
                      ),
                      icon: const Icon(Icons.refresh),
                      label: Text(tr.retry),
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

          return Scaffold(
            backgroundColor: theme.colorScheme.background,
            body: SafeArea(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                children: [
                  UserProfileHeader(user: user),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      tr.profileMotto,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ===== Simple menu tiles =====
                  _tile(
                    context,
                    icon: Icons.language,
                    title: tr.language,
                    onTap: () => _showLanguageSelector(context),
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
                            token,
                            !(user.isPublicProfile ?? true),
                          ),
                        ),
                      ),
                      _tile(
                        context,
                        icon: Icons.power_settings_new,
                        title: tr.setInactive,
                        onTap: () async {
                          // 🔴 THIS IS THE IMPORTANT PART
                          final ok = await showDialog<bool>(
                            context: context,
                            barrierDismissible: false,
                            builder: (ctx) => DeactivateUserDialog(
                              token: token,
                              userId: userId,
                            ),
                          );

                          // ✅ If backend accepted INACTIVE → log out
                          if (ok == true) {
                            onLogout();
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

        return const SizedBox.shrink();
      },
    );
  }

 
  /// Simple reusable ListTile builder for profile menu entries.
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

  /// Language bottom sheet
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
                onChangeLocale(const Locale('en'));
              },
            ),
            ListTile(
              title: const Text('Français'),
              onTap: () {
                Navigator.pop(ctx);
                onChangeLocale(const Locale('fr'));
              },
            ),
            ListTile(
              title: const Text('العربية'),
              onTap: () {
                Navigator.pop(ctx);
                onChangeLocale(const Locale('ar'));
              },
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                tr.language_note, // optional hint key
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Logout confirmation dialog
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
      onLogout();
    }
  }
}

/// Detect if the backend error is basically "login required".
bool _isLoginRequiredMessage(String raw) {
  final lower = raw.toLowerCase();
  return lower.contains('please login first') ||
      lower.contains('please log in first') ||
      lower.contains('unauthorized') ||
      lower.contains('401');
}

/// Map a raw error message to a user-friendly one.
String _mapErrorMessage(
  String raw,
  AppLocalizations tr, {
  required String fallback,
}) {
  if (_isLoginRequiredMessage(raw)) {
    // You can add this key in your ARB:
    // "profile_login_required": "Please log in to view your profile."
    return "";
  }

  // For other cases, just use the generic fallback text (e.g. "Could not load profile").
  return fallback;
}
