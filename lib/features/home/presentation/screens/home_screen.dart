import 'package:build4front/core/network/globals.dart' as authState;
import 'package:build4front/features/home/homebanner/presentations/widgets/home_banner_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4front/core/config/app_config.dart';
import 'package:build4front/core/config/home_config.dart';
import 'package:build4front/core/theme/theme_cubit.dart';
import 'package:build4front/l10n/app_localizations.dart';

import 'package:build4front/features/auth/presentation/login/bloc/auth_bloc.dart';
import 'package:build4front/features/auth/presentation/login/bloc/auth_state.dart';
import 'package:build4front/features/auth/domain/entities/user_entity.dart';

import 'package:build4front/features/home/presentation/bloc/home_bloc.dart';
import 'package:build4front/features/home/presentation/bloc/home_event.dart';
import 'package:build4front/features/home/presentation/bloc/home_state.dart';

import 'package:build4front/common/widgets/app_search_field.dart';
import 'package:build4front/features/home/presentation/widgets/home_header.dart';
import 'package:build4front/features/home/presentation/widgets/home_category_chips.dart';
import 'package:build4front/features/home/presentation/widgets/home_items_section.dart';
import 'package:build4front/features/home/presentation/widgets/home_section_header.dart';
import 'package:build4front/features/items/domain/entities/item_summary.dart';

class HomeScreen extends StatelessWidget {
  final AppConfig appConfig;
  final List<HomeSectionConfig> sections;

  const HomeScreen({
    super.key,
    required this.appConfig,
    required this.sections,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final enabled = appConfig.enabledFeatures.toSet();

    // Read spacing tokens once at screen level
    final themeState = context.watch<ThemeCubit>().state;
    final spacing = themeState.tokens.spacing;

    final visibleSections = sections.where((s) {
      if (s.feature == null) return true;
      return enabled.contains(s.feature);
    }).toList();

    final homeBloc = context.read<HomeBloc>();
    if (!homeBloc.state.hasLoaded && !homeBloc.state.isLoading) {
      homeBloc.add(const HomeStarted());
    }

    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            String? fullName;
            String? avatarUrl;

            final UserEntity? user = authState.user as UserEntity?;

            if (authState.isLoggedIn && user != null) {
              final hasFirst = (user.firstName ?? '').trim().isNotEmpty;
              final hasLast = (user.lastName ?? '').trim().isNotEmpty;

              if (hasFirst || hasLast) {
                fullName = '${user.firstName ?? ''} ${user.lastName ?? ''}'
                    .trim();
              } else if ((user.username ?? '').trim().isNotEmpty) {
                fullName = user.username!.trim();
              } else if ((user.email ?? '').trim().isNotEmpty) {
                fullName = user.email!.trim();
              } else if ((user.phoneNumber ?? '').trim().isNotEmpty) {
                fullName = user.phoneNumber!.trim();
              }

              avatarUrl = user.profilePictureUrl;
            }

            return BlocBuilder<HomeBloc, HomeState>(
              builder: (context, homeState) {
                if (homeState.isLoading && !homeState.hasLoaded) {
                  return const Center(child: CircularProgressIndicator());
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<HomeBloc>().add(const HomeStarted());
                  },
                  child: ListView.builder(
                    padding: EdgeInsets.fromLTRB(
                      spacing.lg,
                      spacing.lg,
                      spacing.lg,
                      spacing.xl,
                    ),
                    itemCount: visibleSections.length,
                    itemBuilder: (context, index) {
                      final section = visibleSections[index];
                      return _buildSection(
                        context,
                        theme,
                        l10n,
                        section,
                        homeState: homeState,
                        fullName: fullName,
                        avatarUrl: avatarUrl,
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    HomeSectionConfig section, {
    required HomeState homeState,
    String? fullName,
    String? avatarUrl,
  }) {
    switch (section.type) {
      case HomeSectionType.header:
        return HomeHeader(
          appName: appConfig.appName,
          fullName: fullName,
          avatarUrl: avatarUrl,
          welcomeText: l10n.home_welcome,
        );

      case HomeSectionType.search:
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: AppSearchField(
            hintText: l10n.home_search_hint,
            onSubmitted: (value) {
              // TODO: navigate to search screen or filter
            },
          ),
        );

      case HomeSectionType.categoryChips:
        return HomeCategoryChips(categories: homeState.categories);

      case HomeSectionType.banner:
        return HomeBannerSlider(
          ownerProjectId:
              appConfig.ownerProjectId ?? 1, // or whatever field you use
          token: authState.token ?? '', // adapt to your AuthState
          onBannerTap: (banner) {
            // TODO: handle navigation:
            // - if banner.targetType == 'PRODUCT' => open product details with banner.targetId
            // - if 'CATEGORY' => navigate to category filter
            // - if 'URL' => launchUrl(banner.targetUrl!)
          },
        );

      case HomeSectionType.itemList:
        final itemsForSection = _mapItemsForSection(section, homeState);

        final sectionTitle =
            section.title ??
            (section.id == 'recommended'
                ? l10n.home_recommended_title
                : section.id == 'popular'
                ? l10n.home_popular_title
                : section.id == 'flash_sale'
                ? 'Flash Sale'
                : section.id == 'new_arrivals'
                ? 'New Arrivals'
                : section.id == 'best_sellers'
                ? 'Best Sellers'
                : section.id == 'top_rated'
                ? 'Top Rated'
                : l10n.home_items_default_title);

        final icon = _iconForSection(section);
        final trailing = _trailingForSection(section);

        return HomeItemsSection(
          title: sectionTitle,
          layout: section.layout,
          items: itemsForSection,
          icon: icon,
          trailingText: trailing.text,
          trailingIcon: trailing.icon,
          onTrailingTap: () {
            // TODO: navigate to dedicated list screen
          },
        );

      case HomeSectionType.bookingList:
        return _BookingSection(
          title: section.title ?? l10n.home_bookings_title,
        );

      case HomeSectionType.reviewList:
        // For e-commerce: use this slot as "Why Shop With Us"
        return _WhyShopWithUsSection(
          title: section.title ?? 'Why Shop With Us',
        );
    }
  }

  List<ItemSummary> _mapItemsForSection(
    HomeSectionConfig section,
    HomeState homeState,
  ) {
    switch (section.id) {
      case 'recommended':
        if (homeState.recommendedItems.isNotEmpty) {
          return homeState.recommendedItems;
        }
        return homeState.popularItems;
      case 'popular':
      case 'flash_sale':
      case 'new_arrivals':
      case 'best_sellers':
      case 'top_rated':
        // For now reuse popular items for all.
        // Later: map each to its real backend list.
        return homeState.popularItems;
      default:
        return homeState.popularItems;
    }
  }

  IconData _iconForSection(HomeSectionConfig section) {
    switch (section.id) {
      case 'flash_sale':
        return Icons.flash_on_rounded;
      case 'new_arrivals':
        return Icons.local_offer_outlined;
      case 'best_sellers':
        return Icons.workspace_premium_outlined;
      case 'top_rated':
        return Icons.star_rate_rounded;
      default:
        return Icons.local_activity_outlined;
    }
  }
}

class _TrailingData {
  final String? text;
  final IconData? icon;

  const _TrailingData({this.text, this.icon});
}

_TrailingData _trailingForSection(HomeSectionConfig section) {
  switch (section.id) {
    case 'flash_sale':
      return const _TrailingData(text: 'Limited time');
    case 'new_arrivals':
    case 'best_sellers':
    case 'top_rated':
      return const _TrailingData(
        text: 'See all',
        icon: Icons.chevron_right_rounded,
      );
    default:
      return const _TrailingData();
  }
}

/// ===================
///  Banner / bookings / why-us
/// ===================

class _BannerSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonLabel;

  const _BannerSection({
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
  });

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    final themeState = context.read<ThemeCubit>().state;
    final spacing = themeState.tokens.spacing;

    return Container(
      margin: EdgeInsets.only(bottom: spacing.lg),
      padding: EdgeInsets.all(spacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [c.primary, c.primaryContainer.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Text + CTA
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: t.headlineSmall?.copyWith(color: c.onPrimary),
                ),
                SizedBox(height: spacing.sm),
                Text(
                  subtitle,
                  style: t.bodyMedium?.copyWith(color: c.onPrimary),
                ),
                SizedBox(height: spacing.md),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: c.onPrimary,
                    foregroundColor: c.primary,
                    padding: EdgeInsets.symmetric(
                      horizontal: spacing.lg,
                      vertical: spacing.sm,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  onPressed: () {
                    // TODO: scroll to items / navigate
                  },
                  child: Text(buttonLabel),
                ),
              ],
            ),
          ),
          SizedBox(width: spacing.md),
          // Right icon box (placeholder image block)
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: c.onPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.shopping_bag_rounded,
              color: c.onPrimary,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingSection extends StatelessWidget {
  final String title;

  const _BookingSection({required this.title});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    final themeState = context.read<ThemeCubit>().state;
    final spacing = themeState.tokens.spacing;

    return Container(
      margin: EdgeInsets.only(bottom: spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeSectionHeader(title: title, icon: Icons.event_available_outlined),
          SizedBox(height: spacing.sm),
          Container(
            padding: EdgeInsets.all(spacing.md),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: c.outline.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 18),
                SizedBox(width: spacing.sm),
                Expanded(
                  child: Text(
                    'Bookings feed not wired yet.',
                    style: t.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// New: Why Shop With Us section (bottom cards)
class _WhyShopWithUsSection extends StatelessWidget {
  final String title;

  const _WhyShopWithUsSection({required this.title});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    final themeState = context.read<ThemeCubit>().state;
    final spacing = themeState.tokens.spacing;

    final cards = [
      ('Free Shipping', 'On all orders over \$50'),
      ('Easy Returns', '30-day return policy'),
      ('Secure Payment', '100% protected transactions'),
      ('24/7 Support', 'Always here to help you'),
    ];

    return Container(
      margin: EdgeInsets.only(bottom: spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: t.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: spacing.md),
          Column(
            children: cards
                .map(
                  (card) => Container(
                    margin: EdgeInsets.only(bottom: spacing.sm),
                    padding: EdgeInsets.all(spacing.lg),
                    decoration: BoxDecoration(
                      color: c.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: c.outline.withOpacity(0.12)),
                      boxShadow: [
                        BoxShadow(
                          color: c.shadow.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          card.$1,
                          style: t.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: spacing.xs),
                        Text(
                          card.$2,
                          style: t.bodySmall?.copyWith(
                            color: c.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
