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

  static DateTime? _lastRefreshAt;

  /// ✅ Refresh from server (does NOT override with cached)
  Future<void> refresh({Duration minInterval = const Duration(seconds: 15)}) async {
    final now = DateTime.now();
    final last = _lastRefreshAt;
    if (last != null && now.difference(last) < minInterval) return;
    _lastRefreshAt = now;

    final linkIdStr = Env.ownerProjectLinkId.trim();
    final linkId = int.tryParse(linkIdStr);
    if (linkId == null) {
      debugPrint('AI refresh: invalid OWNER_PROJECT_LINK_ID=$linkIdStr');
      g.aiEnabled = false;
      return;
    }

    final fresh = await _api.fetchAiEnabled(linkId: linkId);
    if (fresh == null) {
      debugPrint('AI refresh: status endpoint failed (keep current=${g.aiEnabled})');
      return;
    }

    g.aiEnabled = fresh;
    await _store.saveAiEnabled(linkId: linkIdStr, enabled: fresh);
  }

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

    // 2) server refresh (force now)
    await refresh(minInterval: Duration.zero);
  }
}