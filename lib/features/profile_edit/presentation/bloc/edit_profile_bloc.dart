import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_user_by_id.dart';
import '../../domain/usecases/update_user_profile.dart';
import '../../domain/usecases/delete_user.dart';
import 'edit_profile_event.dart';
import 'edit_profile_state.dart';

class EditProfileBloc extends Bloc<EditProfileEvent, EditProfileState> {
  final GetUserById getUserById;
  final UpdateUserProfile updateUserProfile;
  final DeleteUser deleteUser;

  EditProfileBloc({
    required this.getUserById,
    required this.updateUserProfile,
    required this.deleteUser,
  }) : super(EditProfileState.initial) {
    on<LoadEditProfile>(_onLoad);
    on<SaveEditProfile>(_onSave);
    on<DeleteAccount>(_onDelete);
  }

  Future<void> _onLoad(
    LoadEditProfile e,
    Emitter<EditProfileState> emit,
  ) async {
    emit(state.copyWith(loading: true, error: null, success: null));
    try {
      final user = await getUserById(
        token: e.token,
        userId: e.userId,
        ownerProjectLinkId: e.ownerProjectLinkId,
      );
      emit(state.copyWith(loading: false, user: user));
    } catch (err) {
      emit(state.copyWith(loading: false, error: err.toString()));
    }
  }

  Future<void> _onSave(
    SaveEditProfile e,
    Emitter<EditProfileState> emit,
  ) async {
    emit(state.copyWith(saving: true, error: null, success: null));
    try {
      final updated = await updateUserProfile(
        token: e.token,
        userId: e.userId,
        ownerProjectLinkId: e.ownerProjectLinkId,
        firstName: e.firstName,
        lastName: e.lastName,
        username: e.username,
        isPublicProfile: e.isPublicProfile,
        imageFilePath: e.imageFilePath,
        imageRemoved: e.imageRemoved,
      );

      emit(
        state.copyWith(
          saving: false,
          user: updated,
          success: "Profile updated",
        ),
      );
    } catch (err) {
      emit(state.copyWith(saving: false, error: err.toString()));
    }
  }

  Future<void> _onDelete(
    DeleteAccount e,
    Emitter<EditProfileState> emit,
  ) async {
    emit(state.copyWith(deleting: true, error: null, success: null));
    try {
      await deleteUser(token: e.token, userId: e.userId, password: e.password);
      emit(state.copyWith(deleting: false, success: "Account deleted"));
    } catch (err) {
      emit(state.copyWith(deleting: false, error: err.toString()));
    }
  }
}
