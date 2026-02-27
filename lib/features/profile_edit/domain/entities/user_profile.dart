class UserProfile {
  final int id;
  final int ownerProjectLinkId;

  final String firstName;
  final String lastName;
  final String? username;

  final String? email;
  final String? phoneNumber;

  final String? profileImageUrl;
  final bool publicProfile;
  final String? statusName;

  // ✅ NEW
  final bool emailVerificationRequired;
  final String? pendingEmail;

  UserProfile({
    required this.id,
    required this.ownerProjectLinkId,
    required this.firstName,
    required this.lastName,
    this.username,
    this.email,
    this.phoneNumber,
    this.profileImageUrl,
    required this.publicProfile,
    this.statusName,

    // ✅ NEW
    this.emailVerificationRequired = false,
    this.pendingEmail,
  });

  UserProfile copyWith({
    String? firstName,
    String? lastName,
    String? username,
    String? profileImageUrl,
    bool? publicProfile,

    // ✅ NEW
    bool? emailVerificationRequired,
    String? pendingEmail,
  }) {
    return UserProfile(
      id: id,
      ownerProjectLinkId: ownerProjectLinkId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      username: username ?? this.username,
      email: email,
      phoneNumber: phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      publicProfile: publicProfile ?? this.publicProfile,
      statusName: statusName,

      // ✅ NEW
      emailVerificationRequired:
          emailVerificationRequired ?? this.emailVerificationRequired,
      pendingEmail: pendingEmail ?? this.pendingEmail,
    );
  }
}