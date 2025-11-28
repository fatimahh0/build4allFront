// lib/core/network/interceptors/auth_body_injector.dart

import 'package:dio/dio.dart';
import 'package:build4front/core/config/env.dart';
import 'package:build4front/core/network/globals.dart' as g;

/// Interceptor that injects ownerProjectLinkId + auth token
/// into every request.
class OwnerInjector extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // 1) Inject ownerProjectLinkId as header
    final ownerId = Env.ownerProjectLinkId.trim();
    if (ownerId.isNotEmpty) {
      options.headers['X-Owner-Project-Link-Id'] = ownerId;
    }

    // 2) Inject Authorization header from global token (if any)
    final token = g.readAuthToken().trim();
    final currentAuth = (options.headers['Authorization'] ?? '').toString();

    if (token.isNotEmpty && currentAuth.isEmpty) {
      final normalized = token.startsWith('Bearer ') ? token : 'Bearer $token';
      options.headers['Authorization'] = normalized;
    }

    // optional debug
    // // ignore: avoid_print
    // print('🟦 OwnerInjector headers → ${options.headers}');

    handler.next(options);
  }
}
