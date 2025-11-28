// lib/features/auth/presentation/bloc/auth_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/config/env.dart';
import '../../../domain/usecases/login_with_email.dart';

import '../../../domain/entities/user_entity.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginWithEmail loginWithEmail;

  AuthBloc({required this.loginWithEmail}) : super(AuthState.initial()) {
    on<AuthLoginSubmitted>(_onLoginSubmitted);
  }

  Future<void> _onLoginSubmitted(
    AuthLoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    final ownerId = int.tryParse(Env.ownerProjectLinkId) ?? 0;

    final result = await loginWithEmail(
      email: event.email.trim(), // can be email OR phone
      password: event.password,
      ownerProjectLinkId: ownerId,
    );

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
            isLoggedIn: false,
          ),
        );
      },
      (user) {
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: null,
            isLoggedIn: true,
            user: user as UserEntity,
          ),
        );
      },
    );
  }
}
