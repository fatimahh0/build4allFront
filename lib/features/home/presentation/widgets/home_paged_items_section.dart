import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:build4front/core/theme/theme_cubit.dart';
import 'package:build4front/common/widgets/ItemCard.dart';
import 'package:build4front/features/items/domain/entities/item_summary.dart';

enum HomePagerMode { carouselPages, gridPages }

class HomePagedItemsSection extends StatefulWidget {
  final String title;
  final IconData icon;

  final String? trailingText;
  final IconData? trailingIcon;
  final VoidCallback? onTrailingTap;

  final List<ItemSummary> items;
  final HomePagerMode mode;

  final PricingView Function(ItemSummary) pricingFor;
  final String? Function(ItemSummary) subtitleFor;
  final String? Function(ItemSummary) metaFor;
  final String Function(ItemSummary) ctaLabelFor;

  final void Function(int itemId) onTapItem;
  final void Function(ItemSummary item) onCtaPressed;

  const HomePagedItemsSection({
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
  State<HomePagedItemsSection> createState() => _HomePagedItemsSectionState();
}

/// Small helper type to avoid importing your private class.
/// Same fields you already use.
class PricingView {
  final String? currentLabel;
  final String? oldLabel;
  final String? tagLabel;
  const PricingView({this.currentLabel, this.oldLabel, this.tagLabel});
}

class _HomePagedItemsSectionState extends State<HomePagedItemsSection> {
  late PageController _pageController;
  int _page = 0;

  double get _vf => widget.mode == HomePagerMode.carouselPages ? 0.84 : 1.0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: _vf);
  }

  @override
  void didUpdateWidget(covariant HomePagedItemsSection oldWidget) {
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
      if (_pageController.hasClients) _pageController.jumpToPage(0);
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
        items.length == 1 && widget.mode == HomePagerMode.carouselPages;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        header,
        SizedBox(height: spacing.xs), // ✅ no gap
        if (widget.mode == HomePagerMode.gridPages)
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
        final h = (w * 0.86).clamp(280.0, 350.0);

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
            final cardH = (w * 0.86).clamp(280.0, 350.0);

            return SizedBox(
              height: cardH,
              child: PageView.builder(
                controller: _pageController,
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
