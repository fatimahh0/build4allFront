// lib/features/home/presentation/screens/home_screen.dart
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4front/core/network/globals.dart' as authState;
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
import 'package:build4front/features/home/homebanner/presentations/widgets/home_banner_slider.dart';

import 'package:build4front/features/home/presentation/widgets/home_bottom_section.dart';

import 'package:build4front/features/items/domain/entities/item_summary.dart';
import 'package:build4front/common/widgets/ItemCard.dart';

import 'package:build4front/features/itemsDetails/presentation/screens/item_details_page.dart';

import 'package:build4front/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:build4front/features/cart/presentation/bloc/cart_event.dart';
import 'package:build4front/common/widgets/app_toast.dart';

class HomeScreen extends StatefulWidget {
  final AppConfig appConfig;
  final List<HomeSectionConfig> sections;

  final VoidCallback? onOpenProfileTab;
  const HomeScreen({
    super.key,
    required this.appConfig,
    required this.sections,
    this.onOpenProfileTab,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  String _searchQuery = '';
  int? _selectedCategoryId;
  Timer? _searchDebounce;

  int _filterVersion = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeBloc = context.read<HomeBloc>();
      if (!homeBloc.state.hasLoaded && !homeBloc.state.isLoading) {
        homeBloc.add(const HomeStarted());
      }
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _resetPaging() => _filterVersion++;

  void _onSearchChangedDebounced(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 280), () {
      if (!mounted) return;
      setState(() {
        _searchQuery = value.trim();
        _resetPaging();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final enabled = widget.appConfig.enabledFeatures.toSet();
    final themeState = context.watch<ThemeCubit>().state;
    final spacing = themeState.tokens.spacing;

    final visibleSections = widget.sections.where((s) {
      if (s.feature == null) return true;
      return enabled.contains(s.feature);
    }).toList();

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
                      _resetPaging();
                    });
                    context.read<HomeBloc>().add(const HomeRefreshRequested());
                  },
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final maxW = constraints.maxWidth;
                      final contentMaxWidth = maxW > 900 ? 900.0 : maxW;

                      final hp = maxW < 390 ? spacing.md : spacing.lg;
                      final top = maxW < 390 ? spacing.md : spacing.lg;
                      final bottom = spacing.lg;

                      return Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: contentMaxWidth,
                          ),
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.fromLTRB(hp, top, hp, bottom),
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
                        ),
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
    final spacing = context.read<ThemeCubit>().state.tokens.spacing;

    switch (section.type) {
      case HomeSectionType.header:
        return Padding(
          padding: EdgeInsets.only(bottom: spacing.xs),
          child: HomeHeader(
            appName: widget.appConfig.appName,
            fullName: fullName,
            avatarUrl: avatarUrl,
            welcomeText: l10n.home_welcome,
            onProfileTap: widget.onOpenProfileTab,
          ),
        );

      case HomeSectionType.search:
        return Padding(
          padding: EdgeInsets.only(bottom: spacing.xs),
          child: AppSearchField(
            hintText: l10n.home_search_hint,
            onChanged: _onSearchChangedDebounced,
            onSubmitted: (value) {
              setState(() {
                _searchQuery = value.trim();
                _resetPaging();
              });
            },
          ),
        );

      case HomeSectionType.categoryChips:
        final selectedLabel = _selectedCategoryId == null
            ? l10n.explore_category_all
            : () {
                for (final cat in homeState.categoryEntities) {
                  if (cat.id == _selectedCategoryId) return cat.name;
                }
                return l10n.explore_category_all;
              }();

        return Padding(
          padding: EdgeInsets.only(bottom: spacing.xs),
          child: HomeCategoryChips(
            categories: [l10n.explore_category_all, ...homeState.categories],
            selectedCategory: selectedLabel,
            onCategoryTap: (categoryName) {
              final selected = categoryName.trim();

              if (selected.isEmpty || selected == l10n.explore_category_all) {
                setState(() {
                  _selectedCategoryId = null;
                  _resetPaging();
                });
                return;
              }

              int? foundId;
              for (final cat in homeState.categoryEntities) {
                if (cat.name == selected) {
                  foundId = cat.id;
                  break;
                }
              }

              setState(() {
                _selectedCategoryId = foundId;
                _resetPaging();
              });
            },
          ),
        );

      case HomeSectionType.banner:
        return Padding(
          padding: EdgeInsets.only(bottom: spacing.xs),
          child: HomeBannerSlider(
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
                // TODO url_launcher
              }
            },
          ),
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
        final trailing = _trailingForSection(section, l10n);

        final bool forceGridPager =
            (section.id == 'new_arrivals') ||
            ((section.layout ?? '').toLowerCase() == 'grid');

        return Padding(
          padding: EdgeInsets.only(bottom: spacing.xs),
          child: _HomePagedItemsSection(
            key: ValueKey('${section.id}::$_filterVersion'),
            title: sectionTitle,
            icon: icon,
            trailingText: trailing.text,
            trailingIcon: trailing.icon,
            onTrailingTap: () {
              Navigator.of(
                context,
              ).pushNamed('/explore', arguments: {'sectionId': section.id});
            },
            items: itemsForSection,
            mode: forceGridPager
                ? _HomePagerMode.gridPages
                : _HomePagerMode.carouselPages,
            pricingFor: (item) => _pricingFor(context, item),
            subtitleFor: _subtitleFor,
            metaFor: (item) => _metaLabelFor(context, item),
            ctaLabelFor: (item) => _ctaLabelFor(context, item),
            onTapItem: (id) => _openDetails(context, id),
            onCtaPressed: (item) => _handleCtaPressed(context, item),
          ),
        );

      case HomeSectionType.bookingList:
        return _BookingSection(
          title: section.title ?? l10n.home_bookings_title,
          placeholderText: l10n.home_bookings_placeholder,
        );

      case HomeSectionType.reviewList:
        // ✅ now this is only the 4-tiles grid (no review/thankyou/secure slider)
        return const HomeBottomSection();
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

  void _openDetails(BuildContext context, int itemId) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => ItemDetailsPage(itemId: itemId)));
  }

  String _ctaLabelFor(BuildContext context, ItemSummary item) {
    final l10n = AppLocalizations.of(context)!;
    switch (item.kind) {
      case ItemKind.product:
        return l10n.cart_add_button;
      case ItemKind.activity:
        return l10n.home_book_now_button;
      default:
        return l10n.home_view_details_button;
    }
  }

  String? _subtitleFor(ItemSummary item) {
    switch (item.kind) {
      case ItemKind.activity:
        return item.location;
      case ItemKind.product:
        return item.subtitle;
      default:
        return item.subtitle ?? item.location;
    }
  }

  String? _metaLabelFor(BuildContext context, ItemSummary item) {
    final l10n = AppLocalizations.of(context)!;

    switch (item.kind) {
      case ItemKind.activity:
        if (item.start == null) return null;
        final dt = item.start!.toLocal();
        final y = dt.year.toString().padLeft(4, '0');
        final m = dt.month.toString().padLeft(2, '0');
        final d = dt.day.toString().padLeft(2, '0');
        final hh = dt.hour.toString().padLeft(2, '0');
        final mm = dt.minute.toString().padLeft(2, '0');
        return '$d/$m/$y  $hh:$mm';

      case ItemKind.product:
        if (item.stock == null) return null;
        return l10n.home_stock_label(item.stock!);

      default:
        return null;
    }
  }

  void _handleCtaPressed(BuildContext context, ItemSummary item) {
    final l10n = AppLocalizations.of(context)!;
    final auth = context.read<AuthBloc>().state;

    if (!auth.isLoggedIn) {
      AppToast.show(context, l10n.cart_login_required_message, isError: true);
      return;
    }

    if (item.kind == ItemKind.product) {
      context.read<CartBloc>().add(
        CartAddItemRequested(itemId: item.id, quantity: 1),
      );
      AppToast.show(context, l10n.cart_item_added_snackbar);
      return;
    }

    _openDetails(context, item.id);
  }

  bool _isSaleActiveNow(ItemSummary item) {
    final now = DateTime.now();
    final start = item.saleStart;
    final end = item.saleEnd;

    if (start == null && end == null) return item.onSale;
    if (start != null && end == null) return !now.isBefore(start);
    if (start == null && end != null) return !now.isAfter(end);

    return !now.isBefore(start!) && !now.isAfter(end!);
  }

  num? _currentPrice(ItemSummary item) {
    final saleActive = item.onSale && _isSaleActiveNow(item);
    return saleActive
        ? (item.effectivePrice ?? item.salePrice ?? item.price)
        : item.price;
  }

  _PricingView _pricingFor(BuildContext context, ItemSummary item) {
    final l10n = AppLocalizations.of(context)!;
    final saleActive = item.onSale && _isSaleActiveNow(item);
    final current = _currentPrice(item);

    final currentLabel = current != null
        ? '${current.toStringAsFixed(2)} \$'
        : null;

    String? oldLabel;
    if (saleActive &&
        item.price != null &&
        current != null &&
        item.price! > current) {
      oldLabel = '${item.price!.toStringAsFixed(2)} \$';
    }

    String? tagLabel;
    if (saleActive &&
        item.price != null &&
        current != null &&
        item.price! > 0) {
      final percent = ((1 - (current / item.price!)) * 100).round();
      tagLabel = percent > 0 ? '-$percent%' : l10n.home_sale_tag;
    }

    return _PricingView(
      currentLabel: currentLabel,
      oldLabel: oldLabel,
      tagLabel: tagLabel,
    );
  }

  _TrailingData _trailingForSection(
    HomeSectionConfig section,
    AppLocalizations l10n,
  ) {
    switch (section.id) {
      case 'flash_sale':
        return _TrailingData(text: l10n.home_trailing_limited_time);
      case 'new_arrivals':
      case 'best_sellers':
      case 'top_rated':
        return _TrailingData(
          text: l10n.home_trailing_see_all,
          icon: Icons.chevron_right_rounded,
        );
      default:
        return const _TrailingData();
    }
  }
}

// =========================
// Pagination section
// ✅ FIXED the weird LEFT GAP (padEnds=false + better viewportFraction)
// =========================

enum _HomePagerMode { carouselPages, gridPages }

class _HomePagedItemsSection extends StatefulWidget {
  final String title;
  final IconData icon;

  final String? trailingText;
  final IconData? trailingIcon;
  final VoidCallback? onTrailingTap;

  final List<ItemSummary> items;
  final _HomePagerMode mode;

  final _PricingView Function(ItemSummary) pricingFor;
  final String? Function(ItemSummary) subtitleFor;
  final String? Function(ItemSummary) metaFor;
  final String Function(ItemSummary) ctaLabelFor;

  final void Function(int itemId) onTapItem;
  final void Function(ItemSummary item) onCtaPressed;

  const _HomePagedItemsSection({
    super.key,
    required this.title,
    required this.icon,
    required this.trailingText,
    required this.trailingIcon,
    required this.onTrailingTap,
    required this.items,
    required this.mode,
    required this.pricingFor,
    required this.subtitleFor,
    required this.metaFor,
    required this.ctaLabelFor,
    required this.onTapItem,
    required this.onCtaPressed,
  });

  @override
  State<_HomePagedItemsSection> createState() => _HomePagedItemsSectionState();
}

class _HomePagedItemsSectionState extends State<_HomePagedItemsSection> {
  late PageController _pageController;
  int _page = 0;

  double get _vf =>
      widget.mode == _HomePagerMode.carouselPages ? 0.94 : 1.0; // ✅ less gap

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: _vf);
  }

  @override
  void didUpdateWidget(covariant _HomePagedItemsSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.mode != widget.mode) {
      final old = _pageController;
      _pageController = PageController(viewportFraction: _vf);
      _page = 0;
      old.dispose();
      return;
    }

    if (_page >= widget.items.length) {
      _page = 0;
      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _jumpTo(int page) {
    if (!_pageController.hasClients) return;
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final spacing = context.read<ThemeCubit>().state.tokens.spacing;

    final items = widget.items;
    if (items.isEmpty) return const SizedBox.shrink();

    final header = Row(
      children: [
        Icon(widget.icon, size: 20, color: c.onSurface.withOpacity(0.85)),
        SizedBox(width: spacing.sm),
        Expanded(
          child: Text(
            widget.title,
            style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if ((widget.trailingText ?? '').trim().isNotEmpty)
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: widget.onTrailingTap,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: spacing.sm,
                vertical: spacing.xs,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.trailingText!,
                    style: t.bodySmall?.copyWith(
                      color: c.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (widget.trailingIcon != null) ...[
                    SizedBox(width: spacing.xs),
                    Icon(widget.trailingIcon, size: 18, color: c.primary),
                  ],
                ],
              ),
            ),
          ),
      ],
    );

    final bool single =
        items.length == 1 && widget.mode == _HomePagerMode.carouselPages;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        header,
        SizedBox(height: spacing.xs),

        if (widget.mode == _HomePagerMode.gridPages)
          _buildGridPager(context, items)
        else if (single)
          _buildSingleCard(context, items.first)
        else
          _buildCarouselPager(context, items),
      ],
    );
  }

  Widget _buildSingleCard(BuildContext context, ItemSummary item) {
    final pricing = widget.pricingFor(item);

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = (w * 0.86).clamp(280.0, 340.0);

        return SizedBox(
          height: h,
          child: ItemCard(
            width: double.infinity,
            title: item.title,
            subtitle: widget.subtitleFor(item),
            imageUrl: item.imageUrl,
            badgeLabel: pricing.currentLabel,
            oldPriceLabel: pricing.oldLabel,
            tagLabel: pricing.tagLabel,
            metaLabel: widget.metaFor(item),
            ctaLabel: widget.ctaLabelFor(item),
            onTap: () => widget.onTapItem(item.id),
            onCtaPressed: () => widget.onCtaPressed(item),
          ),
        );
      },
    );
  }

  Widget _buildCarouselPager(BuildContext context, List<ItemSummary> items) {
    final spacing = context.read<ThemeCubit>().state.tokens.spacing;

    final totalPages = items.length.clamp(1, 999999);
    final safePage = _page.clamp(0, totalPages - 1);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final cardH = (w * 0.86).clamp(280.0, 340.0);

            return SizedBox(
              height: cardH,
              child: PageView.builder(
                controller: _pageController,
                padEnds: false, // ✅ THIS is the main fix for your left gap
                allowImplicitScrolling: true,
                physics: const PageScrollPhysics(),
                onPageChanged: (i) => setState(() => _page = i),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final pricing = widget.pricingFor(item);

                  return Padding(
                    padding: EdgeInsets.only(right: spacing.md),
                    child: ItemCard(
                      width: double.infinity,
                      title: item.title,
                      subtitle: widget.subtitleFor(item),
                      imageUrl: item.imageUrl,
                      badgeLabel: pricing.currentLabel,
                      oldPriceLabel: pricing.oldLabel,
                      tagLabel: pricing.tagLabel,
                      metaLabel: widget.metaFor(item),
                      ctaLabel: widget.ctaLabelFor(item),
                      onTap: () => widget.onTapItem(item.id),
                      onCtaPressed: () => widget.onCtaPressed(item),
                    ),
                  );
                },
              ),
            );
          },
        ),
        SizedBox(height: spacing.sm),
        if (totalPages > 1)
          _DotsPager(
            currentPage0: safePage,
            totalPages: totalPages,
            onDotTap: (p0) => _jumpTo(p0),
          ),
      ],
    );
  }

  Widget _buildGridPager(BuildContext context, List<ItemSummary> items) {
    final spacing = context.read<ThemeCubit>().state.tokens.spacing;

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;

        final rowsPerPage = w < 390 ? 2 : 3;
        const cols = 2;
        final perPage = rowsPerPage * cols;

        final totalPages = (items.length / perPage).ceil().clamp(1, 999999);
        final safePage = _page.clamp(0, totalPages - 1);

        final aspect = w < 420 ? 0.66 : (w < 700 ? 0.74 : 0.82);
        final itemW = (w - spacing.md) / 2.0;
        final itemH = itemW / aspect;
        final gridHeight =
            (rowsPerPage * itemH) + ((rowsPerPage - 1) * spacing.md);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: gridHeight,
              child: PageView.builder(
                controller: _pageController,
                padEnds: false,
                allowImplicitScrolling: true,
                physics: const PageScrollPhysics(),
                onPageChanged: (i) => setState(() => _page = i),
                itemCount: totalPages,
                itemBuilder: (context, pageIndex) {
                  final start = pageIndex * perPage;
                  final end = math.min(start + perPage, items.length);
                  final pageItems = start >= items.length
                      ? <ItemSummary>[]
                      : items.sublist(start, end);

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: spacing.md,
                      crossAxisSpacing: spacing.md,
                      childAspectRatio: aspect,
                    ),
                    itemCount: pageItems.length,
                    itemBuilder: (context, i) {
                      final item = pageItems[i];
                      final pricing = widget.pricingFor(item);

                      return ItemCard(
                        width: double.infinity,
                        title: item.title,
                        subtitle: widget.subtitleFor(item),
                        imageUrl: item.imageUrl,
                        badgeLabel: pricing.currentLabel,
                        oldPriceLabel: pricing.oldLabel,
                        tagLabel: pricing.tagLabel,
                        metaLabel: widget.metaFor(item),
                        ctaLabel: widget.ctaLabelFor(item),
                        onTap: () => widget.onTapItem(item.id),
                        onCtaPressed: () => widget.onCtaPressed(item),
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(height: spacing.sm),
            if (totalPages > 1)
              _DotsPager(
                currentPage0: safePage,
                totalPages: totalPages,
                onDotTap: (p0) => _jumpTo(p0),
              ),
          ],
        );
      },
    );
  }
}

class _DotsPager extends StatelessWidget {
  final int currentPage0;
  final int totalPages;
  final void Function(int page0)? onDotTap;

  const _DotsPager({
    required this.currentPage0,
    required this.totalPages,
    this.onDotTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final spacing = context.read<ThemeCubit>().state.tokens.spacing;

    final current1 = currentPage0 + 1;
    final bool many = totalPages > 8;

    List<int> dotsToShow0() {
      if (!many) return List.generate(totalPages, (i) => i);
      final start = (currentPage0 - 2).clamp(0, totalPages - 1);
      final end = (currentPage0 + 2).clamp(0, totalPages - 1);
      final list = <int>[];
      for (int p = start; p <= end; p++) list.add(p);
      return list;
    }

    final dots0 = dotsToShow0();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Wrap(
          spacing: spacing.xs,
          children: dots0.map((p0) {
            final selected = p0 == currentPage0;
            return GestureDetector(
              onTap: () => onDotTap?.call(p0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: selected ? 16 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: selected ? c.primary : c.outline.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(width: spacing.sm),
        Text(
          '$current1/$totalPages',
          style: t.bodySmall?.copyWith(color: c.onSurface.withOpacity(0.65)),
        ),
      ],
    );
  }
}

class _PricingView {
  final String? currentLabel;
  final String? oldLabel;
  final String? tagLabel;

  const _PricingView({
    required this.currentLabel,
    required this.oldLabel,
    required this.tagLabel,
  });
}

class _TrailingData {
  final String? text;
  final IconData? icon;
  const _TrailingData({this.text, this.icon});
}

class _BookingSection extends StatelessWidget {
  final String title;
  final String placeholderText;

  const _BookingSection({required this.title, required this.placeholderText});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final spacing = context.read<ThemeCubit>().state.tokens.spacing;

    return Container(
      margin: EdgeInsets.only(bottom: spacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: t.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
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
                Expanded(child: Text(placeholderText, style: t.bodySmall)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
