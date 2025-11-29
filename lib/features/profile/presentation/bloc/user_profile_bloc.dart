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

  Future<void> _onLoad(
    LoadUserProfile e,
    Emitter<UserProfileState> emit,
  ) async {
    emit(const UserProfileLoading());
    try {
      final user = await getUser(e.token, e.userId);
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
      await toggleVisibility(e.token, e.newValue);
      add(LoadUserProfile(e.token, prev.user.id!));
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
        password: e.password,
      );
      add(LoadUserProfile(e.token, e.userId));
    } catch (err) {
      emit(UserProfileError(err.toString()));
    }
  }
}
