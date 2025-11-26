// lib/features/home/presentation/screens/home_screen.dart

import 'package:flutter/material.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/config/home_config.dart';

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
    final enabled = appConfig.enabledFeatures.toSet();

    final visibleSections = sections.where((s) {
      if (s.feature == null) return true;
      return enabled.contains(s.feature);
    }).toList();

    return Scaffold(
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          itemCount: visibleSections.length,
          itemBuilder: (context, index) {
            final section = visibleSections[index];
            return _buildSection(context, theme, section);
          },
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    ThemeData theme,
    HomeSectionConfig section,
  ) {
    switch (section.type) {
      case HomeSectionType.header:
        return _HeaderSection(appName: appConfig.appName);
      case HomeSectionType.search:
        return const _SearchSection();
      case HomeSectionType.categoryChips:
        return const _CategoryChipsSection();
      case HomeSectionType.banner:
        return _BannerSection(title: section.title);
      case HomeSectionType.itemList:
        return _ItemsSection(
          title: section.title ?? 'Items',
          layout: section.layout,
        );
      case HomeSectionType.bookingList:
        return _BookingSection(title: section.title ?? 'Bookings');
      case HomeSectionType.reviewList:
        return _ReviewsSection(
          title: section.title ?? 'Reviews',
          layout: section.layout,
        );
    }
  }
}

/// ===================
///  SECTIONS
/// ===================

class _HeaderSection extends StatelessWidget {
  final String appName;

  const _HeaderSection({required this.appName});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: c.primary.withOpacity(0.15),
            child: Icon(Icons.star_rounded, color: c.primary),
            // TODO: later: NetworkImage(Env.appLogoUrl)
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome 👋', style: t.labelLarge),
                Text(
                  appName,
                  style: t.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded),
          ),
        ],
      ),
    );
  }
}

class _SearchSection extends StatelessWidget {
  const _SearchSection();

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search activities, items...',
          prefixIcon: const Icon(Icons.search_rounded),
          filled: true,
          fillColor: c.surface,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 0,
            horizontal: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: c.outline.withOpacity(0.2)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: c.outline.withOpacity(0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: c.primary, width: 1.4),
          ),
        ),
      ),
    );
  }
}

class _CategoryChipsSection extends StatelessWidget {
  const _CategoryChipsSection();

  @override
  Widget build(BuildContext context) {
    final categories = ['All', 'Sports', 'Art', 'Cooking', 'Music', 'Tech'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = index == 0; // TODO: bind to state later
          final c = Theme.of(context).colorScheme;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? c.primary : c.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? c.primary : c.outline.withOpacity(0.3),
              ),
            ),
            child: Text(
              categories[index],
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isSelected ? c.onPrimary : c.onSurface,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BannerSection extends StatelessWidget {
  final String? title;

  const _BannerSection({this.title});

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
                  title ?? 'Discover your next hobby',
                  style: t.headlineSmall?.copyWith(color: c.onPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  'Explore activities, classes and more near you.',
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
                  onPressed: () {},
                  child: const Text('Start exploring'),
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

class _ItemsSection extends StatelessWidget {
  final String title;
  final String layout; // horizontal / vertical

  const _ItemsSection({required this.title, required this.layout});

  @override
  Widget build(BuildContext context) {
    final isHorizontal = layout.toLowerCase() == 'horizontal';
    final dummyItems = List.generate(5, (i) => 'Item #${i + 1}');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: title, icon: Icons.local_activity_outlined),
          const SizedBox(height: 8),
          SizedBox(
            height: isHorizontal ? 190 : null,
            child: isHorizontal
                ? ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) =>
                        _FakeCard(label: dummyItems[index]),
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemCount: dummyItems.length,
                  )
                : Column(
                    children: dummyItems
                        .map(
                          (e) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _FakeCard(label: e),
                          ),
                        )
                        .toList(),
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
    final dummy = List.generate(3, (i) => 'Booking #${i + 1}');
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: title, icon: Icons.event_available_outlined),
          const SizedBox(height: 8),
          Column(
            children: dummy
                .map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _FakeCard(label: e),
                  ),
                )
                .toList(),
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
    final isHorizontal = layout.toLowerCase() == 'horizontal';
    final dummy = List.generate(4, (i) => 'Review #${i + 1}');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: title, icon: Icons.reviews_outlined),
          const SizedBox(height: 8),
          SizedBox(
            height: isHorizontal ? 160 : null,
            child: isHorizontal
                ? ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) =>
                        _FakeCard(label: dummy[index]),
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemCount: dummy.length,
                  )
                : Column(
                    children: dummy
                        .map(
                          (e) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _FakeCard(label: e),
                          ),
                        )
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

/// ===================
///  SMALL WIDGETS
/// ===================

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Text(title, style: t.titleMedium),
      ],
    );
  }
}

class _FakeCard extends StatelessWidget {
  final String label;

  const _FakeCard({required this.label});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    // if you want to read from tokens instead of hard-coding:
    // final card = context.read<ThemeCubit>().state.tokens.card;

    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(0), // 👈 radius 0
        border: Border.all(color: c.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // image placeholder
          Container(
            height: 90,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(0), // 👈 radius 0
              ),
              color: c.primary.withOpacity(0.15),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: t.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Short description...',
                  style: t.bodySmall?.copyWith(
                    color: c.onSurface.withOpacity(0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
