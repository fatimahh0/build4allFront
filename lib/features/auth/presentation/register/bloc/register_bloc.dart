// lib/features/auth/presentation/bloc/register_bloc.dart
import 'package:build4front/core/config/env.dart';
import 'package:build4front/features/auth/domain/usecases/send_verification_code.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'register_event.dart';
import 'register_state.dart';

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
    emit(state.copyWith(isLoading: true, errorMessage: null, codeSent: false));

    final ownerId = int.tryParse(Env.ownerProjectLinkId) ?? 0;

    try {
      final email = event.method == RegisterMethod.email
          ? event.email?.trim()
          : null;
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
          errorMessage: null,
          codeSent: true,
          contact: email ?? phone,
          method: event.method,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
          codeSent: false,
        ),
      );
    }
  }
}
