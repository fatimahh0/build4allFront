class UserEntity {
  final int id;
  final String? username;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phoneNumber;
  final String? profilePictureUrl;
  final int ownerProjectLinkId;

  const UserEntity({
    required this.id,
    required this.ownerProjectLinkId,
    this.username,
    this.firstName,
    this.lastName,
    this.email,
    this.phoneNumber,
    this.profilePictureUrl,
  });
}
