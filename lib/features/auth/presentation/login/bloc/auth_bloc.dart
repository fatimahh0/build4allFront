// lib/features/auth/presentation/bloc/auth_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/config/env.dart';
import '../../../domain/usecases/login_with_email.dart';
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
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final ownerId = int.tryParse(Env.ownerProjectLinkId) ?? 0;

      final userEntity = await loginWithEmail(
        email: event.email.trim(),
        password: event.password,
        ownerProjectLinkId: ownerId,
      );

      final token = await loginWithEmail.authApi.getSavedToken();

      emit(
        state.copyWith(
          isLoading: false,
          error: null,
          isLoggedIn: true,
          user: userEntity,
          token: token,
        ),
      );
    } catch (e) {
      // ✅ keep the original exception object
      emit(state.copyWith(isLoading: false, error: e, isLoggedIn: false));
    }
  }
}
