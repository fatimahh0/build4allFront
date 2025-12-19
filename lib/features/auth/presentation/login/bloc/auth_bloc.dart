import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/config/env.dart';
import '../../../domain/usecases/login_with_email.dart';
import '../../../domain/entities/user_entity.dart';

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
    on<AuthUserPatched>(_onUserPatched); // ✅ NEW
    on<AuthLoggedOut>(_onLoggedOut);
  }

  /// Direct login using email/password + ownerProjectLinkId.
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

  /// ✅ NEW: Patch logged-in user fields (used after Edit Profile)
  void _onUserPatched(AuthUserPatched event, Emitter<AuthState> emit) {
    final current = state.user;
    if (!state.isLoggedIn || current == null) return;

    final updated = current.copyWith(
      firstName: event.firstName,
      lastName: event.lastName,
      username: event.username,
      profilePictureUrl: event.profilePictureUrl,
      isPublicProfile: event.isPublicProfile,
      status: event.status,
    );

    // Important: your copyWith() clears error if you don’t pass it
    // so we keep it as-is to avoid wiping an existing error.
    emit(state.copyWith(user: updated, error: state.error));
  }

  /// Reset auth state to initial.
  void _onLoggedOut(AuthLoggedOut event, Emitter<AuthState> emit) {
    emit(AuthState.initial());
  }
}
