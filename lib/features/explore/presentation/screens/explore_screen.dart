// lib/features/explore/presentation/screens/explore_screen.dart
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

// 🔥 Auth + Cart + Toast
import 'package:build4front/features/auth/presentation/login/bloc/auth_bloc.dart';
import 'package:build4front/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:build4front/features/cart/presentation/bloc/cart_event.dart';
import 'package:build4front/common/widgets/app_toast.dart';

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

  /// Label shown in chips
  String? _selectedCategoryLabel;

  /// Actual category id used for filtering (like Home)
  int? _selectedCategoryId;

  ExploreSortOption _sortOption = ExploreSortOption.relevance;

  @override
  void initState() {
    super.initState();

    // Initialize from navigation arguments
    _searchQuery = (widget.initialQuery ?? '').trim();
    _selectedCategoryLabel = widget.initialCategoryLabel;
    _selectedCategoryId = widget.initialCategoryId;
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
            final categories = homeState.categories; // list of labels
            final categoryEntities =
                homeState.categoryEntities; // with id + name

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
                    _ExploreItemsGrid(
                      items: items,
                      ctaLabelFor: _ctaLabelFor,
                      onCtaPressed: _handleCtaPressed,
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Filter + sort (same style as Home: categoryId-based)
  List<ItemSummary> _buildFilteredAndSortedItems(List<ItemSummary> base) {
    List<ItemSummary> result = base;

    // 1) Filter by search text
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((item) {
        final title = (item.title).toLowerCase();
        final subtitle = (item.subtitle ?? '').toLowerCase();
        final location = (item.location ?? '').toLowerCase();
        return title.contains(query) ||
            subtitle.contains(query) ||
            location.contains(query);
      }).toList();
    }

    // 2) Filter by categoryId (exactly like Home)
    if (_selectedCategoryId != null) {
      result = result
          .where((item) => item.categoryId == _selectedCategoryId)
          .toList();
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

  /// CTA label: same logic as Home
  String _ctaLabelFor(BuildContext context, ItemSummary item) {
    final l10n = AppLocalizations.of(context)!;

    switch (item.kind) {
      case ItemKind.product:
        return l10n.cart_add_button; // "Add to cart"
      case ItemKind.activity:
        return l10n.home_book_now_button; // "Book now"
      case ItemKind.service:
      case ItemKind.unknown:
      default:
        return l10n.home_view_details_button; // "View details"
    }
  }

  /// 🔥 Handle "Add to cart" / "Book now" with AppToast
void _handleCtaPressed(BuildContext context, ItemSummary item) {
    final l10n = AppLocalizations.of(context)!;
    final authState = context.read<AuthBloc>().state;

    // 1) Not logged in → toast only
    if (!authState.isLoggedIn) {
      AppToast.show(context, l10n.cart_login_required_message, isError: true);
      return;
    }

    // 2) PRODUCT → add to cart only, stay on Explore
    if (item.kind == ItemKind.product) {
      context.read<CartBloc>().add(
        CartAddItemRequested(itemId: item.id, quantity: 1),
      );

      AppToast.show(context, l10n.cart_item_added_snackbar);

      // ❌ remove this for now:
      // Navigator.of(context).pushNamed('/cart');

      return;
    }

    // 3) ACTIVITY (future booking logic)
    if (item.kind == ItemKind.activity) {
      AppToast.show(context, l10n.home_book_now_button);
      return;
    }
  }


    // 4) Other kinds → maybe open details later
    // Navigator.of(context).pushNamed('/item-details', arguments: item.id);
  }


/// =======================
///  Category chips (Explore)
/// =======================

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
              (cat == null && selectedCategoryLabel == null) ||
              (cat != null && cat == selectedCategoryLabel);

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

  final String Function(BuildContext, ItemSummary) ctaLabelFor;
  final void Function(BuildContext, ItemSummary) onCtaPressed;

  const _ExploreItemsGrid({
    super.key,
    required this.items,
    required this.ctaLabelFor,
    required this.onCtaPressed,
  });

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
          ctaLabel: ctaLabelFor(context, item),
          onTap: () {
            // TODO: navigate to item details
            // Navigator.pushNamed(context, '/itemDetails', arguments: item.id);
          },
          onCtaPressed: () => onCtaPressed(context, item),
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
