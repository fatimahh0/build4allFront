import 'package:build4front/features/admin/profile/data/servcies/admin_user_api_service.dart';
import 'package:build4front/features/admin/profile/domain/repository/admin_profile_repository.dart';

import '../../domain/entities/admin_user_profile.dart';

import '../models/admin_user_profile_model.dart';


class AdminProfileRepositoryImpl implements AdminProfileRepository {
  final AdminUserApiService api;
  AdminProfileRepositoryImpl({required this.api});

  @override
  Future<AdminUserProfile> getMyProfile() async {
    final json = await api.getMyProfileJson();
    return AdminUserProfileModel.fromJson(json);
  }
}
