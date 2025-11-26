import 'dart:convert';
import 'package:build4front/core/config/env.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/user_model.dart';

class AuthApiService {
  final http.Client _client;

  AuthApiService({http.Client? client}) : _client = client ?? http.Client();

  String get _base => Env.apiBaseUrl; // مثلا: http://192.168.1.2:8080

  Uri _uri(String path) => Uri.parse('$_base$path');

  /// POST /api/auth/send-verification
  Future<void> sendVerificationCode({
    String? email,
    String? phoneNumber,
    required String password,
    required int ownerProjectLinkId,
  }) async {
    final uri = _uri('/api/auth/send-verification');

    // backend يستخدم @RequestParam → منبعت form-encoded عادي
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

    final resp = await _client.post(uri, body: body);

    if (resp.statusCode >= 400) {
      final decoded = _safeJson(resp.body);
      final error =
          decoded['error']?.toString() ?? 'Failed to send verification';
      throw Exception(error);
    }
  }

  /// POST /api/auth/verify-email-code  (JSON body)
  Future<int> verifyEmailCode({
    required String email,
    required String code,
  }) async {
    final uri = _uri('/api/auth/verify-email-code');

    final resp = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'code': code}),
    );

    final decoded = _safeJson(resp.body);

    if (resp.statusCode >= 400) {
      final error = decoded['error']?.toString() ?? 'Invalid verification code';
      throw Exception(error);
    }

    final user = decoded['user'] as Map<String, dynamic>? ?? {};
    final id = user['id'];
    if (id == null) throw Exception('No user id returned');
    return (id as num).toInt();
  }

  /// POST /api/auth/user/login  (JSON body)
  Future<UserModel> loginWithEmail({
    required String email,
    required String password,
    required int ownerProjectLinkId,
  }) async {
    final uri = _uri('/api/auth/user/login');

    debugPrint('🔐 LOGIN REQUEST → $uri');
    debugPrint('BODY: email=$email, ownerProjectLinkId=$ownerProjectLinkId');

    final resp = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'ownerProjectLinkId': ownerProjectLinkId.toString(),
      }),
    );

    debugPrint('🔐 LOGIN RESPONSE → ${resp.statusCode}');
    debugPrint('BODY: ${resp.body}');

    final decoded = _safeJson(resp.body);

    if (resp.statusCode >= 400) {
      final error = decoded['error']?.toString() ?? 'Login failed';
      throw Exception(error);
    }

    return UserModel.fromLoginJson(decoded);
  }

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
