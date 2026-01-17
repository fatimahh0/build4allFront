class AiChatResponseModel {
  final String answer;

  const AiChatResponseModel({required this.answer});

  factory AiChatResponseModel.fromJson(Map<String, dynamic> json) {
    // Flexible parsing (because backend response might differ)
    final v =
        json['answer'] ?? json['message'] ?? json['content'] ?? json['text'];
    return AiChatResponseModel(answer: (v ?? '').toString());
  }
}
