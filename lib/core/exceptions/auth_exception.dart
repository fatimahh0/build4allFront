// lib/core/exceptions/auth_exception.dart

import 'app_exception.dart';

class AuthException extends AppException {
  AuthException(String message, {String? code, Object? original})
    : super(message, code: code ?? 'AUTH_ERROR', original: original);
}
