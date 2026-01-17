enum AiMessageRole { user, assistant }

class AiMessage {
  final AiMessageRole role;
  final String text;
  final DateTime at;

  const AiMessage({
    required this.role,
    required this.text,
    required this.at,
  });

  bool get isUser => role == AiMessageRole.user;
}
