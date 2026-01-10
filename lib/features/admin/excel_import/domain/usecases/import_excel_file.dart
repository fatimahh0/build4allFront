import 'dart:io';
import '../entities/excel_import_result.dart';
import '../repositories/excel_import_repository.dart';

class ImportExcelFile {
  final ExcelImportRepository repo;
  ImportExcelFile(this.repo);

  Future<ExcelImportResult> call({
    required File file,
    required bool replace,
    required String replaceScope,
  }) {
    return repo.importFile(
      file: file,
      replace: replace,
      replaceScope: replaceScope,
    );
  }
}
