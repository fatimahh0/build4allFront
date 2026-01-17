import '../../domain/entities/ai_message.dart';

class AiChatState {
  final List<AiMessage> messages;
  final bool isSending;

  const AiChatState({
    required this.messages,
    required this.isSending,
  });

  factory AiChatState.initial() =>
      const AiChatState(messages: [], isSending: false);

  AiChatState copyWith({
    List<AiMessage>? messages,
    bool? isSending,
  }) {
    return AiChatState(
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
    );
  }
}
