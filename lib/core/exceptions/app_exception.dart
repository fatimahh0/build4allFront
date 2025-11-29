// lib/core/exceptions/app_exception.dart

class AppException implements Exception {
  final String message;
  final String? code; // e.g. "INVALID_CREDENTIALS"
  final Object? original; // original low-level error (DioException, etc.)

  AppException(this.message, {this.code, this.original});

  @override
  String toString() => 'AppException($code): $message';
}
