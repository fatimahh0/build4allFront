import 'package:build4front/core/config/env.dart';
import 'package:build4front/features/auth/domain/usecases/send_verification_code.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'register_event.dart';
import 'register_state.dart';

// Exceptions
import 'package:build4front/core/exceptions/auth_exception.dart';
import 'package:build4front/core/exceptions/network_exception.dart';
import 'package:build4front/core/exceptions/app_exception.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final SendVerificationCode sendVerificationCode;

  RegisterBloc({required this.sendVerificationCode})
      : super(RegisterState.initial()) {
    on<RegisterSendCodeSubmitted>(_onSendCodeSubmitted);
  }

  Future<void> _onSendCodeSubmitted(
    RegisterSendCodeSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    emit(
      state.copyWith(
        isLoading: true,
        clearErrorCode: true,
        codeSent: false,
      ),
    );

    final ownerId = int.tryParse(Env.ownerProjectLinkId) ?? 0;

    final email =
        event.method == RegisterMethod.email ? event.email?.trim() : null;

    final phone = event.method == RegisterMethod.phone
        ? event.phoneNumber?.trim()
        : null;

    try {
      final dynamic result = await sendVerificationCode(
        email: email,
        phoneNumber: phone,
        password: event.password,
        ownerProjectLinkId: ownerId,
      );

      // ✅ If the usecase returns Either => handle Left/Right properly
      if (result is Either) {
        return result.fold(
          (failure) {
            final code = _mapFailureToCode(failure);
            emit(
              state.copyWith(
                isLoading: false,
                errorCode: code,
                codeSent: false,
              ),
            );
          },
          (_) {
            emit(
              state.copyWith(
                isLoading: false,
                clearErrorCode: true,
                codeSent: true,
                contact: email ?? phone,
                method: event.method,
              ),
            );
          },
        );
      }

      // ✅ If the usecase returns "void"/success directly
      emit(
        state.copyWith(
          isLoading: false,
          clearErrorCode: true,
          codeSent: true,
          contact: email ?? phone,
          method: event.method,
        ),
      );
    } catch (e) {
      final code = _mapErrorToCode(e);
      emit(
        state.copyWith(
          isLoading: false,
          errorCode: code,
          codeSent: false,
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Failure mapping (Either Left)
  // ---------------------------------------------------------------------------

  String _mapFailureToCode(dynamic failure) {
    // If it's already one of your exceptions (some apps use exception as failure)
    if (failure is AuthException) return failure.code ?? 'AUTH_ERROR';
    if (failure is NetworkException) return _mapNetworkFailure(failure);
    if (failure is AppException) {
      final code = _tryReadDynamicCode(failure);
      if (code != null) return code;
      final msg = _tryReadDynamicMessage(failure) ?? failure.toString();
      return _mapMessageToAuthCode(msg) ?? 'GENERIC';
    }

    // Try to read common fields from Failure objects: failure.code / failure.message
    final rawCode = _tryReadDynamicCode(failure);
    final rawMsg = _tryReadDynamicMessage(failure) ?? failure.toString();

    if (rawCode != null) {
      // If backend-like code exists, normalize it
      final normalized = _normalizeCode(rawCode);
      // If it's a generic code but message is specific, prefer message mapping
      final byMsg = _mapMessageToAuthCode(rawMsg);
      if (byMsg != null) return byMsg;
      return normalized;
    }

    return _mapMessageToAuthCode(rawMsg) ?? 'GENERIC';
  }

  String _mapNetworkFailure(NetworkException e) {
    final msg = e.message.toLowerCase();
    if (msg.contains('no internet')) return 'NO_INTERNET';
    if (msg.contains('timed out') || msg.contains('timeout')) return 'TIMEOUT';
    return 'NETWORK_ERROR';
  }

  // ---------------------------------------------------------------------------
  // Exception mapping (catch)
  // ---------------------------------------------------------------------------

  String _mapErrorToCode(Object e) {
    // ✅ AuthException already has a stable code
    if (e is AuthException) return e.code ?? 'AUTH_ERROR';

    // ✅ Your custom exceptions
    if (e is NetworkException) return _mapNetworkFailure(e);
    if (e is AppException) {
      final code = _tryReadDynamicCode(e);
      if (code != null) return _normalizeCode(code);

      final msg = _tryReadDynamicMessage(e) ?? e.toString();
      return _mapMessageToAuthCode(msg) ?? 'GENERIC';
    }

    // ✅ DioException (your backend response is here)
    if (e is DioException) {
      final parsed = _parseBackendErrorFromDio(e);

      // 1) prefer message mapping (most precise)
      final byMsg =
          parsed.message != null ? _mapMessageToAuthCode(parsed.message!) : null;
      if (byMsg != null) return byMsg;

      // 2) backend code if present (BAD_REQUEST etc)
      final byCode =
          parsed.code != null ? _normalizeCode(parsed.code!) : null;
      if (byCode != null && byCode != 'BAD_REQUEST') return byCode;

      // 3) HTTP status fallback
      final s = parsed.status;
      if (s == 401) return 'UNAUTHORIZED';
      if (s == 403) return 'FORBIDDEN';
      if (s == 404) return 'NOT_FOUND';
      if (s != null && s >= 500) return 'SERVER_ERROR';

      // 400-ish -> show validation instead of generic
      if (s == 400) return 'VALIDATION_ERROR';

      return 'NETWORK_ERROR';
    }

    // last fallback: map by any text
    final mapped = _mapMessageToAuthCode(e.toString());
    return mapped ?? 'GENERIC';
  }

  // ---------------------------------------------------------------------------
  // Backend parsing helpers
  // ---------------------------------------------------------------------------

  _BackendErr _parseBackendErrorFromDio(DioException e) {
    String? code;
    String? message;
    int? status;

    try {
      status = e.response?.statusCode;
      final data = e.response?.data;

      if (data is Map) {
        // ✅ YOUR BACKEND USES "error"
        message = (data['error'] ??
                data['message'] ??
                data['details'] ??
                data['detail'] ??
                data['msg'])
            ?.toString()
            .trim();

        code = data['code']?.toString().trim();

        // sometimes backend repeats status
        final s = data['status'];
        if (s is int) status = s;
        if (s is String) status = int.tryParse(s);
      } else if (data is String && data.trim().isNotEmpty) {
        message = data.trim();
      }

      message ??= e.message;
    } catch (_) {
      message = e.message ?? e.toString();
    }

    return _BackendErr(code: code, message: message, status: status);
  }

  // ---------------------------------------------------------------------------
  // Message -> Stable code mapping
  // ---------------------------------------------------------------------------

  String? _mapMessageToAuthCode(String msg) {
    final m = msg.toLowerCase();

    // ✅ matches: "Email already in use in this app"
    if (m.contains('email') && m.contains('already') && m.contains('in use')) {
      return 'EMAIL_ALREADY_EXISTS';
    }

    if (m.contains('phone') && m.contains('already') && m.contains('in use')) {
      return 'PHONE_ALREADY_EXISTS';
    }

    if (m.contains('username') && (m.contains('taken') || m.contains('already'))) {
      return 'USERNAME_TAKEN';
    }

    if (m.contains('invalid') && (m.contains('code') || m.contains('otp'))) {
      return 'INVALID_CODE';
    }

    return null;
  }

  // ---------------------------------------------------------------------------
  // Dynamic readers (works with many Failure/Exception shapes)
  // ---------------------------------------------------------------------------

  String? _tryReadDynamicCode(dynamic obj) {
    try {
      final any = obj as dynamic;
      final c = any.code;
      if (c == null) return null;
      final s = c.toString().trim();
      return s.isEmpty ? null : s;
    } catch (_) {
      return null;
    }
  }

  String? _tryReadDynamicMessage(dynamic obj) {
    try {
      final any = obj as dynamic;
      final m = any.message;
      if (m == null) return null;
      final s = m.toString().trim();
      return s.isEmpty ? null : s;
    } catch (_) {
      return null;
    }
  }

  String _normalizeCode(String code) {
    // normalize: "bad-request" / "Bad Request" -> "BAD_REQUEST"
    return code
        .trim()
        .replaceAll(' ', '_')
        .replaceAll('-', '_')
        .toUpperCase();
  }
}

class _BackendErr {
  final String? code;
  final String? message;
  final int? status;

  _BackendErr({this.code, this.message, this.status});
}
