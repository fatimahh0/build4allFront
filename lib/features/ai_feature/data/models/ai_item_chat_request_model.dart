class AiItemChatRequestModel {
  final int itemId;
  final String message;

  const AiItemChatRequestModel({required this.itemId, required this.message});

  Map<String, dynamic> toJson() => {
        "itemId": itemId,
        "message": message,
      };
}
