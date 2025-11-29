// lib/features/profile/data/models/profile_user_dto.dart

import 'package:build4front/core/config/env.dart';
import 'package:build4front/features/auth/domain/entities/user_entity.dart';



class ProfileUserDto {
  final int id;
  final int ownerProjectLinkId;

  final String firstName;
  final String lastName;
  final String? email;
  final String? phoneNumber;
  final String? profileImageUrl;
  final bool publicProfile;
  final String? statusName;

  ProfileUserDto({
    required this.id,
    required this.ownerProjectLinkId,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phoneNumber,
    this.profileImageUrl,
    required this.publicProfile,
    this.statusName,
  });

  factory ProfileUserDto.fromMap(Map<String, dynamic> m) {
    final st = m['status'];
    final name = st is Map ? st['name'] as String? : m['status'] as String?;

    // try from payload, fallback to dart-define OWNER_PROJECT_LINK_ID
    final ownerProjectLinkId =
        (m['ownerProjectLinkId'] as num?)?.toInt() ??
        int.tryParse(Env.ownerProjectLinkId) ??
        0;

    // support both keys: profilePictureUrl OR profileImageUrl
    final dynamic rawImage = m['profilePictureUrl'] ?? m['profileImageUrl'];

    return ProfileUserDto(
      id: (m['id'] as num).toInt(),
      ownerProjectLinkId: ownerProjectLinkId,
      firstName: '${m['firstName'] ?? ''}',
      lastName: '${m['lastName'] ?? ''}',
      email: m['email'] as String?,
      phoneNumber: m['phoneNumber'] as String?,
      profileImageUrl: rawImage as String?,
      publicProfile:
          (m['publicProfile'] ?? m['isPublicProfile'] ?? false) == true,
      statusName: name,
    );
  }

  UserEntity toEntity() => UserEntity(
    id: id,
    ownerProjectLinkId: ownerProjectLinkId,
    username: null,
    firstName: firstName.isEmpty ? null : firstName,
    lastName: lastName.isEmpty ? null : lastName,
    email: email,
    phoneNumber: phoneNumber,
    profilePictureUrl: profileImageUrl,
    isPublicProfile: publicProfile,
    status: statusName,
  );
}
