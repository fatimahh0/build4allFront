import 'package:build4front/features/ai_feature/data/services/ai_chat_remote_datasource.dart';

import '../../domain/repositories/ai_chat_repository.dart';

import '../models/ai_item_chat_request_model.dart';

class AiChatRepositoryImpl implements AiChatRepository {
  final AiChatRemoteDataSource remote;
  AiChatRepositoryImpl(this.remote);

  @override
  Future<String> chatItem({
    required int ownerProjectLinkId,
    required int itemId,
    required String message,
  }) async {
    final res = await remote.chatItem(
      ownerProjectLinkId: ownerProjectLinkId,
      body: AiItemChatRequestModel(itemId: itemId, message: message),
    );
    return res.answer;
  }
}
