import 'package:build4front/features/admin/profile/domain/repository/admin_profile_repository.dart';

import '../entities/admin_user_profile.dart';


class GetMyAdminProfile {
  final AdminProfileRepository repo;
  const GetMyAdminProfile(this.repo);

  Future<AdminUserProfile> call() => repo.getMyProfile();
}
