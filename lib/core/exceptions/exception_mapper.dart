// lib/core/exceptions/exception_mapper.dart
import 'app_exception.dart';

class ExceptionMapper {
  static String toMessage(Object error) {
    if (error is AppException) {
      switch (error.code) {
        case 'INVALID_CREDENTIALS':
          return 'Invalid email or password';
        case 'USER_NOT_FOUND':
          return 'User not found';
        case 'INACTIVE':
          return 'Your account is inactive. Reactivate to continue.';
        case 'NETWORK_ERROR':
          return 'No internet connection';
        case 'SERVER_ERROR':
          return 'Server error. Please try later.';
      }
      return error.message; // fallback clean message from service
    }
    return 'Something went wrong. Please try again.';
  }
}
