import 'package:build4front/l10n/app_localizations.dart';

enum TaxClassUi { none, standard, reduced, zero }

extension TaxClassUiX on TaxClassUi {
  String get apiName {
    switch (this) {
      case TaxClassUi.none:
        return 'NONE';
      case TaxClassUi.standard:
        return 'STANDARD';
      case TaxClassUi.reduced:
        return 'REDUCED';
      case TaxClassUi.zero:
        return 'ZERO';
    }
  }

  String label(AppLocalizations l) {
    switch (this) {
      case TaxClassUi.none:
        return l.taxClassNone ?? 'No tax';
      case TaxClassUi.standard:
        return l.taxClassStandard ?? 'Standard';
      case TaxClassUi.reduced:
        return l.taxClassReduced ?? 'Reduced';
      case TaxClassUi.zero:
        return l.taxClassZero ?? 'Zero';
    }
  }

  static TaxClassUi? fromApi(String? v) {
    switch ((v ?? '').toUpperCase().trim()) {
      case 'NONE':
        return TaxClassUi.none;
      case 'STANDARD':
        return TaxClassUi.standard;
      case 'REDUCED':
        return TaxClassUi.reduced;
      case 'ZERO':
        return TaxClassUi.zero;
      default:
        return null;
    }
  }
}
