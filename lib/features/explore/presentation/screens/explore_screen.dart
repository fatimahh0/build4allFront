import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4front/core/config/app_config.dart';
import 'package:build4front/l10n/app_localizations.dart';

import 'package:build4front/features/home/presentation/bloc/home_bloc.dart';
import 'package:build4front/features/home/presentation/bloc/home_state.dart';
import 'package:build4front/features/home/presentation/bloc/home_event.dart';

import 'package:build4front/features/items/domain/entities/item_summary.dart';
import 'package:build4front/common/widgets/app_search_field.dart';
import 'package:build4front/common/widgets/ItemCard.dart';

/// Sort options for Explore
enum ExploreSortOption { relevance, priceLowHigh, priceHighLow, dateSoonest }

class ExploreScreen extends StatefulWidget {
  final AppConfig appConfig;

  /// Optional initial search query (from Home search bar).
  final String? initialQuery;

  /// Optional initial category label (from Home chips).
  final String? initialCategoryLabel;

  /// Optional section id (e.g. "new_arrivals", "best_sellers", "flash_sale"...)
  final String? initialSectionId;

  /// Optional category id (from banner targetId).
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
  String? _selectedCategory; // null = All
  ExploreSortOption _sortOption = ExploreSortOption.relevance;

  @override
  void initState() {
    super.initState();

    // Initialize from navigation arguments
    _searchQuery = (widget.initialQuery ?? '').trim();
    _selectedCategory = widget.initialCategoryLabel;
    _sortOption = ExploreSortOption.relevance;

    // Make sure HomeBloc has data (in case Explore is opened first)
    final homeBloc = context.read<HomeBloc>();
    if (!homeBloc.state.hasLoaded && !homeBloc.state.isLoading) {
      homeBloc.add(const HomeStarted());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = theme.colorScheme;
    final t = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, homeState) {
            if (homeState.isLoading && !homeState.hasLoaded) {
              return const Center(child: CircularProgressIndicator());
            }

            // Base items source for explore:
            // Prefer recommended, fallback to popular.
            final List<ItemSummary> baseItems =
                homeState.recommendedItems.isNotEmpty
                ? homeState.recommendedItems
                : homeState.popularItems;

            final items = _buildFilteredAndSortedItems(baseItems);
            final categories = homeState.categories;

            return RefreshIndicator(
              onRefresh: () async {
                context.read<HomeBloc>().add(const HomeRefreshRequested());
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  // 🔍 Search bar
                  AppSearchField(
                    hintText: l10n.explore_search_hint, // add to l10n
                    initialValue: _searchQuery.isEmpty ? null : _searchQuery,
                    onChanged: (value) {
                      setState(() => _searchQuery = value.trim());
                    },
                    onSubmitted: (value) {
                      setState(() => _searchQuery = value.trim());
                    },
                  ),
                  const SizedBox(height: 12),

                  // 🏷 Categories (with "All")
                  if (categories.isNotEmpty)
                    _ExploreCategoryChips(
                      categories: categories,
                      selectedCategory: _selectedCategory,
                      onCategorySelected: (value) {
                        setState(() => _selectedCategory = value);
                      },
                    ),

                  const SizedBox(height: 8),

                  // 🔢 Result count + sort dropdown
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.explore_results_label(items.length),
                          style: t.bodyMedium?.copyWith(
                            color: c.onSurface.withOpacity(0.8),
                          ),
                        ),
                      ),
                      _SortDropdown(
                        current: _sortOption,
                        onChanged: (opt) {
                          setState(() => _sortOption = opt);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  if (items.isEmpty)
                    _EmptyExploreState(
                      message: l10n.explore_empty_message, // add to l10n
                    )
                  else
                    _ExploreItemsGrid(items: items),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<ItemSummary> _buildFilteredAndSortedItems(List<ItemSummary> base) {
    List<ItemSummary> result = base;

    // 1) Filter by search text
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((item) {
        final title = (item.title).toLowerCase();
        final location = (item.location ?? '').toLowerCase();
        return title.contains(query) || location.contains(query);
      }).toList();
    }

    // 2) Filter by category (if any selected)
    if (_selectedCategory != null && _selectedCategory!.trim().isNotEmpty) {
      final cat = _selectedCategory!.toLowerCase();
      result = result.where((item) {
        // For now: match in title or location.
        final title = (item.title).toLowerCase();
        final location = (item.location ?? '').toLowerCase();
        return title.contains(cat) || location.contains(cat);
      }).toList();
    }

    // 3) Sort
    result = List<ItemSummary>.from(result); // defensive copy

    switch (_sortOption) {
      case ExploreSortOption.relevance:
        // Keep original order (from backend/HomeBloc)
        break;

      case ExploreSortOption.priceLowHigh:
        result.sort((a, b) {
          final ap = a.price ?? double.infinity;
          final bp = b.price ?? double.infinity;
          return ap.compareTo(bp);
        });
        break;

      case ExploreSortOption.priceHighLow:
        result.sort((a, b) {
          final ap = a.price ?? -1;
          final bp = b.price ?? -1;
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
}

/// =======================
///  Category chips (Explore)
/// =======================

class _ExploreCategoryChips extends StatelessWidget {
  final List<String> categories;
  final String? selectedCategory;
  final ValueChanged<String?> onCategorySelected;

  const _ExploreCategoryChips({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    // build list: [All, ...categories]
    final List<String?> allCats = [null, ...categories];

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: allCats.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = allCats[index]; // null = All
          final bool isSelected =
              (cat == null && selectedCategory == null) ||
              (cat != null && cat == selectedCategory);

          final label =
              cat ?? AppLocalizations.of(context)!.explore_category_all;

          return GestureDetector(
            onTap: () => onCategorySelected(cat),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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

/// =======================
///  Sort dropdown
/// =======================

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
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.outline.withOpacity(0.4)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<ExploreSortOption>(
          value: current,
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
              child: Text(labelFor(opt)),
            );
          }).toList(),
        ),
      ),
    );
  }
}

/// =======================
///  Items grid (2 per row)
/// =======================

class _ExploreItemsGrid extends StatelessWidget {
  final List<ItemSummary> items;

  const _ExploreItemsGrid({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(), // scrolling handled by ListView
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 🔹 2 per row
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.7, // tweak if cards look too tall/wide
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final meta = _buildMetaLabel(item);
        final priceLabel = item.price != null ? '${item.price} \$' : null;

        return ItemCard(
          title: item.title,
          subtitle: item.location,
          imageUrl: item.imageUrl,
          badgeLabel: priceLabel,
          metaLabel: meta,
          onTap: () {
            // TODO: navigate to item details
            // Navigator.pushNamed(context, '/itemDetails', arguments: item.id);
          },
        );
      },
    );
  }

  String? _buildMetaLabel(ItemSummary item) {
    if (item.start != null) {
      // later: use intl + localized format
      return item.start!.toLocal().toString().substring(0, 16);
    }
    return null;
  }
}

/// =======================
///  Empty state
/// =======================

class _EmptyExploreState extends StatelessWidget {
  final String message;

  const _EmptyExploreState({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.outline.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.search_off_rounded, color: c.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(message, style: t.bodyMedium)),
        ],
      ),
    );
  }
}
