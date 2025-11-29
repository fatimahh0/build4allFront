class UserEntity {
  final int id;
  final String? username;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phoneNumber;
  final String? profilePictureUrl;
  final int ownerProjectLinkId;

  /// NEW: visibility (public/private)
  final bool? isPublicProfile;

  /// NEW: status text: "ACTIVE", "INACTIVE", "DELETED", ...
  final String? status;

  const UserEntity({
    required this.id,
    required this.ownerProjectLinkId,
    this.username,
    this.firstName,
    this.lastName,
    this.email,
    this.phoneNumber,
    this.profilePictureUrl,

    // NEW optional fields
    this.isPublicProfile,
    this.status,
  });

  /// Optional helper: nice display name for UI
  String get displayName {
    final f = (firstName ?? '').trim();
    final l = (lastName ?? '').trim();
    final name = '$f $l'.trim();

    if (name.isNotEmpty) return name;
    if ((username ?? '').trim().isNotEmpty) return username!.trim();
    if ((email ?? '').trim().isNotEmpty) return email!.trim();
    if ((phoneNumber ?? '').trim().isNotEmpty) return phoneNumber!.trim();

    return 'User #$id';
  }
}
