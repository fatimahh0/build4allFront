import 'package:build4front/features/itemsDetails/presentation/screens/item_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4front/core/config/app_config.dart';
import 'package:build4front/core/theme/theme_cubit.dart';
import 'package:build4front/l10n/app_localizations.dart';

import 'package:build4front/features/home/presentation/bloc/home_bloc.dart';
import 'package:build4front/features/home/presentation/bloc/home_state.dart';
import 'package:build4front/features/home/presentation/bloc/home_event.dart';

import 'package:build4front/features/items/domain/entities/item_summary.dart';
import 'package:build4front/common/widgets/app_search_field.dart';
import 'package:build4front/common/widgets/ItemCard.dart';

// 🔥 Auth + Cart + Toast
import 'package:build4front/features/auth/presentation/login/bloc/auth_bloc.dart';
import 'package:build4front/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:build4front/features/cart/presentation/bloc/cart_event.dart';
import 'package:build4front/common/widgets/app_toast.dart';

enum ExploreSortOption { relevance, priceLowHigh, priceHighLow, dateSoonest }

class ExploreScreen extends StatefulWidget {
  final AppConfig appConfig;

  final String? initialQuery;
  final String? initialCategoryLabel;
  final String? initialSectionId;
  final int? initialCategoryId;

  const ExploreScreen({
    super.key,
    required this.appConfig,
    this.initialQuery,
    this.initialCategoryLabel,
    this.initialSectionId,
    this.initialCategoryId,
  });

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  late String _searchQuery;
  String? _selectedCategoryLabel;
  int? _selectedCategoryId;
  ExploreSortOption _sortOption = ExploreSortOption.relevance;

  @override
  void initState() {
    super.initState();
    _searchQuery = (widget.initialQuery ?? '').trim();
    _selectedCategoryLabel = widget.initialCategoryLabel;
    _selectedCategoryId = widget.initialCategoryId;
    _sortOption = ExploreSortOption.relevance;

    final homeBloc = context.read<HomeBloc>();
    if (!homeBloc.state.hasLoaded && !homeBloc.state.isLoading) {
      homeBloc.add(const HomeStarted());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themeState = context.watch<ThemeCubit>().state;
    final spacing = themeState.tokens.spacing;

    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, homeState) {
            if (homeState.isLoading && !homeState.hasLoaded) {
              return const Center(child: CircularProgressIndicator());
            }

            final baseItems = _baseItemsForExplore(homeState);
            final items = _buildFilteredAndSortedItems(baseItems);

            final categories = homeState.categories;
            final categoryEntities = homeState.categoryEntities;

            return RefreshIndicator(
              onRefresh: () async {
                context.read<HomeBloc>().add(const HomeRefreshRequested());
              },
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  spacing.lg,
                  spacing.lg,
                  spacing.lg,
                  spacing.xl,
                ),
                children: [
                  AppSearchField(
                    hintText: l10n.explore_search_hint,
                    initialValue: _searchQuery.isEmpty ? null : _searchQuery,
                    onChanged: (value) =>
                        setState(() => _searchQuery = value.trim()),
                    onSubmitted: (value) =>
                        setState(() => _searchQuery = value.trim()),
                  ),
                  SizedBox(height: spacing.md),

                  if (categories.isNotEmpty)
                    _ExploreCategoryChips(
                      categories: categories,
                      selectedCategoryLabel: _selectedCategoryLabel,
                      onCategorySelected: (label) {
                        int? foundId;

                        if (label != null && label.trim().isNotEmpty) {
                          for (final cat in categoryEntities) {
                            if (cat.name == label) {
                              foundId = cat.id;
                              break;
                            }
                          }
                        }

                        setState(() {
                          _selectedCategoryLabel = label;
                          _selectedCategoryId = foundId;
                        });
                      },
                    ),

                  SizedBox(height: spacing.sm),

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.explore_results_label(items.length),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _SortDropdown(
                        current: _sortOption,
                        onChanged: (opt) => setState(() => _sortOption = opt),
                      ),
                    ],
                  ),

                  SizedBox(height: spacing.md),

                  if (items.isEmpty)
                    _EmptyExploreState(message: l10n.explore_empty_message)
                  else
                    _ExploreItemsGrid(
                      items: items,
                      pricingFor: _pricingFor,
                      subtitleFor: _subtitleFor,
                      metaFor: _metaLabelFor,
                      ctaLabelFor: _ctaLabelFor,
                      onTapItem: (id) => _openDetails(context, id),
                      onCtaPressed: (item) => _handleCtaPressed(context, item),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<ItemSummary> _baseItemsForExplore(HomeState homeState) {
    final sid = (widget.initialSectionId ?? '').trim();

    if (sid == 'flash_sale') {
      return homeState.flashSaleItems.isNotEmpty
          ? homeState.flashSaleItems
          : homeState.popularItems;
    }
    if (sid == 'new_arrivals') {
      return homeState.newArrivalsItems.isNotEmpty
          ? homeState.newArrivalsItems
          : homeState.popularItems;
    }
    if (sid == 'best_sellers') {
      return homeState.bestSellersItems.isNotEmpty
          ? homeState.bestSellersItems
          : homeState.popularItems;
    }
    if (sid == 'top_rated') {
      return homeState.topRatedItems.isNotEmpty
          ? homeState.topRatedItems
          : homeState.popularItems;
    }

    return homeState.recommendedItems.isNotEmpty
        ? homeState.recommendedItems
        : homeState.popularItems;
  }

  List<ItemSummary> _buildFilteredAndSortedItems(List<ItemSummary> base) {
    List<ItemSummary> result = base;

    // search
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((item) {
        final title = item.title.toLowerCase();
        final subtitle = (item.subtitle ?? '').toLowerCase();
        final location = (item.location ?? '').toLowerCase();
        return title.contains(query) ||
            subtitle.contains(query) ||
            location.contains(query);
      }).toList();
    }

    // categoryId filter
    if (_selectedCategoryId != null) {
      result = result
          .where((item) => item.categoryId == _selectedCategoryId)
          .toList();
    }

    // sort
    result = List<ItemSummary>.from(result);

    switch (_sortOption) {
      case ExploreSortOption.relevance:
        break;

      case ExploreSortOption.priceLowHigh:
        result.sort((a, b) {
          final ap = (_currentPrice(a) ?? double.infinity).toDouble();
          final bp = (_currentPrice(b) ?? double.infinity).toDouble();
          return ap.compareTo(bp);
        });
        break;

      case ExploreSortOption.priceHighLow:
        result.sort((a, b) {
          final ap = (_currentPrice(a) ?? -1).toDouble();
          final bp = (_currentPrice(b) ?? -1).toDouble();
          return bp.compareTo(ap);
        });
        break;

      case ExploreSortOption.dateSoonest:
        result.sort((a, b) {
          final ad = a.start;
          final bd = b.start;
          if (ad == null && bd == null) return 0;
          if (ad == null) return 1;
          if (bd == null) return -1;
          return ad.compareTo(bd);
        });
        break;
    }

    return result;
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

  // =========================
  // ✅ pricing (sale window)
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
// UI pieces
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

class _ExploreCategoryChips extends StatelessWidget {
  final List<String> categories;
  final String? selectedCategoryLabel;
  final ValueChanged<String?> onCategorySelected;

  const _ExploreCategoryChips({
    super.key,
    required this.categories,
    required this.selectedCategoryLabel,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final spacing = context.read<ThemeCubit>().state.tokens.spacing;

    final List<String?> allCats = [null, ...categories];

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: allCats.length,
        separatorBuilder: (_, __) => SizedBox(width: spacing.sm),
        itemBuilder: (context, index) {
          final cat = allCats[index];
          final bool isSelected =
              (cat == null && selectedCategoryLabel == null) ||
              (cat != null && cat == selectedCategoryLabel);

          final label =
              cat ?? AppLocalizations.of(context)!.explore_category_all;

          return GestureDetector(
            onTap: () => onCategorySelected(cat),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: spacing.md,
                vertical: spacing.xs + 2,
              ),
              decoration: BoxDecoration(
                color: isSelected ? c.primary : c.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? c.primary : c.outline.withOpacity(0.3),
                ),
              ),
              child: Text(
                label,
                style: t.bodyMedium?.copyWith(
                  color: isSelected ? c.onPrimary : c.onSurface,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SortDropdown extends StatelessWidget {
  final ExploreSortOption current;
  final ValueChanged<ExploreSortOption> onChanged;

  const _SortDropdown({
    super.key,
    required this.current,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final l = AppLocalizations.of(context)!;
    final spacing = context.read<ThemeCubit>().state.tokens.spacing;

    String labelFor(ExploreSortOption opt) {
      switch (opt) {
        case ExploreSortOption.relevance:
          return l.explore_sort_relevance;
        case ExploreSortOption.priceLowHigh:
          return l.explore_sort_price_low_high;
        case ExploreSortOption.priceHighLow:
          return l.explore_sort_price_high_low;
        case ExploreSortOption.dateSoonest:
          return l.explore_sort_date_soonest;
      }
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: spacing.sm),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.outline.withOpacity(0.4)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ExploreSortOption>(
          value: current,
          isDense: true,
          icon: Icon(
            Icons.expand_more_rounded,
            size: 20,
            color: c.onSurface.withOpacity(0.8),
          ),
          style: t.bodyMedium,
          onChanged: (value) {
            if (value != null) onChanged(value);
          },
          items: ExploreSortOption.values.map((opt) {
            return DropdownMenuItem<ExploreSortOption>(
              value: opt,
              child: Text(labelFor(opt), overflow: TextOverflow.ellipsis),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _ExploreItemsGrid extends StatelessWidget {
  final List<ItemSummary> items;

  final _PricingView Function(ItemSummary) pricingFor;
  final String? Function(ItemSummary) subtitleFor;
  final String? Function(ItemSummary) metaFor;

  final String Function(BuildContext, ItemSummary) ctaLabelFor;
  final void Function(int itemId) onTapItem;
  final void Function(ItemSummary) onCtaPressed;

  const _ExploreItemsGrid({
    super.key,
    required this.items,
    required this.pricingFor,
    required this.subtitleFor,
    required this.metaFor,
    required this.ctaLabelFor,
    required this.onTapItem,
    required this.onCtaPressed,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = context.read<ThemeCubit>().state.tokens.spacing;

    // ✅ KEY FIX: responsive grid sizing + taller tiles
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;

        // 1 col on super small, else auto columns
        int crossAxisCount;
        if (maxWidth < 360) {
          crossAxisCount = 1;
        } else {
          // target width per tile (tweakable)
          const targetTileWidth = 190.0;
          crossAxisCount = (maxWidth / targetTileWidth).floor();
          crossAxisCount = crossAxisCount.clamp(2, 4);
        }

        final tileWidth =
            (maxWidth - (crossAxisCount - 1) * spacing.md) / crossAxisCount;

        // Taller tiles on small widths to avoid Column overflow in ItemCard
        final double heightFactor = tileWidth < 170
            ? 2.05
            : (tileWidth < 210 ? 1.9 : 1.78);

        final childAspectRatio = 1 / heightFactor; // width / height

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: spacing.md,
            crossAxisSpacing: spacing.md,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final pricing = pricingFor(item);

            return ItemCard(
              // ✅ IMPORTANT: don’t force 160 width inside a grid cell
              width: double.infinity,

              title: item.title,
              subtitle: subtitleFor(item),
              imageUrl: item.imageUrl,

              badgeLabel: pricing.currentLabel,
              oldPriceLabel: pricing.oldLabel,
              tagLabel: pricing.tagLabel,

              metaLabel: metaFor(item),
              ctaLabel: ctaLabelFor(context, item),
              onTap: () => onTapItem(item.id),
              onCtaPressed: () => onCtaPressed(item),
            );
          },
        );
      },
    );
  }
}

class _EmptyExploreState extends StatelessWidget {
  final String message;
  const _EmptyExploreState({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final spacing = context.read<ThemeCubit>().state.tokens.spacing;

    return Container(
      margin: EdgeInsets.only(top: spacing.lg),
      padding: EdgeInsets.all(spacing.md),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.outline.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.search_off_rounded, color: c.primary),
          SizedBox(width: spacing.sm),
          Expanded(child: Text(message, style: t.bodyMedium)),
        ],
      ),
    );
  }
}
