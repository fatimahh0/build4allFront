import 'dart:convert';
import 'env.dart';

/// Represents one navigation item in the bottom bar.
class NavItemConfig {
  final String id; // "home", "items", "orders", "profile", ...
  final String label; // Label in bottom bar
  final String icon; // Icon name ("home", "bag", "ticket", ...)

  const NavItemConfig({
    required this.id,
    required this.label,
    required this.icon,
  });

  factory NavItemConfig.fromJson(Map<String, dynamic> json) {
    return NavItemConfig(
      id: json['id'] as String,
      label: json['label'] as String,
      icon: json['icon'] as String,
    );
  }
}

/// High-level app config read from Env / dart-define
class AppConfig {
  final String appName;
  final String appType; // ACTIVITIES / SHOP / SERVICES / ...
  final List<String> enabledFeatures;
  final List<NavItemConfig> navigation;

  const AppConfig({
    required this.appName,
    required this.appType,
    required this.enabledFeatures,
    required this.navigation,
  });

  /// Builds AppConfig from Env (dart-define values).
  factory AppConfig.fromEnv() {
    // -------- NAV JSON --------
    List<NavItemConfig> navList = [];
    try {
      String navSource = Env.navJson.trim();

      if ((navSource.isEmpty || navSource == '[]') &&
          Env.navJsonB64.isNotEmpty) {
        navSource = utf8.decode(base64Decode(Env.navJsonB64));
      }

      if (navSource.isNotEmpty && navSource != '[]') {
        final decoded = jsonDecode(navSource);
        final list = (decoded as List<dynamic>? ?? []);
        navList = list
            .map((e) => NavItemConfig.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      navList = [];
    }

    // -------- FEATURES JSON --------
    List<String> features = [];
    try {
      String featuresSource = Env.enabledFeaturesJson.trim();

      if ((featuresSource.isEmpty || featuresSource == '[]') &&
          Env.enabledFeaturesJsonB64.isNotEmpty) {
        featuresSource = utf8.decode(base64Decode(Env.enabledFeaturesJsonB64));
      }

      if (featuresSource.isNotEmpty && featuresSource != '[]') {
        final decoded = jsonDecode(featuresSource);
        features = List<String>.from(decoded as List<dynamic>? ?? []);
      }
    } catch (_) {
      features = [];
    }

    return AppConfig(
      appName: Env.appName,
      appType: Env.appType,
      enabledFeatures: features,
      navigation: navList,
    );
  }
}

extension AppConfigX on AppConfig {
  bool get hasItems => enabledFeatures.contains('ITEMS');
  bool get hasBooking => enabledFeatures.contains('BOOKING');
  bool get hasOrders => enabledFeatures.contains('ORDERS');
  bool get hasChat => enabledFeatures.contains('CHAT');
  bool get hasReviews => enabledFeatures.contains('REVIEWS');
}
