import 'dart:io';
import '../entities/excel_import_result.dart';
import '../entities/excel_validation_result.dart';

abstract class ExcelImportRepository {
  Future<ExcelValidationResult> validate(File file);
  Future<ExcelImportResult> importFile({
    required File file,
    required bool replace,
    required String replaceScope,
  });
}
