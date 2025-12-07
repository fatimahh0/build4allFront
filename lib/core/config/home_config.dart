import 'dart:convert';
import 'package:flutter/material.dart';
import 'env.dart';
import 'app_config.dart';

enum HomeSectionType {
  header, // logo + welcome
  search, // search bar
  categoryChips, // horizontal chips row
  banner, // hero / promo card (slider)
  itemList, // items list (flash / new arrivals / ...)
  bookingList, // upcoming bookings
  reviewList, // latest reviews OR "Why Shop With Us"
}

HomeSectionType _parseType(String raw) {
  switch (raw.toUpperCase()) {
    case 'HEADER':
      return HomeSectionType.header;
    case 'SEARCH':
      return HomeSectionType.search;
    case 'CATEGORY_CHIPS':
      return HomeSectionType.categoryChips;
    case 'BANNER':
      return HomeSectionType.banner;
    case 'ITEM_LIST':
      return HomeSectionType.itemList;
    case 'BOOKING_LIST':
      return HomeSectionType.bookingList;
    case 'REVIEW_LIST':
      return HomeSectionType.reviewList;
    default:
      return HomeSectionType.itemList;
  }
}

/// config سكشن واحد
class HomeSectionConfig {
  final String id;
  final HomeSectionType type;
  final String? title;
  final String? feature; // ITEMS / BOOKING / REVIEWS / ORDERS...
  final String layout; // horizontal / vertical / full
  final int limit;

  const HomeSectionConfig({
    required this.id,
    required this.type,
    required this.layout,
    required this.limit,
    this.title,
    this.feature,
  });

  factory HomeSectionConfig.fromJson(Map<String, dynamic> json) {
    return HomeSectionConfig(
      id: json['id'] as String,
      type: _parseType(json['type'] as String),
      title: json['title'] as String?,
      feature: json['feature'] as String?,
      layout: (json['layout'] as String?) ?? 'vertical',
      limit: (json['limit'] as num?)?.toInt() ?? 10,
    );
  }
}

class HomeConfigLoader {
  /// default sections لو ما في HOME_JSON_B64
  static List<HomeSectionConfig> buildDefaultSections(AppConfig app) {
    final hasItems = app.hasItems;
    final hasBooking = app.hasBooking;
    final hasReviews = app.hasReviews;

    final sections = <HomeSectionConfig>[];

    // 1) Header (logo + welcome)
    sections.add(
      const HomeSectionConfig(
        id: 'header',
        type: HomeSectionType.header,
        layout: 'full',
        limit: 1,
      ),
    );

    // 2) Search
    sections.add(
      const HomeSectionConfig(
        id: 'search',
        type: HomeSectionType.search,
        layout: 'full',
        limit: 1,
      ),
    );

    // 3) Hero banner (slider)
    sections.add(
      const HomeSectionConfig(
        id: 'hero_banner',
        type: HomeSectionType.banner,
        layout: 'full',
        limit: 1,
      ),
    );

    // 4) Category chips row
    sections.add(
      const HomeSectionConfig(
        id: 'categories',
        type: HomeSectionType.categoryChips,
        layout: 'horizontal',
        limit: 10,
      ),
    );

    if (hasItems) {
      // 5) Flash sale (horizontal cards)
      sections.add(
        const HomeSectionConfig(
          id: 'flash_sale',
          type: HomeSectionType.itemList,
          feature: 'ITEMS',
          layout: 'horizontal',
          limit: 10,
        ),
      );

      // 6) New arrivals (vertical list)
      sections.add(
        const HomeSectionConfig(
          id: 'new_arrivals',
          type: HomeSectionType.itemList,
          feature: 'ITEMS',
          layout: 'vertical',
          limit: 10,
        ),
      );

      // 7) Best sellers (horizontal cards)
      sections.add(
        const HomeSectionConfig(
          id: 'best_sellers',
          type: HomeSectionType.itemList,
          feature: 'ITEMS',
          layout: 'horizontal',
          limit: 10,
        ),
      );

      // 8) Top rated (vertical list)
      sections.add(
        const HomeSectionConfig(
          id: 'top_rated',
          type: HomeSectionType.itemList,
          feature: 'ITEMS',
          layout: 'vertical',
          limit: 10,
        ),
      );
    }

    // 9) Why shop with us (bottom info cards)
    if (hasReviews) {
      sections.add(
        const HomeSectionConfig(
          id: 'why_shop',
          type: HomeSectionType.reviewList,
          feature: 'REVIEWS',
          layout: 'vertical',
          limit: 4,
        ),
      );
    }

    return sections;
  }

  static List<HomeSectionConfig> loadSections(AppConfig app) {
    String raw = '';

    if (Env.homeJsonB64.isNotEmpty) {
      try {
        raw = utf8.decode(base64Decode(Env.homeJsonB64));
      } catch (_) {
        raw = '';
      }
    }

    if (raw.isEmpty) {
      return buildDefaultSections(app);
    }

    try {
      final decoded = jsonDecode(raw);

      if (decoded is Map<String, dynamic> && decoded['sections'] is List) {
        final list = decoded['sections'] as List<dynamic>;
        return list
            .map((e) => HomeSectionConfig.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (decoded is List) {
        return decoded
            .map((e) => HomeSectionConfig.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      return buildDefaultSections(app);
    } catch (_) {
      return buildDefaultSections(app);
    }
  }
}
