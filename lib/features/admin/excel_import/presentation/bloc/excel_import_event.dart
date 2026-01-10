import 'package:equatable/equatable.dart';

abstract class ExcelImportEvent extends Equatable {
  const ExcelImportEvent();
  @override
  List<Object?> get props => [];
}

class ExcelPickFilePressed extends ExcelImportEvent {
  const ExcelPickFilePressed();
}

class ExcelValidatePressed extends ExcelImportEvent {
  const ExcelValidatePressed();
}

class ExcelImportPressed extends ExcelImportEvent {
  const ExcelImportPressed();
}

class ExcelReplaceToggled extends ExcelImportEvent {
  final bool value;
  const ExcelReplaceToggled(this.value);

  @override
  List<Object?> get props => [value];
}

class ExcelReplaceScopeChanged extends ExcelImportEvent {
  final String scope; // TENANT | FULL
  const ExcelReplaceScopeChanged(this.scope);

  @override
  List<Object?> get props => [scope];
}

/// ✅ NEW: download template into app storage
class ExcelDownloadTemplatePressed extends ExcelImportEvent {
  const ExcelDownloadTemplatePressed();
}
