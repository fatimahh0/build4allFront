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

import 'package:build4front/features/items/domain/entities/item_summary.dart';
import 'package:build4front/common/widgets/ItemCard.dart';

// ✅ details page (same behavior as Explore)
import 'package:build4front/features/itemsDetails/presentation/screens/item_details_page.dart';

// ✅ CTA add-to-cart + toast
import 'package:build4front/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:build4front/features/cart/presentation/bloc/cart_event.dart';
import 'package:build4front/common/widgets/app_toast.dart';

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

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  String _searchQuery = '';
  int? _selectedCategoryId;

  Timer? _searchDebounce;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    // ✅ start loading ONCE (not inside build)
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

  void _onSearchChangedDebounced(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 280), () {
      if (!mounted) return;
      setState(() => _searchQuery = value.trim());
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

    final filterStamp = '${_selectedCategoryId ?? 'all'}|$_searchQuery';

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
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // ✅ nice width on iPad/desktop
                      final maxW = constraints.maxWidth;
                      final contentMaxWidth = maxW > 900 ? 900.0 : maxW;

                      return Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: contentMaxWidth,
                          ),
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
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
                                filterStamp: filterStamp,
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
    required String filterStamp,
    String? fullName,
    String? avatarUrl,
  }) {
    final spacing = context.read<ThemeCubit>().state.tokens.spacing;

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
          margin: EdgeInsets.only(bottom: spacing.md),
          child: AppSearchField(
            hintText: l10n.home_search_hint,
            onChanged: _onSearchChangedDebounced, // ✅ typing search
            onSubmitted: (value) => setState(() => _searchQuery = value.trim()),
          ),
        );

      case HomeSectionType.categoryChips:
        return HomeCategoryChips(
          categories: [l10n.explore_category_all, ...homeState.categories],
          onCategoryTap: (categoryName) {
            final selected = categoryName.trim();

            if (selected.isEmpty || selected == l10n.explore_category_all) {
              setState(() => _selectedCategoryId = null);
              return;
            }

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
        return Padding(
          padding: EdgeInsets.only(bottom: spacing.lg),
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
        final trailing = _trailingForSection(section);

        // ✅ IMPORTANT:
        // - new_arrivals MUST be paginated too (no take(6) anymore)
        // - grid forced for new_arrivals
        final effectiveLayout = section.id == 'new_arrivals'
            ? _HomeLayout.grid
            : ((section.layout ?? 'horizontal') == 'grid'
                  ? _HomeLayout.grid
                  : _HomeLayout.pagedRow);

        return Padding(
          padding: EdgeInsets.only(bottom: spacing.lg),
          child: _HomeItemsSectionPaged(
            key: PageStorageKey('home_section_${section.id}'),
            sectionId: section.id ?? 'items',
            filterStamp: filterStamp,
            title: sectionTitle,
            icon: icon,
            trailingText: trailing.text,
            trailingIcon: trailing.icon,
            onTrailingTap: () {
              Navigator.of(
                context,
              ).pushNamed('/explore', arguments: {'sectionId': section.id});
            },
            layout: effectiveLayout,
            items: itemsForSection,
            ctaLabelFor: (item) => _ctaLabelFor(context, item),
            subtitleFor: _subtitleFor,
            metaFor: _metaLabelFor,
            pricingFor: _pricingFor,
            onTapItem: (id) => _openDetails(context, id), // ✅ no login redirect
            onCtaPressed: (item) => _handleCtaPressed(context, item),
          ),
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

  // =========================
  // Filters
  // =========================
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

  // =========================
  // Section mapping
  // =========================
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

  // =========================
  // Details + CTA behavior
  // =========================
  void _openDetails(BuildContext context, int itemId) {
    // ✅ EXACTLY like Explore: push page directly (no auth-guarded route)
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

  String? _metaLabelFor(ItemSummary item) {
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
        return 'Stock: ${item.stock}';

      default:
        return null;
    }
  }

  void _handleCtaPressed(BuildContext context, ItemSummary item) {
    final l10n = AppLocalizations.of(context)!;
    final auth = context.read<AuthBloc>().state;

    // ✅ keep your behavior for cart
    if (!auth.isLoggedIn && item.kind == ItemKind.product) {
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

  // =========================
  // Pricing (sale window)
  // =========================
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

  _PricingView _pricingFor(ItemSummary item) {
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
      tagLabel = percent > 0 ? '-$percent%' : 'SALE';
    }

    return _PricingView(
      currentLabel: currentLabel,
      oldLabel: oldLabel,
      tagLabel: tagLabel,
    );
  }
}

// =========================
// Section pager UI (swipe + dots)
// =========================

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

enum _HomeLayout { grid, pagedRow }

class _HomeItemsSectionPaged extends StatefulWidget {
  final String sectionId;
  final String filterStamp;

  final String title;
  final IconData icon;

  final String? trailingText;
  final IconData? trailingIcon;
  final VoidCallback? onTrailingTap;

  final _HomeLayout layout;
  final List<ItemSummary> items;

  final _PricingView Function(ItemSummary) pricingFor;
  final String? Function(ItemSummary) subtitleFor;
  final String? Function(ItemSummary) metaFor;
  final String Function(ItemSummary) ctaLabelFor;

  final void Function(int itemId) onTapItem;
  final void Function(ItemSummary item) onCtaPressed;

  const _HomeItemsSectionPaged({
    super.key,
    required this.sectionId,
    required this.filterStamp,
    required this.title,
    required this.icon,
    required this.trailingText,
    required this.trailingIcon,
    required this.onTrailingTap,
    required this.layout,
    required this.items,
    required this.pricingFor,
    required this.subtitleFor,
    required this.metaFor,
    required this.ctaLabelFor,
    required this.onTapItem,
    required this.onCtaPressed,
  });

  @override
  State<_HomeItemsSectionPaged> createState() => _HomeItemsSectionPagedState();
}

class _HomeItemsSectionPagedState extends State<_HomeItemsSectionPaged> {
  late final PageController _pc;
  int _pageIndex = 0;

  static const int _gridRows = 3;
  static const int _gridCols = 2;
  static const int _gridPerPage = _gridRows * _gridCols; // 6

  static const int _rowPerPage = 2; // 2 cards per swipe

  int get _itemsPerPage =>
      widget.layout == _HomeLayout.grid ? _gridPerPage : _rowPerPage;

  int _totalPages() {
    if (widget.items.isEmpty) return 1;
    return (widget.items.length / _itemsPerPage).ceil();
  }

  int _clampPageIndex(int idx, int totalPages) {
    if (totalPages <= 0) return 0;
    return math.max(0, math.min(idx, totalPages - 1));
  }

  @override
  void initState() {
    super.initState();
    _pc = PageController();
  }

  @override
  void didUpdateWidget(covariant _HomeItemsSectionPaged oldWidget) {
    super.didUpdateWidget(oldWidget);

    final total = _totalPages();

    // ✅ if filters changed -> reset to first page
    if (oldWidget.filterStamp != widget.filterStamp) {
      _pageIndex = 0;
      if (_pc.hasClients) _pc.jumpToPage(0);
      setState(() {});
      return;
    }

    // ✅ if item count shrank -> clamp current page
    final safe = _clampPageIndex(_pageIndex, total);
    if (safe != _pageIndex) {
      _pageIndex = safe;
      if (_pc.hasClients) _pc.jumpToPage(_pageIndex);
      setState(() {});
    }
  }

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final spacing = context.read<ThemeCubit>().state.tokens.spacing;

    final totalPages = _totalPages();
    final safeIndex = _clampPageIndex(_pageIndex, totalPages);

    Widget header = Row(
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
                vertical: spacing.xs + 2,
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

    Widget pager = totalPages <= 1
        ? const SizedBox.shrink()
        : Padding(
            padding: EdgeInsets.only(top: spacing.sm),
            child: _DotsPager(
              count: totalPages,
              index: safeIndex,
              onTap: (i) {
                _pc.animateToPage(
                  i,
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOut,
                );
              },
            ),
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        header,
        SizedBox(height: spacing.sm),

        // ✅ content + dynamic height (no overflow)
        LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;

            if (widget.layout == _HomeLayout.grid) {
              final double aspect = w <= 420 ? 0.52 : (w <= 700 ? 0.60 : 0.70);

              final tileW = (w - spacing.md) / 2.0;
              final tileH = tileW / aspect;

              final gridH =
                  (_gridRows * tileH) + ((_gridRows - 1) * spacing.md);

              return Column(
                children: [
                  SizedBox(
                    height: gridH,
                    child: PageView.builder(
                      controller: _pc,
                      onPageChanged: (i) => setState(() => _pageIndex = i),
                      itemCount: totalPages,
                      itemBuilder: (context, page) {
                        final start = page * _itemsPerPage;
                        final end = math.min(
                          start + _itemsPerPage,
                          widget.items.length,
                        );
                        final pageItems = widget.items.sublist(start, end);

                        return GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: spacing.md,
                                crossAxisSpacing: spacing.md,
                                childAspectRatio: aspect,
                              ),
                          itemCount: pageItems.length,
                          itemBuilder: (context, idx) {
                            final item = pageItems[idx];
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
                  pager,
                ],
              );
            }

            // ✅ paged row (2 items per swipe)
            final double pageH = w <= 360 ? 310.0 : (w <= 700 ? 300.0 : 285.0);

            return Column(
              children: [
                SizedBox(
                  height: pageH,
                  child: PageView.builder(
                    controller: _pc,
                    onPageChanged: (i) => setState(() => _pageIndex = i),
                    itemCount: totalPages,
                    itemBuilder: (context, page) {
                      final start = page * _itemsPerPage;
                      final end = math.min(
                        start + _itemsPerPage,
                        widget.items.length,
                      );
                      final pageItems = widget.items.sublist(start, end);

                      return Row(
                        children: [
                          Expanded(
                            child: _RowCard(
                              item: pageItems.isNotEmpty ? pageItems[0] : null,
                              pricingFor: widget.pricingFor,
                              subtitleFor: widget.subtitleFor,
                              metaFor: widget.metaFor,
                              ctaLabelFor: widget.ctaLabelFor,
                              onTapItem: widget.onTapItem,
                              onCtaPressed: widget.onCtaPressed,
                            ),
                          ),
                          SizedBox(width: spacing.md),
                          Expanded(
                            child: _RowCard(
                              item: pageItems.length > 1 ? pageItems[1] : null,
                              pricingFor: widget.pricingFor,
                              subtitleFor: widget.subtitleFor,
                              metaFor: widget.metaFor,
                              ctaLabelFor: widget.ctaLabelFor,
                              onTapItem: widget.onTapItem,
                              onCtaPressed: widget.onCtaPressed,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                pager,
              ],
            );
          },
        ),
      ],
    );
  }
}

class _RowCard extends StatelessWidget {
  final ItemSummary? item;

  final _PricingView Function(ItemSummary) pricingFor;
  final String? Function(ItemSummary) subtitleFor;
  final String? Function(ItemSummary) metaFor;
  final String Function(ItemSummary) ctaLabelFor;

  final void Function(int itemId) onTapItem;
  final void Function(ItemSummary item) onCtaPressed;

  const _RowCard({
    required this.item,
    required this.pricingFor,
    required this.subtitleFor,
    required this.metaFor,
    required this.ctaLabelFor,
    required this.onTapItem,
    required this.onCtaPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (item == null) return const SizedBox.shrink();

    final pricing = pricingFor(item!);

    return ItemCard(
      width: double.infinity,
      title: item!.title,
      subtitle: subtitleFor(item!),
      imageUrl: item!.imageUrl,
      badgeLabel: pricing.currentLabel,
      oldPriceLabel: pricing.oldLabel,
      tagLabel: pricing.tagLabel,
      metaLabel: metaFor(item!),
      ctaLabel: ctaLabelFor(item!),
      onTap: () => onTapItem(item!.id),
      onCtaPressed: () => onCtaPressed(item!),
    );
  }
}

class _DotsPager extends StatelessWidget {
  final int count;
  final int index;
  final ValueChanged<int>? onTap;

  const _DotsPager({required this.count, required this.index, this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final spacing = context.read<ThemeCubit>().state.tokens.spacing;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final selected = i == index;
        return GestureDetector(
          onTap: onTap == null ? null : () => onTap!(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: EdgeInsets.symmetric(horizontal: spacing.xs),
            width: selected ? 18 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: selected ? c.primary : c.outline.withOpacity(0.35),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        );
      }),
    );
  }
}

// =========================
// Trailing helpers
// =========================

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

// =========================
// Existing “info” sections (same idea as yours)
// =========================

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
