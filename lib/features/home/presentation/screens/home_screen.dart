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

class HomeScreen extends StatefulWidget {
  final AppConfig appConfig;
  final List<HomeSectionConfig> sections;

  const HomeScreen({
    super.key,
    required this.appConfig,
    required this.sections,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  int? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final enabled = widget.appConfig.enabledFeatures.toSet();

    final themeState = context.watch<ThemeCubit>().state;
    final spacing = themeState.tokens.spacing;

    final visibleSections = widget.sections.where((s) {
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
          builder: (context, authBlocState) {
            String? fullName;
            String? avatarUrl;

            final UserEntity? user = authBlocState.user as UserEntity?;

            if (authBlocState.isLoggedIn && user != null) {
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
                    setState(() {
                      _searchQuery = '';
                      _selectedCategoryId = null;
                    });
                    context.read<HomeBloc>().add(const HomeRefreshRequested());
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
          appName: widget.appConfig.appName,
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
              setState(() => _searchQuery = value.trim());
            },
          ),
        );

      case HomeSectionType.categoryChips:
        return HomeCategoryChips(
          categories: [l10n.explore_category_all, ...homeState.categories],

          onCategoryTap: (categoryName) {
            final selected = categoryName.trim();

            // "All" -> clear filter
            if (selected.isEmpty || selected == l10n.explore_category_all) {
              setState(() => _selectedCategoryId = null);
              return;
            }

            // map name -> id using categoryEntities
            int? foundId;
            for (final cat in homeState.categoryEntities) {
              if (cat.name == selected) {
                foundId = cat.id;
                break;
              }
            }

            setState(() => _selectedCategoryId = foundId);
          },
        );

      case HomeSectionType.banner:
        return HomeBannerSlider(
          ownerProjectId: widget.appConfig.ownerProjectId ?? 1,
          token: authState.token ?? '',
          onBannerTap: (banner) {
            if (banner.targetType == 'CATEGORY' && banner.targetId != null) {
              Navigator.of(context).pushNamed(
                '/explore',
                arguments: {'categoryId': banner.targetId},
              );
            } else if (banner.targetType == 'URL' &&
                (banner.targetUrl ?? '').isNotEmpty) {
              // TODO: url_launcher
            }
          },
        );

      case HomeSectionType.itemList:
        final rawItems = _mapItemsForSection(section, homeState);
        final itemsForSection = _applyFilters(rawItems);

        if (itemsForSection.isEmpty) return const SizedBox.shrink();

        final sectionTitle =
            section.title ??
            (section.id == 'recommended'
                ? l10n.home_recommended_title
                : section.id == 'popular'
                ? l10n.home_popular_title
                : section.id == 'flash_sale'
                ? l10n.home_flash_sale_title
                : section.id == 'new_arrivals'
                ? l10n.home_new_arrivals_title
                : section.id == 'best_sellers'
                ? l10n.home_best_sellers_title
                : section.id == 'top_rated'
                ? l10n.home_top_rated_title
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
            Navigator.of(
              context,
            ).pushNamed('/explore', arguments: {'sectionId': section.id});
          },
        );

      case HomeSectionType.bookingList:
        return _BookingSection(
          title: section.title ?? l10n.home_bookings_title,
        );

      case HomeSectionType.reviewList:
        return _WhyShopWithUsSection(
          title: section.title ?? l10n.home_why_shop_title,
        );
    }
  }

  List<ItemSummary> _applyFilters(List<ItemSummary> items) {
    var result = items;

    if (_selectedCategoryId != null) {
      result = result
          .where((item) => item.categoryId == _selectedCategoryId)
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((item) {
        final title = item.title.toLowerCase();
        final subtitle = (item.subtitle ?? '').toLowerCase();
        final location = (item.location ?? '').toLowerCase();
        return title.contains(q) ||
            subtitle.contains(q) ||
            location.contains(q);
      }).toList();
    }

    return result;
  }

  List<ItemSummary> _mapItemsForSection(
    HomeSectionConfig section,
    HomeState homeState,
  ) {
    switch (section.id) {
      case 'recommended':
        return homeState.recommendedItems.isNotEmpty
            ? homeState.recommendedItems
            : homeState.popularItems;

      case 'popular':
        return homeState.popularItems;

      case 'flash_sale':
        return homeState.flashSaleItems.isNotEmpty
            ? homeState.flashSaleItems
            : homeState.popularItems;

      case 'new_arrivals':
        return homeState.newArrivalsItems.isNotEmpty
            ? homeState.newArrivalsItems
            : homeState.popularItems;

      case 'best_sellers':
        return homeState.bestSellersItems.isNotEmpty
            ? homeState.bestSellersItems
            : homeState.popularItems;

      case 'top_rated':
        return homeState.topRatedItems.isNotEmpty
            ? homeState.topRatedItems
            : (homeState.bestSellersItems.isNotEmpty
                  ? homeState.bestSellersItems
                  : homeState.popularItems);

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

class _BookingSection extends StatelessWidget {
  final String title;
  const _BookingSection({required this.title});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final spacing = context.read<ThemeCubit>().state.tokens.spacing;

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

class _WhyShopWithUsSection extends StatelessWidget {
  final String title;
  const _WhyShopWithUsSection({required this.title});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final spacing = context.read<ThemeCubit>().state.tokens.spacing;
    final l10n = AppLocalizations.of(context)!;

    final cards = [
      (
        l10n.home_why_shop_free_shipping_title,
        l10n.home_why_shop_free_shipping_subtitle,
      ),
      (
        l10n.home_why_shop_easy_returns_title,
        l10n.home_why_shop_easy_returns_subtitle,
      ),
      (
        l10n.home_why_shop_secure_payment_title,
        l10n.home_why_shop_secure_payment_subtitle,
      ),
      (l10n.home_why_shop_support_title, l10n.home_why_shop_support_subtitle),
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
            children: cards.map((card) {
              return Container(
                margin: EdgeInsets.only(bottom: spacing.sm),
                padding: EdgeInsets.all(spacing.lg),
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: c.outline.withOpacity(0.12)),
                  boxShadow: [
                    BoxShadow(
                      color: c.onSurface.withOpacity(0.04),
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
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
