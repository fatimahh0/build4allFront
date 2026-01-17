import 'package:flutter/foundation.dart';
import 'package:build4front/core/config/env.dart';
import 'package:build4front/core/network/globals.dart' as g;
import 'package:build4front/features/ai_feature/data/services/ai_feature_store.dart';
import 'package:build4front/features/ai_feature/data/services/public_ai_status_api_service.dart';

class AiFeatureBootstrap {
  AiFeatureBootstrap({
    AiFeatureStore? store,
    PublicAiStatusApiService? api,
  })  : _store = store ?? AiFeatureStore(),
        _api = api ?? PublicAiStatusApiService();

  final AiFeatureStore _store;
  final PublicAiStatusApiService _api;

  Future<void> init() async {
    final linkIdStr = Env.ownerProjectLinkId.trim();
    final linkId = int.tryParse(linkIdStr);
    if (linkId == null) {
      debugPrint('AI bootstrap: invalid OWNER_PROJECT_LINK_ID=$linkIdStr');
      g.aiEnabled = false;
      return;
    }

    // 1) cached value
    final cached = await _store.readAiEnabled(linkId: linkIdStr);
    g.aiEnabled = cached ?? false;


    // 2) server refresh
    final fresh = await _api.fetchAiEnabled(linkId: linkId);
    if (fresh == null) {
      debugPrint('AI bootstrap: status endpoint failed, keep cached=$cached');
      return;
    }

    g.aiEnabled = fresh;
    await _store.saveAiEnabled(linkId: linkIdStr, enabled: fresh);
  }
}
