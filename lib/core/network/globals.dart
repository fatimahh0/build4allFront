// lib/core/network/globals.dart
library globals;

import 'dart:convert'; // for JWT decoding
import 'package:dio/dio.dart';
import 'package:build4front/core/config/env.dart';
import 'package:build4front/core/network/interceptors/auth_body_injector.dart';
import 'package:build4front/core/network/connecting(wifiORserver)/connection_cubit.dart';
import 'package:flutter/foundation.dart';

Dio? appDio;

/// Core server base, e.g. "http://192.168.1.5:8080"
late String appServerRoot;

// -------- Tokens (legacy compatibility) --------
String? authToken;
String? token;
String? userToken;
String? Token;

// -------- Owner / tenant wiring --------
String? ownerProjectLinkId;
String? ownerAttachMode;
String? projectId;
String? appRole;
String? wsPath;

// -------- Branding --------
String appName = 'Build4All — Client';
String appLogoUrl = '';

final ValueNotifier<bool> aiEnabledNotifier = ValueNotifier<bool>(false);

bool get aiEnabled => aiEnabledNotifier.value;
set aiEnabled(bool v) => aiEnabledNotifier.value = v;

// -------- Connection Cubit (for server / network status) --------
ConnectionCubit? connectionCubit;

/// Register the ConnectionCubit globally so the network layer can update status.
void registerConnectionCubit(ConnectionCubit cubit) {
  connectionCubit = cubit;
}

/// Read the current auth token from any of the legacy fields.
String readAuthToken() {
  return (authToken ?? token ?? userToken ?? Token ?? '').toString();
}

/// Set the current auth token and update Dio default headers.
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

/// Base URL without "/api" suffix, used to resolve relative URLs.
String serverRootNoApi() {
  final base = appServerRoot;
  return base.replaceFirst(RegExp(r'/api/?$'), '');
}

/// Resolve a relative path against the server root.
String resolveUrl(String maybeRelative) {
  final s = maybeRelative.trim();
  if (s.isEmpty) return s;

  if (s.startsWith('http://') || s.startsWith('https://')) return s;

  final base = serverRootNoApi().replaceAll(RegExp(r'/+$'), '');
  final rel = s.startsWith('/') ? s : '/$s';
  return '$base$rel';
}

String get appLogoUrlResolved => resolveUrl(appLogoUrl);

/// Get the shared Dio instance (or create it lazily).
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
/// Call this once at app startup.
void makeDefaultDio(String baseUrl) {
  appServerRoot = baseUrl;

  // Copy Env → globals so interceptors can read them.
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
  d.interceptors.add(OwnerInjector());
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

/// =======================
///   JWT helpers (USER + OWNER)
/// =======================

/// Extract raw JWT without the "Bearer " prefix.
String? _rawJwt() {
  final full = readAuthToken().trim();
  if (full.isEmpty) return null;
  if (full.toLowerCase().startsWith('bearer ')) {
    return full.substring(7).trim();
  }
  return full;
}

/// Decode the JWT payload as a Map<String, dynamic>.
Map<String, dynamic>? decodeJwtPayload() {
  try {
    final raw = _rawJwt();
    if (raw == null || raw.isEmpty) return null;

    final parts = raw.split('.');
    if (parts.length != 3) return null;

    var payload = parts[1];
    payload = base64Url.normalize(payload);
    final decoded = utf8.decode(base64Url.decode(payload));
    final map = jsonDecode(decoded);

    if (map is Map<String, dynamic>) {
      return map;
    }
    return null;
  } catch (_) {
    return null;
  }
}

/// Return the OWNER name (username) from the JWT if the role is OWNER.
///
/// Based on JwtUtil.java:
/// - USER token:  id, username, firstName, lastName, profileImageUrl, role = USER
/// - OWNER token: id, username, role = OWNER
///
/// If the token is not an OWNER token, this returns null.
String? getOwnerNameFromJwt() {
  final payload = decodeJwtPayload();
  if (payload == null) return null;

  final roleRaw = payload['role'];
  final role = roleRaw is String ? roleRaw.toUpperCase().trim() : null;

  if (role == 'OWNER') {
    final uname = payload['username'];
    if (uname is String && uname.trim().isNotEmpty) {
      return uname.trim();
    }
  }

  return null;
}
