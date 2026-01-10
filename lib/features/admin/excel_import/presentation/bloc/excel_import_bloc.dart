import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';

import '../../domain/usecases/import_excel_file.dart';
import '../../domain/usecases/validate_excel_file.dart';
import 'excel_import_event.dart';
import 'excel_import_state.dart';

class ExcelImportBloc extends Bloc<ExcelImportEvent, ExcelImportState> {
  final ValidateExcelFile validateUc;
  final ImportExcelFile importUc;

  ExcelImportBloc({
    required this.validateUc,
    required this.importUc,
  }) : super(ExcelImportState.initial()) {
    on<ExcelPickFilePressed>(_pickFile);
    on<ExcelValidatePressed>(_validate);
    on<ExcelImportPressed>(_import);
    on<ExcelReplaceToggled>(_toggleReplace);
    on<ExcelReplaceScopeChanged>(_changeScope);

    // ✅ NEW
    on<ExcelDownloadTemplatePressed>(_downloadTemplate);
  }

  Future<void> _pickFile(
    ExcelPickFilePressed event,
    Emitter<ExcelImportState> emit,
  ) async {
    emit(state.copyWith(picking: true, clearError: true));

    try {
      final res = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['xlsx'],
        withData: false,
      );

      if (res == null || res.files.isEmpty || res.files.first.path == null) {
        emit(state.copyWith(picking: false));
        return;
      }

      final file = File(res.files.first.path!);
      emit(state.copyWith(
        picking: false,
        file: file,
        clearValidation: true,
        clearResult: true,
      ));
    } catch (e) {
      emit(state.copyWith(picking: false, errorMessage: e.toString()));
    }
  }

  Future<void> _validate(
    ExcelValidatePressed event,
    Emitter<ExcelImportState> emit,
  ) async {
    if (state.file == null) return;

    emit(state.copyWith(validating: true, clearError: true, clearResult: true));

    try {
      final vr = await validateUc(state.file!);
      emit(state.copyWith(validating: false, validation: vr));
    } catch (e) {
      emit(state.copyWith(validating: false, errorMessage: e.toString()));
    }
  }

  Future<void> _import(
    ExcelImportPressed event,
    Emitter<ExcelImportState> emit,
  ) async {
    if (!state.canImport) return;

    emit(state.copyWith(importing: true, clearError: true));

    try {
      final r = await importUc(
        file: state.file!,
        replace: state.replace,
        replaceScope: state.replaceScope,
      );
      emit(state.copyWith(importing: false, result: r));
    } catch (e) {
      emit(state.copyWith(importing: false, errorMessage: e.toString()));
    }
  }

  void _toggleReplace(
    ExcelReplaceToggled event,
    Emitter<ExcelImportState> emit,
  ) {
    emit(state.copyWith(replace: event.value));
  }

  void _changeScope(
    ExcelReplaceScopeChanged event,
    Emitter<ExcelImportState> emit,
  ) {
    emit(state.copyWith(replaceScope: event.scope));
  }

  /// ✅ Template download (SAFE): save inside app docs dir (always works)
  Future<void> _downloadTemplate(
    ExcelDownloadTemplatePressed event,
    Emitter<ExcelImportState> emit,
  ) async {
    emit(state.copyWith(
      downloadingTemplate: true,
      clearError: true,
      clearTemplatePath: true,
    ));

    try {
      // ✅ Load the template from assets
      final data = await rootBundle.load('assets/templates/Template.xlsx');
      final bytes = data.buffer.asUint8List();

      // ✅ Use ApplicationSupportDirectory (internal, safest on Android)
      final dir = await getApplicationSupportDirectory();
      final outFile = File('${dir.path}/Build4All_Template.xlsx');

      // ✅ Ensure dir exists
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      await outFile.writeAsBytes(bytes, flush: true);

      emit(state.copyWith(
        downloadingTemplate: false,
        templateFilePath: outFile.path,
      ));
    } catch (e) {
      emit(state.copyWith(
        downloadingTemplate: false,
        errorMessage: e.toString(),
      ));
    }
  }
}
