// lib/features/auth/data/services/auth_api_service.dart

import 'dart:convert';

import 'package:build4front/core/config/env.dart';
import 'package:build4front/core/network/globals.dart' as g;
import 'package:build4front/core/exceptions/app_exception.dart';
import 'package:build4front/core/exceptions/network_exception.dart';
import 'package:build4front/core/exceptions/auth_exception.dart';

import 'package:flutter/material.dart';
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
    if (email != null && email.isNotEmpty) {
      body['email'] = email;
    }
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      body['phoneNumber'] = phoneNumber;
    }

    try {
      final resp = await _client.post(uri, body: body);

      final decoded = _safeJson(resp.body);

      if (resp.statusCode >= 400) {
        final error =
            decoded['error']?.toString() ?? 'Failed to send verification';
        throw AuthException(error);
      }
    } on AuthException {
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
      final resp = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'code': code}),
      );

      final decoded = _safeJson(resp.body);

      if (resp.statusCode >= 400) {
        final error =
            decoded['error']?.toString() ?? 'Invalid verification code';
        throw AuthException(error);
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
      final resp = await _client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phoneNumber': phoneNumber, 'code': code}),
      );

      final decoded = _safeJson(resp.body);

      if (resp.statusCode >= 400) {
        final error =
            decoded['error']?.toString() ?? 'Invalid verification code';
        throw AuthException(error);
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
      final streamed = await _client.send(request);
      final resp = await http.Response.fromStream(streamed);

      debugPrint('👤 COMPLETE PROFILE → ${resp.statusCode}');
      debugPrint('BODY: ${resp.body}');

      final decoded = _safeJson(resp.body);

      if (resp.statusCode >= 400) {
        final error =
            decoded['error']?.toString() ?? 'Failed to complete profile';
        throw AuthException(error);
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
      final resp = await _client.post(
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
        final error = decoded['error']?.toString() ?? 'Login failed';
        throw AuthException(error);
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
      final resp = await _client.post(
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
        final error = decoded['error']?.toString() ?? 'Login failed';
        throw AuthException(error);
      }

      await _storeAuthFromLogin(decoded);

      return UserModel.fromLoginJson(decoded);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppException('Failed to login with phone', original: e);
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

  Future<void> clearAuth() => _tokenStore.clear();

  // ============================ JSON SAFE PARSER ========================

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
}
