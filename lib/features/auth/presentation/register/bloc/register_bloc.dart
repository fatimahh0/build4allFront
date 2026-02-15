import 'package:build4front/core/config/env.dart';
import 'package:build4front/features/auth/domain/usecases/send_verification_code.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'register_event.dart';
import 'register_state.dart';

// Exceptions (adjust paths if needed)
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

    try {
      final email =
          event.method == RegisterMethod.email ? event.email?.trim() : null;

      final phone = event.method == RegisterMethod.phone
          ? event.phoneNumber?.trim()
          : null;

      await sendVerificationCode(
        email: email,
        phoneNumber: phone,
        password: event.password,
        ownerProjectLinkId: ownerId,
      );

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

  /// ✅ Map any thrown error → stable error code for l10n
  String _mapErrorToCode(Object e) {
    // AuthException already has code
    if (e is AuthException) {
      return e.code ?? 'AUTH_ERROR';
    }

    // NetworkException (if you have codes, great; if not, map by type)
    if (e is NetworkException) {
      final msg = e.message.toLowerCase();
      if (msg.contains('no internet')) return 'NO_INTERNET';
      if (msg.contains('timed out') || msg.contains('timeout'))
        return 'TIMEOUT';
      return 'NETWORK_ERROR';
    }

    // AppException (if it has code in your project)
    if (e is AppException) {
      // if your AppException has .code, use it; otherwise generic
      final dynamic any = e;
      final String? code = any.code as String?;
      return code ?? 'GENERIC';
    }

    return 'GENERIC';
  }
}
