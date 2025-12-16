// lib/features/auth/presentation/bloc/auth_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/config/env.dart';
import '../../../domain/usecases/login_with_email.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// AuthBloc manages the basic user-authentication state:
/// - handles direct email login (legacy path)
/// - can be hydrated by external login flows (DualLoginOrchestrator)
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginWithEmail loginWithEmail;

  AuthBloc({required this.loginWithEmail}) : super(AuthState.initial()) {
    on<AuthLoginSubmitted>(_onLoginSubmitted);
    on<AuthLoginHydrated>(_onLoginHydrated);
    on<AuthLoggedOut>(_onLoggedOut);
  }

  /// Direct login using email/password + ownerProjectLinkId.
  /// (You are currently using DualLoginOrchestrator in the screen,
  /// but we keep this flow working too.)
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

      // Read token + wasInactive from AuthApiService via usecase
      final token = await loginWithEmail.authApi.getSavedToken();
      final wasInactive = await loginWithEmail.authApi.getWasInactive();

      emit(
        state.copyWith(
          isLoading: false,
          error: null,
          isLoggedIn: true,
          user: userEntity,
          token: token,
          wasInactive: wasInactive,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: e,
          isLoggedIn: false,
          wasInactive: false,
        ),
      );
    }
  }

  /// Hydrate auth state after an external login flow (DualLoginOrchestrator).
void _onLoginHydrated(AuthLoginHydrated event, Emitter<AuthState> emit) {
    emit(
      state.copyWith(
        isLoading: false,
        error: null,
        isLoggedIn: true,
        user: event.user,
        token: event.token,
        wasInactive: event.wasInactive,
      ),
    );
  }


  /// Reset auth state to initial.
  void _onLoggedOut(AuthLoggedOut event, Emitter<AuthState> emit) {
    emit(AuthState.initial());
  }
}
