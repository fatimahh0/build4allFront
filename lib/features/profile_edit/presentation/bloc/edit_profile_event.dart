abstract class EditProfileEvent {}

class LoadEditProfile extends EditProfileEvent {
  final String token;
  final int userId;
  final int ownerProjectLinkId;

  LoadEditProfile({
    required this.token,
    required this.userId,
    required this.ownerProjectLinkId,
  });
}

class SaveEditProfile extends EditProfileEvent {
  final String token;
  final int userId;
  final int ownerProjectLinkId;

  final String firstName;
  final String lastName;
  final String? username;

  // ✅ NEW: email (if changed -> backend sends OTP, doesn’t update immediately)
  final String? email;

  final bool isPublicProfile;

  final String? imageFilePath;
  final bool imageRemoved;

  SaveEditProfile({
    required this.token,
    required this.userId,
    required this.ownerProjectLinkId,
    required this.firstName,
    required this.lastName,
    required this.isPublicProfile,
    this.username,
    this.email, // ✅ NEW
    this.imageFilePath,
    this.imageRemoved = false,
  });
}

class DeleteAccount extends EditProfileEvent {
  final String token;
  final int userId;
  final String password;

  DeleteAccount({
    required this.token,
    required this.userId,
    required this.password,
  });
}