import '../../domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  UserProfileModel({
    required super.id,
    required super.ownerProjectLinkId,
    required super.firstName,
    required super.lastName,
    super.username,
    super.email,
    super.phoneNumber,
    super.profileImageUrl,
    required super.publicProfile,
    super.statusName,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    final status = json['status'];
    final statusName = status is Map
        ? status['name']?.toString()
        : status?.toString();

    final publicProfile =
        (json['publicProfile'] ??
            json['isPublicProfile'] ??
            json['public_profile'] ??
            false) ==
        true;

    return UserProfileModel(
      id: (json['id'] ?? json['userId'] ?? 0) as int,
      ownerProjectLinkId: (json['ownerProjectLinkId'] ?? 0) as int,
      firstName: (json['firstName'] ?? '').toString(),
      lastName: (json['lastName'] ?? '').toString(),
      username: json['username']?.toString(),
      email: json['email']?.toString(),
      phoneNumber: json['phoneNumber']?.toString(),
      profileImageUrl:
          (json['profileImageUrl'] ??
                  json['profilePictureUrl'] ??
                  json['profile_image_url'])
              ?.toString(),
      publicProfile: publicProfile,
      statusName: statusName,
    );
  }
}
