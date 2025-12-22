// lib/features/admin/product/presentation/screens/admin_dashboard_screen.dart

import 'package:build4front/features/admin/home_banner/presentation/screens/admin_home_banners_screen.dart';
import 'package:build4front/features/admin/orders_admin/data/repository/admin_orders_repository_impl.dart';
import 'package:build4front/features/admin/orders_admin/data/services/admin_orders_api_service.dart';
import 'package:build4front/features/admin/orders_admin/domain/repositories/admin_orders_repository.dart';
import 'package:build4front/features/admin/orders_admin/orders_admin_feature.dart';
import 'package:build4front/features/admin/payment_config/presentation/screens/owner_payment_config_screen.dart';
import 'package:build4front/features/admin/shipping/prensentation/screens/admin_shipping_methods_screen.dart';
import 'package:build4front/features/admin/tax/presentation/screens/admin_tax_rules_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4front/core/theme/theme_cubit.dart';
import 'package:build4front/l10n/app_localizations.dart';
import 'package:build4front/core/config/env.dart';
import 'package:build4front/features/auth/data/services/admin_token_store.dart';

import 'package:build4front/features/admin/product/presentation/screens/admin_products_list_screen.dart';

// 🔹 NEW: Coupons imports
import 'package:build4front/features/admin/coupons/presentations/screens/admin_coupons_screen.dart';
import 'package:build4front/features/admin/coupons/presentations/bloc/coupon_bloc.dart';
import 'package:build4front/features/admin/coupons/data/services/coupon_api_service.dart';
import 'package:build4front/features/admin/coupons/data/repositories/coupon_repository_impl.dart';
import 'package:build4front/features/admin/coupons/domain/usecases/get_coupons.dart';
import 'package:build4front/features/admin/coupons/domain/usecases/save_coupon.dart';
import 'package:build4front/features/admin/coupons/domain/usecases/delete_coupon.dart';

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

                // ✅ SHIPPING TILE
                _AdminTile(
                  icon: Icons.local_shipping_outlined,
                  title: l10n.adminShippingTitle,
                  colors: colors,
                  card: card,
                  onTap: () {
                    final ownerId = int.tryParse(Env.ownerProjectLinkId) ?? 0;
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            AdminShippingMethodsScreen(ownerProjectId: ownerId),
                      ),
                    );
                  },
                ),

              // PAYMENT CONFIG TILE
                _AdminTile(
                  icon: Icons.credit_card_outlined,
                  title: l10n.adminPaymentConfigTitle,
                  colors: colors,
                  card: card,
                  onTap: () {
                   final ownerId = int.tryParse(Env.ownerProjectLinkId) ?? 0;

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => OwnerPaymentConfigScreen(
                          ownerProjectId: ownerId,
                          //  use admin token store (same as coupons)
                          getToken: () => _store.getToken(),
                        ),
                      ),
                    );
                  },
                ),


                // TAXES TILE
                _AdminTile(
                  icon: Icons.receipt_long_outlined,
                  title: l10n.adminTaxesTitle,
                  colors: colors,
                  card: card,
                  onTap: () {
                    final ownerId = int.tryParse(Env.ownerProjectLinkId) ?? 0;
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            AdminTaxRulesScreen(ownerProjectId: ownerId),
                      ),
                    );
                  },
                ),

                //  HOME BANNERS TILE
                _AdminTile(
                  icon: Icons.view_carousel_outlined,
                  title: l10n.adminHomeBannersTitle,
                  colors: colors,
                  card: card,
                  onTap: () {
                    final ownerId = int.tryParse(Env.ownerProjectLinkId) ?? 0;
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            AdminHomeBannersScreen(ownerProjectId: ownerId),
                      ),
                    );
                  },
                ),

                //  NEW: COUPONS TILE (with BlocProvider)
                _AdminTile(
                  icon: Icons.card_giftcard_outlined,
                  title: l10n.adminCouponsTitle,
                  colors: colors,
                  card: card,
                  onTap: () {
                 final api = CouponApiService();
                    final repo = CouponRepositoryImpl(
                      api: api,
                      getToken: () =>
                          _store.getToken(), //  THIS is the missing line
                    );

                    final ownerId = int.tryParse(Env.ownerProjectLinkId) ?? 0;

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BlocProvider<CouponBloc>(
                          create: (_) => CouponBloc(
                            getCouponsUc: GetCoupons(repo),
                            saveCouponUc: SaveCoupon(repo),
                            deleteCouponUc: DeleteCoupon(repo),
                            ownerProjectId: ownerId,
                          ),
                          child: const AdminCouponsScreen(),
                        ),
                      ),
                    );

                    

                  },
                ),

                // ✅ ORDERS TILE (OWNER / SUPER_ADMIN)
            _AdminTile(
                  icon: Icons.receipt_long_outlined,
                  title: 'Orders',
                  colors: colors,
                  card: card,
                  onTap: () {
                    Navigator.of(context).pushNamed('/admin/orders');
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

  Color _roleColor(dynamic c) {
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
    final rColor = _roleColor(colors);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: rColor.withOpacity(.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: rColor.withOpacity(.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: rColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.verified_user_outlined, color: rColor, size: 24),
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
  final dynamic colors;
  final dynamic card;

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
    final width = MediaQuery.of(context).size.width;
    final tileWidth = (width - 16 * 2 - 12) / 2;

    return SizedBox(
      width: tileWidth,
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
            ],
          ),
        ),
      ),
    );
  }
}
