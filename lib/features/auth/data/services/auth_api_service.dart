import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:build4front/core/config/env.dart';
import 'package:build4front/core/network/globals.dart' as g;

// Exceptions
import 'package:build4front/core/exceptions/app_exception.dart';
import 'package:build4front/core/exceptions/network_exception.dart';
import 'package:build4front/core/exceptions/auth_exception.dart';
import 'package:build4front/features/auth/data/models/AdminLoginResponse.dart';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/user_model.dart';
import 'auth_token_store.dart';

class AuthApiService {
  final http.Client _client;
  final AuthTokenStore _tokenStore;

  AuthApiService({http.Client? client, required AuthTokenStore tokenStore})
    : _client = client ?? http.Client(),
      _tokenStore = tokenStore;

  String get _base => Env.apiBaseUrl;
  Uri _uri(String path) => Uri.parse('$_base$path');

  // ========================== INIT FROM STORAGE ==========================

  Future<void> initFromStorage() async {
    final saved = await _tokenStore.getToken();
    if (saved != null && saved.isNotEmpty) {
      g.setAuthToken(saved);
    }
  }

  // ===================== SEND VERIFICATION CODE =========================

  Future<void> sendVerificationCode({
    String? email,
    String? phoneNumber,
    required String password,
    required int ownerProjectLinkId,
  }) async {
    final uri = _uri('/api/auth/send-verification');

    final body = <String, String>{
      'password': password,
      'ownerProjectLinkId': ownerProjectLinkId.toString(),
    };
    if (email != null && email.isNotEmpty) body['email'] = email;
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      body['phoneNumber'] = phoneNumber;
    }

    try {
      final resp = await _safePost(uri, body: body);
      final decoded = _safeJson(resp.body);

      if (resp.statusCode >= 400) {
        _throwAuthFromHttp(
          resp,
          decoded,
          fallback: 'Failed to send verification',
        );
      }
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to send verification', original: e);
    }
  }

  // ========================= VERIFY EMAIL CODE ==========================

  Future<int> verifyEmailCode({
    required String email,
    required String code,
  }) async {
    final uri = _uri('/api/auth/verify-email-code');

    try {
      final resp = await _safePost(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'code': code}),
      );

      final decoded = _safeJson(resp.body);

      if (resp.statusCode >= 400) {
        _throwAuthFromHttp(
          resp,
          decoded,
          fallback: 'Invalid verification code',
        );
      }

      final user = decoded['user'] as Map<String, dynamic>? ?? {};
      final id = user['id'];
      if (id == null) throw AppException('No user id returned');
      return (id as num).toInt();
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to verify email code', original: e);
    }
  }

  // ========================= VERIFY PHONE CODE ==========================

  Future<int> verifyPhoneCode({
    required String phoneNumber,
    required String code,
  }) async {
    final uri = _uri('/api/auth/user/verify-phone-code');

    try {
      final resp = await _safePost(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phoneNumber': phoneNumber, 'code': code}),
      );

      final decoded = _safeJson(resp.body);

      if (resp.statusCode >= 400) {
        _throwAuthFromHttp(
          resp,
          decoded,
          fallback: 'Invalid verification code',
        );
      }

      final user = decoded['user'] as Map<String, dynamic>? ?? {};
      final id = user['id'];
      if (id == null) throw AppException('No user id returned');
      return (id as num).toInt();
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to verify phone code', original: e);
    }
  }

  // ======================= COMPLETE USER PROFILE ========================

  Future<UserModel> completeUserProfile({
    required int pendingId,
    required String username,
    required String firstName,
    required String lastName,
    required bool isPublicProfile,
    required int ownerProjectLinkId,
    String? profileImagePath,
  }) async {
    final uri = _uri('/api/auth/complete-profile');

    final request = http.MultipartRequest('POST', uri)
      ..fields['pendingId'] = pendingId.toString()
      ..fields['username'] = username
      ..fields['firstName'] = firstName
      ..fields['lastName'] = lastName
      ..fields['isPublicProfile'] = isPublicProfile.toString()
      ..fields['ownerProjectLinkId'] = ownerProjectLinkId.toString();

    if (profileImagePath != null && profileImagePath.isNotEmpty) {
      request.files.add(
        await http.MultipartFile.fromPath('profileImage', profileImagePath),
      );
    }

    try {
      final resp = await _safeSend(request);
      debugPrint('👤 COMPLETE PROFILE → ${resp.statusCode}');
      debugPrint('BODY: ${resp.body}');

      final decoded = _safeJson(resp.body);

      if (resp.statusCode >= 400) {
        _throwAuthFromHttp(
          resp,
          decoded,
          fallback: 'Failed to complete profile',
        );
      }

      return UserModel.fromLoginJson(decoded);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to complete profile', original: e);
    }
  }

  // ========================= USER LOGIN - EMAIL =========================

  Future<UserModel> loginWithEmail({
    required String email,
    required String password,
    required int ownerProjectLinkId,
  }) async {
    final uri = _uri('/api/auth/user/login');

    debugPrint('🔐 LOGIN REQUEST (EMAIL) → $uri');
    debugPrint('BODY: email=$email, ownerProjectLinkId=$ownerProjectLinkId');

    try {
      final resp = await _safePost(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'ownerProjectLinkId': ownerProjectLinkId.toString(),
        }),
      );

      debugPrint('🔐 LOGIN RESPONSE (EMAIL) → ${resp.statusCode}');
      debugPrint('BODY: ${resp.body}');

      final decoded = _safeJson(resp.body);

      if (resp.statusCode >= 400) {
        _throwAuthFromLogin(resp, decoded);
      }

      await _storeAuthFromLogin(decoded);
      return UserModel.fromLoginJson(decoded);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to login with email', original: e);
    }
  }

  // ========================= USER LOGIN - PHONE =========================

  Future<UserModel> loginWithPhone({
    required String phoneNumber,
    required String password,
    required int ownerProjectLinkId,
  }) async {
    final uri = _uri('/api/auth/user/login-phone');

    debugPrint('🔐 LOGIN REQUEST (PHONE) → $uri');
    debugPrint(
      'BODY: phoneNumber=$phoneNumber, ownerProjectLinkId=$ownerProjectLinkId',
    );

    try {
      final resp = await _safePost(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phoneNumber': phoneNumber,
          'password': password,
          'ownerProjectLinkId': ownerProjectLinkId.toString(),
        }),
      );

      debugPrint('🔐 LOGIN RESPONSE (PHONE) → ${resp.statusCode}');
      debugPrint('BODY: ${resp.body}');

      final decoded = _safeJson(resp.body);

      if (resp.statusCode >= 400) {
        _throwAuthFromLogin(resp, decoded);
      }

      await _storeAuthFromLogin(decoded);
      return UserModel.fromLoginJson(decoded);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to login with phone', original: e);
    }
  }

  // ========================= USER REACTIVATION =========================

  /// Call /api/auth/reactivate to turn an INACTIVE user back to ACTIVE.
  ///
  /// Returns the updated user model with the new token.
  // ========================= USER REACTIVATION =========================

  // ========================= USER REACTIVATION =========================

  /// Reactivate an INACTIVE user account.
  /// - Calls /api/auth/reactivate with { "id": userId }
  /// - Stores the new JWT token in AuthTokenStore
  /// - Does NOT try to parse a UserModel (to avoid decode errors).
  Future<void> reactivateUser({required int userId}) async {
    final uri = _uri('/api/auth/reactivate');

    try {
      final resp = await _safePost(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': userId}),
      );

      debugPrint('♻️ REACTIVATE USER → ${resp.statusCode}');
      debugPrint('BODY: ${resp.body}');

      final decoded = _safeJson(resp.body);

      if (resp.statusCode >= 400) {
        _throwAuthFromHttp(
          resp,
          decoded,
          fallback: 'Failed to reactivate account',
        );
      }

      // Backend returns: { message, token, user: {...} }
      // We only care about the token here.
      final storePayload = <String, dynamic>{
        'token': decoded['token'],
        'wasInactive': false,
      };

      await _storeAuthFromLogin(storePayload);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to reactivate account', original: e);
    }
  }

  // ========================= ADMIN LOGIN =========================

  Future<AdminLoginResponse> adminLogin({
    required String usernameOrEmail,
    required String password,
  }) async {
    final uri = _uri('/api/auth/admin/login');

    debugPrint('🛡️ ADMIN LOGIN → $uri');
    debugPrint('BODY: usernameOrEmail=$usernameOrEmail');

    try {
      final resp = await _safePost(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'usernameOrEmail': usernameOrEmail,
          'password': password,
        }),
      );

      debugPrint('🛡️ ADMIN LOGIN RESP → ${resp.statusCode}');
      debugPrint('BODY: ${resp.body}');

      final decoded = _safeJson(resp.body);

      if (resp.statusCode >= 400) {
        _throwAdminFromLogin(resp, decoded);
      }

      final token = (decoded['token'] as String?) ?? '';
      final role = (decoded['role'] as String?) ?? '';
      final admin =
          (decoded['admin'] as Map?)?.cast<String, dynamic>() ??
          const <String, dynamic>{};

      if (token.isEmpty || role.isEmpty) {
        throw AuthException(
          'Invalid server response for admin login',
          original: resp,
        );
      }

      // Note: do not store admin token in user AuthTokenStore.
      return AdminLoginResponse(token: token, role: role, admin: admin);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to login as admin', original: e);
    }
  }

  // ============================= TOKEN HELPERS ==========================

  Future<void> _storeAuthFromLogin(Map<String, dynamic> json) async {
    final token = json['token'] as String?;
    final wasInactive = json['wasInactive'] as bool? ?? false;

    if (token != null && token.isNotEmpty) {
      await _tokenStore.saveToken(token: token, wasInactive: wasInactive);
      g.setAuthToken(token);
    }
  }

  Future<String?> getSavedToken() => _tokenStore.getToken();
  Future<bool> getWasInactive() => _tokenStore.getWasInactive();

  Future<void> clearAuth() async {
    await _tokenStore.clear();
    g.setAuthToken('');
    debugPrint('🔓 Auth cleared: token removed from storage and globals');
  }

  // ============================ HELPERS ================================

  Map<String, dynamic> _safeJson(String body) {
    if (body.isEmpty) return {};
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) return decoded;
      return {};
    } catch (_) {
      return {};
    }
  }

  String? _extractBackendMessage(Map<String, dynamic> json) {
    final m = json['message'];
    final e = json['error'];
    if (m is String && m.trim().isNotEmpty) return m;
    if (e is String && e.trim().isNotEmpty) return e;
    return null;
  }

  Future<http.Response> _safePost(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    try {
      return await _client
          .post(uri, headers: headers, body: body)
          .timeout(const Duration(seconds: 30));
    } on SocketException catch (e) {
      throw NetworkException('No internet connection', original: e);
    } on TimeoutException catch (e) {
      throw NetworkException('Request timed out', original: e);
    } on http.ClientException catch (e) {
      throw NetworkException('Network error', original: e);
    }
  }

  Future<http.Response> _safeSend(http.BaseRequest request) async {
    try {
      final streamed = await _client
          .send(request)
          .timeout(const Duration(seconds: 60));
      return await http.Response.fromStream(streamed);
    } on SocketException catch (e) {
      throw NetworkException('No internet connection', original: e);
    } on TimeoutException catch (e) {
      throw NetworkException('Request timed out', original: e);
    } on http.ClientException catch (e) {
      throw NetworkException('Network error', original: e);
    }
  }

  Never _throwAuthFromHttp(
    http.Response resp,
    Map<String, dynamic> decoded, {
    required String fallback,
  }) {
    final backendMsg = _extractBackendMessage(decoded);
    final status = resp.statusCode;

    final message =
        backendMsg ??
        () {
          switch (status) {
            case 400:
              return 'Invalid request.';
            case 401:
              return 'Unauthorized.';
            case 403:
              return 'You don’t have permission to do this.';
            case 404:
              return 'Not found.';
            case 409:
              return 'Conflict. Please retry.';
            case 422:
              return 'Some fields are invalid.';
            case 500:
              return 'Server error. Please try later.';
            default:
              return fallback;
          }
        }();

    throw AuthException(message, original: resp);
  }


Future<void> clearUserSession() async {
    await _tokenStore.clear();
    g.setAuthToken('');
  }


  Never _throwAuthFromLogin(http.Response resp, Map<String, dynamic> decoded) {
    final status = resp.statusCode;
    final backendMsg = _extractBackendMessage(decoded)?.toLowerCase() ?? '';

    if (status == 404 || backendMsg.contains('user not found')) {
      throw AuthException(
        'User not found',
        code: 'USER_NOT_FOUND',
        original: resp,
      );
    }

    if (status == 400 ||
        status == 401 ||
        backendMsg.contains('invalid credentials') ||
        backendMsg.contains('bad credentials') ||
        backendMsg.contains('wrong password')) {
      throw AuthException(
        'Invalid email or password',
        code: 'INVALID_CREDENTIALS',
        original: resp,
      );
    }

    if (status == 423 ||
        backendMsg.contains('inactive') ||
        backendMsg.contains('disabled') ||
        backendMsg.contains('locked')) {
      throw AuthException(
        'Your account is inactive. Reactivate to continue.',
        code: 'INACTIVE',
        original: resp,
      );
    }

    final msg =
        _extractBackendMessage(decoded) ?? 'Login failed. Please try again.';
    throw AuthException(msg, code: 'AUTH_ERROR', original: resp);
  }

  Never _throwAdminFromLogin(http.Response resp, Map<String, dynamic> decoded) {
    final status = resp.statusCode;
    final backendMsg = _extractBackendMessage(decoded)?.toLowerCase() ?? '';

    if (status == 401 &&
        (backendMsg.contains('invalid credentials') ||
            backendMsg.contains('incorrect password'))) {
      throw AuthException(
        'Invalid credentials',
        code: 'ADMIN_INVALID_CREDENTIALS',
        original: resp,
      );
    }

    if (status == 401 && backendMsg.contains('access denied')) {
      throw AuthException(
        'Access denied',
        code: 'ADMIN_ACCESS_DENIED',
        original: resp,
      );
    }

    final msg =
        _extractBackendMessage(decoded) ??
        'Admin login failed. Please try again.';
    throw AuthException(msg, code: 'ADMIN_AUTH_ERROR', original: resp);
  }
}
