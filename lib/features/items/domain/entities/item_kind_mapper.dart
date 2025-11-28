// lib/features/items/domain/entities/item_kind_mapper.dart

import 'package:build4front/core/config/env.dart';
import 'item_summary.dart';

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
