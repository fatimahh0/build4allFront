import 'package:build4front/core/config/env.dart';
import 'item_summary.dart';

/// Decide the current item kind based on APP_TYPE from Env.
///
/// APP_TYPE is provided via --dart-define at build/run time.
///
/// Examples:
/// - ACTIVITIES -> ItemKind.activity
/// - ECOMMERCE / PRODUCTS -> ItemKind.product
/// - SERVICES -> ItemKind.service
ItemKind currentItemKindFromEnv() {
  final t = Env.appType.toUpperCase().trim();
  switch (t) {
    case 'ACTIVITIES':
      return ItemKind.activity;
    case 'ECOMMERCE':
    case 'PRODUCTS':
      return ItemKind.product;
    case 'SERVICES':
      return ItemKind.service;
    default:
      return ItemKind.unknown;
  }
}
