import 'package:build4front/features/items/domain/entities/item_summary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4front/core/config/app_config.dart';
import 'package:build4front/core/config/home_config.dart';
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
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
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
          welcomeText: l10n.home_welcome, // add to ARB
        );

      case HomeSectionType.search:
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: AppSearchField(
            hintText: l10n.home_search_hint, // add to ARB
            onSubmitted: (value) {
              // TODO: navigate to search screen or filter
            },
          ),
        );

      case HomeSectionType.categoryChips:
        return HomeCategoryChips(categories: homeState.categories);

      case HomeSectionType.banner:
        return _BannerSection(
          title: section.title ?? l10n.home_banner_title,
          subtitle: l10n.home_banner_subtitle,
          buttonLabel: l10n.home_banner_button,
        );

      case HomeSectionType.itemList:
        final itemsForSection = _mapItemsForSection(section, homeState);

        final sectionTitle =
            section.title ??
            (section.id == 'recommended'
                ? l10n.home_recommended_title
                : section.id == 'popular'
                ? l10n.home_popular_title
                : l10n.home_items_default_title);

        return HomeItemsSection(
          title: sectionTitle,
          layout: section.layout,
          items: itemsForSection,
        );

      case HomeSectionType.bookingList:
        return _BookingSection(
          title: section.title ?? l10n.home_bookings_title,
        );

      case HomeSectionType.reviewList:
        return _ReviewsSection(
          title: section.title ?? l10n.home_reviews_title,
          layout: section.layout,
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
        return homeState.popularItems;
      default:
        return homeState.popularItems;
    }
  }
}

/// ===================
///  Banner / bookings / reviews
///  (no fake lists – UI only, data later)
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

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [c.primary, c.primaryContainer.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: t.headlineSmall?.copyWith(color: c.onPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: t.bodyMedium?.copyWith(color: c.onPrimary),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: c.onPrimary,
                    foregroundColor: c.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
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
          const SizedBox(width: 12),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: c.onPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.sports_martial_arts_rounded,
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

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeSectionHeader(title: title, icon: Icons.event_available_outlined),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: c.outline.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Bookings feed not wired yet.', // can move to l10n if you want
                    style: Theme.of(context).textTheme.bodySmall,
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

class _ReviewsSection extends StatelessWidget {
  final String title;
  final String layout;

  const _ReviewsSection({required this.title, required this.layout});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final isHorizontal = layout.toLowerCase() == 'horizontal';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HomeSectionHeader(title: title, icon: Icons.reviews_outlined),
          const SizedBox(height: 8),
          SizedBox(
            height: isHorizontal ? 140 : null,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: c.outline.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Reviews feed not wired yet.', // also can be l10n
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
