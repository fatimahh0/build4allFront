abstract class UserProfileEvent {
  const UserProfileEvent();
}

class LoadUserProfile extends UserProfileEvent {
  final String token;
  final int userId;
  final int ownerProjectLinkId;

  const LoadUserProfile(this.token, this.userId, this.ownerProjectLinkId);
}

class ToggleVisibilityPressed extends UserProfileEvent {
  final String token;
  final int userId;
  final bool newValue;
  final int ownerProjectLinkId;

  const ToggleVisibilityPressed(
    this.token,
    this.userId,
    this.newValue,
    this.ownerProjectLinkId,
  );
}

class UpdateStatusPressed extends UserProfileEvent {
  final String token;
  final int userId;
  final String status;
  final int ownerProjectLinkId;
  final String? password;

  const UpdateStatusPressed(
    this.token,
    this.userId,
    this.status,
    this.ownerProjectLinkId, {
    this.password,
  });
}
