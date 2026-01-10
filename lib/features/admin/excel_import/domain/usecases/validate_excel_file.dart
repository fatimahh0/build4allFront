import 'dart:io';
import '../entities/excel_validation_result.dart';
import '../repositories/excel_import_repository.dart';

class ValidateExcelFile {
  final ExcelImportRepository repo;
  ValidateExcelFile(this.repo);

  Future<ExcelValidationResult> call(File file) => repo.validate(file);
}
