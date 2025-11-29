// lib/core/config/home_config.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'env.dart';
import 'app_config.dart';


enum HomeSectionType {
  header, // logo + welcome
  search, // search bar
  categoryChips, // horizontal chips row
  banner, // hero / promo card
  itemList, // items / activities list
  bookingList, // upcominga bookings
  reviewList, // latest reviews
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

    // 3) Category chips
    sections.add(
      const HomeSectionConfig(
        id: 'categories',
        type: HomeSectionType.categoryChips,
        layout: 'horizontal',
        limit: 10,
      ),
    );

    // 4) Hero banner
    sections.add(
      const HomeSectionConfig(
        id: 'hero_banner',
        type: HomeSectionType.banner,
        title: 'Find your next hobby',
        layout: 'full',
        limit: 1,
      ),
    );

    // 5) Recommended items
    if (hasItems) {
      sections.add(
        const HomeSectionConfig(
          id: 'recommended',
          type: HomeSectionType.itemList,
          title: 'Recommended for you',
          feature: 'ITEMS',
          layout: 'horizontal',
          limit: 10,
        ),
      );
    }

    // 6) Popular items
    if (hasItems) {
      sections.add(
        const HomeSectionConfig(
          id: 'popular',
          type: HomeSectionType.itemList,
          title: 'Popular now',
          feature: 'ITEMS',
          layout: 'horizontal',
          limit: 10,
        ),
      );
    }

    // 7) Upcoming bookings
    if (hasBooking) {
      sections.add(
        const HomeSectionConfig(
          id: 'upcoming_bookings',
          type: HomeSectionType.bookingList,
          title: 'Upcoming bookings',
          feature: 'BOOKING',
          layout: 'vertical',
          limit: 5,
        ),
      );
    }

    // 8) Latest reviews
    if (hasReviews) {
      sections.add(
        const HomeSectionConfig(
          id: 'latest_reviews',
          type: HomeSectionType.reviewList,
          title: 'Latest reviews',
          feature: 'REVIEWS',
          layout: 'horizontal',
          limit: 8,
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
