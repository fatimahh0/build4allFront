import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_user_profile.dart';
import '../../domain/usecases/toggle_user_visibility.dart';
import '../../domain/usecases/update_user_status.dart';

import 'user_profile_event.dart';
import 'user_profile_state.dart';

class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  final GetUserProfile getUser;
  final ToggleUserVisibility toggleVisibility;
  final UpdateUserStatus updateStatus;

  UserProfileBloc({
    required this.getUser,
    required this.toggleVisibility,
    required this.updateStatus,
  }) : super(const UserProfileLoading()) {
    on<LoadUserProfile>(_onLoad);
    on<ToggleVisibilityPressed>(_onToggle);
    on<UpdateStatusPressed>(_onUpdateStatus);
  }

  // ✅ NEW: direct method you can await from dialogs (no Provider drama, no event guessing)
  Future<void> updateStatusDirect({
    required String token,
    required int userId,
    required String status,
    required int ownerProjectLinkId,
    String? password,
  }) async {
    await updateStatus(
      token: token,
      userId: userId,
      status: status,
      ownerProjectLinkId: ownerProjectLinkId,
      password: password,
    );
  }

  Future<void> _onLoad(
    LoadUserProfile e,
    Emitter<UserProfileState> emit,
  ) async {
    emit(const UserProfileLoading());
    try {
      final user = await getUser(
        token: e.token,
        userId: e.userId,
        ownerProjectLinkId: e.ownerProjectLinkId,
      );
      emit(UserProfileLoaded(user));
    } catch (err) {
      emit(UserProfileError(err.toString()));
    }
  }

  Future<void> _onToggle(
    ToggleVisibilityPressed e,
    Emitter<UserProfileState> emit,
  ) async {
    final prev = state;
    if (prev is! UserProfileLoaded) return;

    try {
      await toggleVisibility(
        token: e.token,
        userId: e.userId,
        isPublic: e.newValue,
        ownerProjectLinkId: e.ownerProjectLinkId,
      );

      add(LoadUserProfile(e.token, e.userId, e.ownerProjectLinkId));
    } catch (err) {
      emit(UserProfileError(err.toString()));
    }
  }

  Future<void> _onUpdateStatus(
    UpdateStatusPressed e,
    Emitter<UserProfileState> emit,
  ) async {
    try {
      await updateStatus(
        token: e.token,
        userId: e.userId,
        status: e.status,
        ownerProjectLinkId: e.ownerProjectLinkId,
        password: e.password,
      );

      // ✅ CRITICAL FIX:
      // If INACTIVE -> backend may hide profile,
      // so reloading causes "could not find the correct profile".
      if (e.status.toUpperCase() == 'INACTIVE') {
        return;
      }

      add(LoadUserProfile(e.token, e.userId, e.ownerProjectLinkId));
    } catch (err) {
      emit(UserProfileError(err.toString()));
    }
  }
}
