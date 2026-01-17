import '../repositories/ai_chat_repository.dart';

class ChatItemUseCase {
  final AiChatRepository repo;
  ChatItemUseCase(this.repo);

  Future<String> call({
    required int ownerProjectLinkId,
    required int itemId,
    required String message,
  }) {
    return repo.chatItem(
      ownerProjectLinkId: ownerProjectLinkId,
      itemId: itemId,
      message: message,
    );
  }
}
