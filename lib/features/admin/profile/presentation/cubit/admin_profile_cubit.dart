import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:build4front/core/exceptions/exception_mapper.dart';

import '../../domain/entities/admin_user_profile.dart';
import '../../domain/usecases/get_my_admin_profile.dart';

sealed class AdminProfileState {
  const AdminProfileState();
}

class AdminProfileInitial extends AdminProfileState {
  const AdminProfileInitial();
}

class AdminProfileLoading extends AdminProfileState {
  const AdminProfileLoading();
}

class AdminProfileLoaded extends AdminProfileState {
  final AdminUserProfile profile;
  const AdminProfileLoaded(this.profile);
}

class AdminProfileError extends AdminProfileState {
  final String message;
  const AdminProfileError(this.message);
}

class AdminProfileCubit extends Cubit<AdminProfileState> {
  final GetMyAdminProfile getMe;

  AdminProfileCubit({required this.getMe}) : super(const AdminProfileInitial());

  Future<void> load() async {
    emit(const AdminProfileLoading());
    try {
      final profile = await getMe();
      emit(AdminProfileLoaded(profile));
    } catch (e) {
      emit(AdminProfileError(ExceptionMapper.toMessage(e)));
    }
  }
}
