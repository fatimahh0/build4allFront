// lib/core/network/globals.dart
library globals;

import 'package:dio/dio.dart';
import 'package:build4front/core/config/env.dart';
import 'package:build4front/core/network/interceptors/auth_body_injector.dart';

Dio? appDio;

/// Core server base, e.g. "http://192.168.1.5:8080"
late String appServerRoot;

// -------- Tokens (legacy compatibility) --------
String? authToken;
String? token;
String? userToken;
String? Token;

// -------- Owner / tenant wiring --------
String? ownerProjectLinkId; // e.g. "1"
String? ownerAttachMode; // "header" | "query" | "body" | "off"
String? projectId; // e.g. "1"
String? appRole; // "both" | "user" | "business"
String? wsPath; // "/api/ws"

// -------- Branding --------
String appName = 'Build4All — Client'; // fallback
String appLogoUrl = '';

String readAuthToken() {
  return (authToken ?? token ?? userToken ?? Token ?? '').toString();
}

/// ✅ نحط الـ token global + على Dio
void setAuthToken(String? raw) {
  final t = (raw ?? '').trim();

  if (t.isEmpty) {
    authToken = null;
    token = null;
    userToken = null;
    Token = null;

    if (appDio != null) {
      appDio!.options.headers.remove('Authorization');
    }
    return;
  }

  final normalized = t.startsWith('Bearer ') ? t : 'Bearer $t';

  authToken = normalized;
  token = normalized;
  userToken = normalized;
  Token = normalized;

  if (appDio != null) {
    appDio!.options.headers['Authorization'] = normalized;
  }
}

String serverRootNoApi() {
  final base = appServerRoot;
 
  return base.replaceFirst(RegExp(r'/api/?$'), '');
}

/// ✅ Resolve relative URLs against server root
/// "/uploads/x.jpg" -> "http://192.168.1.3:8080/uploads/x.jpg"
String resolveUrl(String maybeRelative) {
  final s = maybeRelative.trim();
  if (s.isEmpty) return s;

 
  if (s.startsWith('http://') || s.startsWith('https://')) return s;

  final base = serverRootNoApi().replaceAll(RegExp(r'/+$'), '');
  final rel = s.startsWith('/') ? s : '/$s';
  return '$base$rel';
}

String get appLogoUrlResolved => resolveUrl(appLogoUrl);

Dio dio() {
  return appDio ??= Dio(
    BaseOptions(
      baseUrl: appServerRoot,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(minutes: 1),
    ),
  );
}

/// Initialize shared Dio and global values.
/// Call once at startup.
void makeDefaultDio(String baseUrl) {
  appServerRoot = baseUrl;

  // 🔗 copy Env → globals so interceptors can read them
  ownerProjectLinkId = Env.ownerProjectLinkId;
  ownerAttachMode = Env.ownerAttachMode;
  projectId = Env.projectId;
  appRole = Env.appRole;
  wsPath = Env.wsPath;
  appName = Env.appName;
  appLogoUrl = Env.appLogoUrl;

  final d = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
      sendTimeout: const Duration(seconds: 30),
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  d.interceptors.clear();
  d.interceptors.add(OwnerInjector()); // will use globals.*
  d.interceptors.add(
    LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: false,
      responseHeader: false,
    ),
  );

  appDio = d;
}
