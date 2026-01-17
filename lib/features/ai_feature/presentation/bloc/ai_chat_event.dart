abstract class AiChatEvent {}

class AiChatOpened extends AiChatEvent {
  final int itemId;
  final String title;
  final String? imageUrl;

  AiChatOpened({required this.itemId, required this.title, this.imageUrl});
}

class AiChatSendPressed extends AiChatEvent {
  final String text;
  AiChatSendPressed(this.text);
}

class AiChatClear extends AiChatEvent {}
