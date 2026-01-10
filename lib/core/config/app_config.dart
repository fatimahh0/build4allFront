import 'dart:convert';
import 'env.dart';

/// Represents one navigation item in the bottom bar.
class NavItemConfig {
  final String id;
  final String label;
  final String icon;

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
  final String appType;
  final List<String> enabledFeatures;
  final List<NavItemConfig> navigation;

  /// ✅ NEW: 'bottom' or 'drawer'
  final String menuType;

  final int? currencyId;
  final int? ownerProjectId;

  const AppConfig({
    required this.appName,
    required this.appType,
    required this.enabledFeatures,
    required this.navigation,
    required this.menuType,
    this.currencyId,
    this.ownerProjectId,
  });

  static String _normalizeMenuType(String? v) {
    final s = (v ?? '').trim().toLowerCase();
    if (s.isEmpty) return 'drawer';
    if (s == 'hamburger') return 'drawer';
    if (s == 'menu') return 'drawer';
    if (s == 'drawer') return 'drawer';
    if (s == 'bottom') return 'bottom';
    return 'drawer';
  }

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

    // -------- ✅ MENU TYPE --------
    // Priority:
    // 1) MENU_TYPE (direct)
    // 2) BRANDING_JSON_B64 { "menuType": "bottom" }
    // 3) default drawer
    String menuType = _normalizeMenuType(Env.menuType);

    if (menuType == 'drawer' && Env.brandingJsonB64.trim().isNotEmpty) {
      try {
        final brandingJson = utf8.decode(base64Decode(Env.brandingJsonB64));
        final map = jsonDecode(brandingJson);
        if (map is Map<String, dynamic>) {
          menuType = _normalizeMenuType(map['menuType']?.toString());
        }
      } catch (_) {
        // keep drawer
      }
    }

    // -------- CURRENCY ID --------
    int? currencyId;
    try {
      final raw = Env.currencyId.trim();
      if (raw.isNotEmpty) {
        currencyId = int.tryParse(raw);
      }
    } catch (_) {
      currencyId = null;
    }

    // -------- OWNER PROJECT ID --------
    int? ownerProjectId;
    try {
      final raw = Env.ownerProjectLinkId.trim();
      if (raw.isNotEmpty) {
        ownerProjectId = int.tryParse(raw);
      }
    } catch (_) {
      ownerProjectId = null;
    }

    return AppConfig(
      appName: Env.appName,
      appType: Env.appType,
      enabledFeatures: features,
      navigation: navList,
      menuType: menuType,
      currencyId: currencyId,
      ownerProjectId: ownerProjectId,
    );
  }
}

extension AppConfigX on AppConfig {
  bool get hasItems => enabledFeatures.contains('ITEMS');
  bool get hasBooking => enabledFeatures.contains('BOOKING');
  bool get hasOrders => enabledFeatures.contains('ORDERS');
  bool get hasChat => enabledFeatures.contains('CHAT');
  bool get hasReviews => enabledFeatures.contains('REVIEWS');

  bool get isBottomNav => menuType == 'bottom';
  bool get isDrawerNav => menuType == 'drawer';
}
