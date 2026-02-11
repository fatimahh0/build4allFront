// lib/features/admin/product/presentation/screens/admin_dashboard_screen.dart

import 'package:build4front/features/admin/licensing/data/models/owner_app_access_response.dart';
import 'package:build4front/features/admin/licensing/data/services/licensing_api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4front/core/theme/theme_cubit.dart';
import 'package:build4front/l10n/app_localizations.dart';
import 'package:build4front/core/config/env.dart';
import 'package:build4front/features/auth/data/services/admin_token_store.dart';

import 'package:build4front/features/admin/product/presentation/screens/admin_products_list_screen.dart';
import 'package:build4front/features/admin/home_banner/presentation/screens/admin_home_banners_screen.dart';
import 'package:build4front/features/admin/payment_config/presentation/screens/owner_payment_config_screen.dart';
import 'package:build4front/features/admin/shipping/prensentation/screens/admin_shipping_methods_screen.dart';
import 'package:build4front/features/admin/tax/presentation/screens/admin_tax_rules_screen.dart';

// 🔹 Coupons
import 'package:build4front/features/admin/coupons/presentations/screens/admin_coupons_screen.dart';
import 'package:build4front/features/admin/coupons/presentations/bloc/coupon_bloc.dart';
import 'package:build4front/features/admin/coupons/data/services/coupon_api_service.dart';
import 'package:build4front/features/admin/coupons/data/repositories/coupon_repository_impl.dart';
import 'package:build4front/features/admin/coupons/domain/usecases/get_coupons.dart';
import 'package:build4front/features/admin/coupons/domain/usecases/save_coupon.dart';
import 'package:build4front/features/admin/coupons/domain/usecases/delete_coupon.dart';

// ✅ Toast + exception mapper
import 'package:build4front/common/widgets/app_toast.dart';
import 'package:build4front/core/exceptions/exception_mapper.dart';

String _planCodeToString(dynamic v) {
  if (v == null) return '';
  if (v is String) return v;
  return v.toString().split('.').last; // supports enum too
}

String _nicePlanName(String code) {
  switch (code) {
    case 'FREE':
      return 'Free';
    case 'PRO_HOSTEDB':
      return 'Pro Hosted DB';
    case 'DEDICATED':
      return 'Dedicated';
    default:
      return code.isEmpty ? 'Plan' : code;
  }
}

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _store = AdminTokenStore();
  String? _role;

  OwnerAppAccessResponse? _license;
  bool _licenseLoading = true;
  String? _licenseError;

  late final LicensingApiService _licensingApi =
      LicensingApiService(getToken: () => _store.getToken());

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _loadRole();
    await _loadLicense();
  }

  Future<void> _loadRole() async {
    final role = await _store.getRole();
    if (!mounted) return;
    setState(() => _role = role?.toUpperCase());
  }

  Future<void> _loadLicense() async {
    try {
      setState(() {
        _licenseLoading = true;
        _licenseError = null;
      });

      final aupId = int.tryParse(Env.ownerProjectLinkId) ?? 0;
      final access = await _licensingApi.getAccess(aupId);

      if (!mounted) return;
      setState(() {
        _license = access;
        _licenseLoading = false;
      });

      // ✅ if user limit reached, we can optionally auto-open upgrade sheet
      if (access.blockingReason == 'USER_LIMIT_REACHED') {
        // ignore: use_build_context_synchronously
        _showUpgradeSheet(access);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _licenseLoading = false;
        // ✅ simple message (not essay)
        _licenseError = ExceptionMapper.toMessage(e);
      });
    }
  }

  Future<void> _logout() async {
    await _store.clear();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
  }

  Future<void> _showUpgradeSheet(OwnerAppAccessResponse access) async {
    final current = access.planCode;

    // hardcoded options (because /api/licensing/plans is SUPER_ADMIN only)
    final options = <_UpgradeOption>[];

    if (current == PlanCode.FREE) {
      options.add(
        const _UpgradeOption(
          code: 'PRO_HOSTEDB',
          title: 'Pro Hosted DB',
          desc: 'Unlimited users (hosted by Build4All)',
        ),
      );
      options.add(
        const _UpgradeOption(
          code: 'DEDICATED',
          title: 'Dedicated',
          desc: 'Dedicated server (needs setup/assignment)',
        ),
      );
    } else if (current == PlanCode.PRO_HOSTEDB) {
      options.add(
        const _UpgradeOption(
          code: 'DEDICATED',
          title: 'Dedicated',
          desc: 'Dedicated server (needs setup/assignment)',
        ),
      );
    }

    if (options.isEmpty) {
      AppToast.show(context, 'No upgrade available.');
      return;
    }

    String selected = options.first.code;

    final sent = await showModalBottomSheet<bool>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final tokens = ctx.watch<ThemeCubit>().state.tokens;
        final colors = tokens.colors;
        final t = Theme.of(ctx).textTheme;

        return StatefulBuilder(
          builder: (ctx2, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 4,
                    width: 36,
                    decoration: BoxDecoration(
                      color: colors.border.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Upgrade request',
                    style: t.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.label,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose a plan to send a request.',
                    style: t.bodyMedium?.copyWith(color: colors.body),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 14),
                  for (final o in options)
                    InkWell(
                      onTap: () => setModalState(() => selected = o.code),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: selected == o.code
                              ? colors.primary.withOpacity(.08)
                              : colors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: selected == o.code
                                ? colors.primary.withOpacity(.35)
                                : colors.border.withOpacity(.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              selected == o.code
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              color: selected == o.code
                                  ? colors.primary
                                  : colors.body,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    o.title,
                                    style: t.bodyLarge?.copyWith(
                                      color: colors.label,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    o.desc,
                                    style: t.bodySmall
                                        ?.copyWith(color: colors.body),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx2, true),
                      child: const Text('Send request'),
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx2, false),
                      child: const Text('Cancel'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (sent != true) return;

    try {
      final aupId = int.tryParse(Env.ownerProjectLinkId) ?? 0;

      await _licensingApi.requestUpgrade(
        aupId: aupId,
        planCode: selected,
      );

      if (!mounted) return;
      AppToast.show(context, 'Request sent ✅');
      await _loadLicense();
    } catch (e) {
      if (!mounted) return;
      AppToast.show(context, ExceptionMapper.toMessage(e), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final tokens = context.watch<ThemeCubit>().state.tokens;
    final colors = tokens.colors;
    final card = tokens.card;
    final role = _role ?? 'ADMIN';

    final blockingReason = (_license?.blockingReason ?? '').trim();
    final bool isBlockedByLicense = _license != null &&
        ((_license!.canAccessDashboard == false) || blockingReason.isNotEmpty);

    // ✅ if blocked (limit/expired/etc) => NO ACCESS to tiles
    final bool lockActions =
        _licenseLoading || _licenseError != null || isBlockedByLicense;

    final bool isLimit = blockingReason == 'USER_LIMIT_REACHED';
    final String lockMsg = _licenseLoading
        ? 'Checking license…'
        : (_licenseError != null
            ? 'License check failed'
            : (isLimit
                ? 'Limit reached — upgrade required'
                : 'Access blocked'));

    VoidCallback guarded(VoidCallback realAction) {
      return () {
        if (lockActions) {
          AppToast.show(context, lockMsg, isError: true);
          return;
        }
        realAction();
      };
    }

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
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
            const SizedBox(height: 12),

            // ✅ License banner always visible
            _LicenseBanner(
              loading: _licenseLoading,
              error: _licenseError,
              access: _license,
              onRetry: _loadLicense,
              onRequestUpgrade: () {
                if (_license != null) _showUpgradeSheet(_license!);
              },
            ),

            const SizedBox(height: 20),
            Text(
              l10n.adminDashboardQuickActions,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colors.label,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),

            // ✅ visually dim when locked (but we still show toast on tap via guarded())
            Opacity(
              opacity: lockActions ? 0.45 : 1,
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _AdminTile(
                    icon: Icons.shopping_bag_outlined,
                    title: l10n.adminProductsTitle,
                    colors: colors,
                    card: card,
                    onTap: guarded(() {
                      final ownerId = int.tryParse(Env.ownerProjectLinkId) ?? 0;
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              AdminProductsListScreen(ownerProjectId: ownerId),
                        ),
                      );
                    }),
                  ),
                  _AdminTile(
                    icon: Icons.local_shipping_outlined,
                    title: l10n.adminShippingTitle,
                    colors: colors,
                    card: card,
                    onTap: guarded(() {
                      final ownerId = int.tryParse(Env.ownerProjectLinkId) ?? 0;
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AdminShippingMethodsScreen(
                              ownerProjectId: ownerId),
                        ),
                      );
                    }),
                  ),
                  _AdminTile(
                    icon: Icons.credit_card_outlined,
                    title: l10n.adminPaymentConfigTitle,
                    colors: colors,
                    card: card,
                    onTap: guarded(() {
                      final ownerId = int.tryParse(Env.ownerProjectLinkId) ?? 0;
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => OwnerPaymentConfigScreen(
                            ownerProjectId: ownerId,
                            getToken: () => _store.getToken(),
                          ),
                        ),
                      );
                    }),
                  ),
                  _AdminTile(
                    icon: Icons.receipt_long_outlined,
                    title: l10n.adminTaxesTitle,
                    colors: colors,
                    card: card,
                    onTap: guarded(() {
                      final ownerId = int.tryParse(Env.ownerProjectLinkId) ?? 0;
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              AdminTaxRulesScreen(ownerProjectId: ownerId),
                        ),
                      );
                    }),
                  ),
                  _AdminTile(
                    icon: Icons.view_carousel_outlined,
                    title: l10n.adminHomeBannersTitle,
                    colors: colors,
                    card: card,
                    onTap: guarded(() {
                      final ownerId = int.tryParse(Env.ownerProjectLinkId) ?? 0;
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              AdminHomeBannersScreen(ownerProjectId: ownerId),
                        ),
                      );
                    }),
                  ),
                  _AdminTile(
                    icon: Icons.card_giftcard_outlined,
                    title: l10n.adminCouponsTitle,
                    colors: colors,
                    card: card,
                    onTap: guarded(() {
                      final api = CouponApiService();
                      final repo = CouponRepositoryImpl(
                        api: api,
                        getToken: () => _store.getToken(),
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
                    }),
                  ),
                  _AdminTile(
                    icon: Icons.receipt_long_outlined,
                    title: 'Orders',
                    colors: colors,
                    card: card,
                    onTap: guarded(() {
                      Navigator.of(context).pushNamed('/admin/orders');
                    }),
                  ),
                  _AdminTile(
                    icon: Icons.upload_file_outlined,
                    title: l10n.adminExcelImportTitle,
                    colors: colors,
                    card: card,
                    onTap: guarded(() {
                      Navigator.of(context).pushNamed('/admin/excel-import');
                    }),
                  ),
                ],
              ),
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

    // ✅ better mobile: 1 column on small screens
    final cols = width < 420 ? 1 : 2;
    final tileWidth = (width - 16 * 2 - 12 * (cols - 1)) / cols;

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

class _LicenseBanner extends StatelessWidget {
  final bool loading;
  final String? error;
  final OwnerAppAccessResponse? access;
  final VoidCallback onRetry;
  final VoidCallback onRequestUpgrade;

  const _LicenseBanner({
    required this.loading,
    required this.error,
    required this.access,
    required this.onRetry,
    required this.onRequestUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.watch<ThemeCubit>().state.tokens;
    final colors = tokens.colors;
    final t = Theme.of(context).textTheme;

    if (loading) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border.withOpacity(.2)),
        ),
        child: Row(
          children: [
            const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 10),
            Text(
              'Checking license…',
              style: t.bodyMedium?.copyWith(color: colors.body),
            ),
          ],
        ),
      );
    }

    if (error != null) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.error.withOpacity(.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.error.withOpacity(.25)),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: colors.error),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                error!,
                style: t.bodyMedium?.copyWith(color: colors.label),
              ),
            ),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (access == null) return const SizedBox.shrink();

    final reason = (access!.blockingReason ?? '').trim();
    final isOk = reason.isEmpty && (access!.canAccessDashboard != false);
    final isLimit = reason == 'USER_LIMIT_REACHED';

    final bg = isLimit
        ? colors.primary.withOpacity(.08)
        : (isOk ? colors.surface : colors.error.withOpacity(.06));

    final border = isLimit
        ? colors.primary.withOpacity(.25)
        : (isOk
            ? colors.border.withOpacity(.2)
            : colors.error.withOpacity(.25));

    final planCodeStr = _planCodeToString(access!.planCode);
    final planName = (access!.planName ?? '').trim().isEmpty
        ? _nicePlanName(planCodeStr)
        : access!.planName!;

    String subtitle;
    if (isOk) {
      subtitle = 'Access granted ✅';
    } else if (isLimit) {
      final active = access!.activeUsers ?? 0;
      final allowed = access!.usersAllowed ?? 0;
      subtitle = 'Limit reached: $active/$allowed users';
    } else {
      subtitle = 'Access blocked';
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Icon(
            isLimit
                ? Icons.people_outline
                : (isOk ? Icons.verified_outlined : Icons.lock_outline),
            color:
                isLimit ? colors.primary : (isOk ? colors.body : colors.error),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  planName,
                  style: t.bodyLarge?.copyWith(
                    color: colors.label,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: t.bodySmall?.copyWith(color: colors.body),
                ),
              ],
            ),
          ),
          if (isLimit)
            ElevatedButton(
              onPressed: onRequestUpgrade,
              child: const Text('Request upgrade'),
            ),
        ],
      ),
    );
  }
}

class _UpgradeOption {
  final String code;
  final String title;
  final String desc;

  const _UpgradeOption({
    required this.code,
    required this.title,
    required this.desc,
  });
}
