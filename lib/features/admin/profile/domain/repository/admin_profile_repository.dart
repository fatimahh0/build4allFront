import '../entities/admin_user_profile.dart';

abstract class AdminProfileRepository {
  Future<AdminUserProfile> getMyProfile();
}
