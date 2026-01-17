abstract class AiChatRepository {
  Future<String> chatItem({
    required int ownerProjectLinkId,
    required int itemId,
    required String message,
  });
}
