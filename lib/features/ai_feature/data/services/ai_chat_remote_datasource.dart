import 'package:dio/dio.dart';
import 'package:build4front/core/network/globals.dart' as g;

import '../models/ai_item_chat_request_model.dart';
import '../models/ai_chat_response_model.dart';

class AiChatRemoteDataSource {
  Future<AiChatResponseModel> chatItem({
    required int ownerProjectLinkId,
    required AiItemChatRequestModel body,
  }) async {
    final Dio dio = g.dio();

    final res = await dio.post(
      '/api/ai/item-chat',
      queryParameters: {'ownerProjectLinkId': ownerProjectLinkId},
      data: body.toJson(),
    );

    final data = res.data;
    if (data is Map<String, dynamic>) {
      return AiChatResponseModel.fromJson(data);
    }
    // worst case:
    return AiChatResponseModel(answer: data?.toString() ?? '');
  }
}
