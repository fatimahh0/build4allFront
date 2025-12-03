// lib/features/admin/dashboard/presentation/screens/admin_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4front/core/theme/app_theme_tokens.dart';
import 'package:build4front/core/theme/theme_cubit.dart';
import 'package:build4front/l10n/app_localizations.dart';
import 'package:build4front/core/config/env.dart';
import 'package:build4front/features/auth/data/services/admin_token_store.dart';

import 'package:build4front/features/admin/product/presentation/screens/admin_products_list_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _store = AdminTokenStore();
  String? _role;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final role = await _store.getRole();
    if (!mounted) return;
    setState(() => _role = role?.toUpperCase());
  }

  Future<void> _logout() async {
    await _store.clear();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tokens = context.watch<ThemeCubit>().state.tokens;
    final colors = tokens.colors;
    final card = tokens.card;

    final role = _role ?? 'ADMIN';

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        title: Text(
          l10n.adminDashboardTitle,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: colors.label,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: Icon(Icons.logout, color: colors.body),
            tooltip: l10n.logoutLabel,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _RoleBanner(role: role),
            const SizedBox(height: 20),
            Text(
              l10n.adminDashboardQuickActions,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colors.label,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _AdminTile(
                  icon: Icons.analytics_outlined,
                  title: l10n.adminOverviewAnalytics,
                  colors: colors,
                  card: card,
                  onTap: () {},
                ),
                _AdminTile(
                  icon: Icons.shopping_bag_outlined,
                  title: l10n.adminProductsTitle,
                  colors: colors,
                  card: card,
                  onTap: () {
                    final ownerId = int.tryParse(Env.ownerProjectLinkId) ?? 0;

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            AdminProductsListScreen(ownerProjectId: ownerId),
                      ),
                    );
                  },
                ),
                _AdminTile(
                  icon: Icons.store_mall_directory_outlined,
                  title: l10n.adminProjectsOwners,
                  colors: colors,
                  card: card,
                  onTap: () {
                    // TODO: owners/projects screen
                  },
                ),
                _AdminTile(
                  icon: Icons.group_outlined,
                  title: l10n.adminUsersManagers,
                  colors: colors,
                  card: card,
                  onTap: () {
                    // TODO: users & managers screen
                  },
                ),
                _AdminTile(
                  icon: Icons.settings_outlined,
                  title: l10n.adminSettings,
                  colors: colors,
                  card: card,
                  onTap: () {
                    // TODO: settings screen
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleBanner extends StatelessWidget {
  final String role;
  const _RoleBanner({required this.role});

  Color _roleColor(ColorTokens c) {
    switch (role) {
      case 'SUPER_ADMIN':
        return c.error;
      case 'OWNER':
        return c.primary;
      case 'MANAGER':
        return c.body;
      default:
        return c.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.watch<ThemeCubit>().state.tokens;
    final colors = tokens.colors;
    final c = _roleColor(colors);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.withOpacity(.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.withOpacity(.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: c.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.verified_user_outlined, color: c, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.adminSignedInAs(role),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colors.label,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final ColorTokens colors;
  final CardTokens card;

  const _AdminTile({
    required this.icon,
    required this.title,
    required this.onTap,
    required this.colors,
    required this.card,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return SizedBox(
      width: (MediaQuery.of(context).size.width - 16 * 2 - 12) / 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(card.radius),
        onTap: onTap,
        child: Ink(
          padding: EdgeInsets.all(card.padding),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(card.radius),
            border: card.showBorder
                ? Border.all(color: colors.border.withOpacity(0.2))
                : null,
            boxShadow: card.showShadow
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: card.elevation * 1.5,
                      offset: Offset(0, card.elevation.toDouble()),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: colors.primary, size: 24),
              const SizedBox(height: 10),
              Text(
                title,
                style: t.bodyMedium?.copyWith(
                  color: colors.label,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '',
                style: t.bodySmall?.copyWith(
                  color: colors.body.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
