import 'package:build4front/l10n/app_localizations.dart';

enum HomeBannerTargetTypeUi { none, category, product, url }

extension HomeBannerTargetTypeUiX on HomeBannerTargetTypeUi {
  String get apiName {
    switch (this) {
      case HomeBannerTargetTypeUi.category:
        return 'CATEGORY';
      case HomeBannerTargetTypeUi.product:
        return 'PRODUCT';
      case HomeBannerTargetTypeUi.url:
        return 'URL';
      case HomeBannerTargetTypeUi.none:
      default:
        return 'NONE';
    }
  }

  static HomeBannerTargetTypeUi fromApi(String? v) {
    final x = (v ?? '').toUpperCase().trim();
    switch (x) {
      case 'CATEGORY':
        return HomeBannerTargetTypeUi.category;
      case 'PRODUCT':
        return HomeBannerTargetTypeUi.product;
      case 'URL':
        return HomeBannerTargetTypeUi.url;
      default:
        return HomeBannerTargetTypeUi.none;
    }
  }

  String label(AppLocalizations l) {
    switch (this) {
      case HomeBannerTargetTypeUi.category:
        return l.adminHomeBannerTargetCategory ?? 'Category';
      case HomeBannerTargetTypeUi.product:
        return l.adminHomeBannerTargetProduct ?? 'Product';
      case HomeBannerTargetTypeUi.url:
        return l.adminHomeBannerTargetUrl ?? 'External URL';
      case HomeBannerTargetTypeUi.none:
      default:
        return l.adminHomeBannerTargetNone ?? 'None';
    }
  }
}
