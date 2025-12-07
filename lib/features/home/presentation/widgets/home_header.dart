// lib/features/home/presentation/widgets/home_header.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4front/core/network/globals.dart' as net;
import 'package:build4front/core/theme/theme_cubit.dart';

class HomeHeader extends StatelessWidget {
  /// App name from AppConfig (dart-define). Used as a fallback label.
  final String appName;

  /// If we are on the user app: pass user's firstName + lastName (or username).
  /// If null, we will try to use USER name from JWT, then OWNER name, then appName.
  final String? fullName;

  /// Optional profile picture (user side).
  final String? avatarUrl;

  /// Localized welcome text (e.g. "Welcome 👋").
  final String welcomeText;

  const HomeHeader({
    super.key,
    required this.appName,
    this.fullName,
    this.avatarUrl,
    required this.welcomeText,
  });

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    final themeState = context.read<ThemeCubit>().state;
    final spacing = themeState.tokens.spacing;

    // 1) Name coming from the screen (AuthBloc user).
    final userNameFromBloc = (fullName != null && fullName!.trim().isNotEmpty)
        ? fullName!.trim()
        : null;

    // 2) Name decoded from JWT if role = USER.
    final jwtUserName = _getUserNameFromJwt();

    // 3) Owner name from JWT (for owner/admin side).
    final ownerName = _getOwnerNameFromJwt();

    // 4) Final priority:
    //    userNameFromBloc  →  jwtUserName  →  ownerName  →  appName  → "Owner"
    String displayName;
    if (userNameFromBloc != null && userNameFromBloc.isNotEmpty) {
      displayName = userNameFromBloc;
    } else if (jwtUserName != null && jwtUserName.isNotEmpty) {
      displayName = jwtUserName;
    } else if (ownerName != null && ownerName.isNotEmpty) {
      displayName = ownerName;
    } else if (appName.trim().isNotEmpty) {
      displayName = appName.trim();
    } else {
      displayName = 'Owner';
    }

    // Resolve avatar URL if provided.
    String? resolvedAvatar;
    if (avatarUrl != null && avatarUrl!.trim().isNotEmpty) {
      resolvedAvatar = net.resolveUrl(avatarUrl!);
    }

    Widget avatar;
    if (resolvedAvatar != null && resolvedAvatar.trim().isNotEmpty) {
      avatar = CircleAvatar(
        radius: 22,
        backgroundColor: c.primary.withOpacity(0.15),
        backgroundImage: NetworkImage(resolvedAvatar),
      );
    } else {
      avatar = CircleAvatar(
        radius: 22,
        backgroundColor: c.primary.withOpacity(0.15),
        child: Icon(Icons.person_rounded, color: c.primary),
      );
    }

    return Container(
      margin: EdgeInsets.only(bottom: spacing.md),
      child: Row(
        children: [
          avatar,
          SizedBox(width: spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(welcomeText, style: t.labelLarge),
                Text(
                  displayName,
                  style: t.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // TODO: open notifications screen when implemented.
            },
            icon: const Icon(Icons.notifications_none_rounded),
          ),
        ],
      ),
    );
  }
}

/// Decode current JWT and extract USER full name (first + last or username).
String? _getUserNameFromJwt() {
  final raw = net.readAuthToken();
  if (raw.isEmpty) return null;

  try {
    final token = raw
        .replaceFirst(RegExp('^Bearer\\s+', caseSensitive: false), '')
        .trim();
    final parts = token.split('.');
    if (parts.length != 3) return null;

    final payloadJson = utf8.decode(
      base64Url.decode(base64Url.normalize(parts[1])),
    );
    final map = jsonDecode(payloadJson) as Map<String, dynamic>;

    final role = (map['role'] as String?)?.toUpperCase();
    if (role != 'USER') return null;

    final first = (map['firstName'] as String?)?.trim() ?? '';
    final last = (map['lastName'] as String?)?.trim() ?? '';
    final username = (map['username'] as String?)?.trim() ?? '';
    final subject = (map['sub'] as String?)?.trim() ?? '';

    if (first.isNotEmpty || last.isNotEmpty) {
      return ('$first $last').trim();
    }
    if (username.isNotEmpty) return username;
    if (subject.isNotEmpty) return subject;

    return null;
  } catch (_) {
    return null;
  }
}

/// Decode OWNER name from JWT (for owner/admin app header fallback).
String? _getOwnerNameFromJwt() {
  final raw = net.readAuthToken();
  if (raw.isEmpty) return null;

  try {
    final token = raw
        .replaceFirst(RegExp('^Bearer\\s+', caseSensitive: false), '')
        .trim();
    final parts = token.split('.');
    if (parts.length != 3) return null;

    final payloadJson = utf8.decode(
      base64Url.decode(base64Url.normalize(parts[1])),
    );
    final map = jsonDecode(payloadJson) as Map<String, dynamic>;

    final role = (map['role'] as String?)?.toUpperCase();
    if (role != 'OWNER') return null;

    final username = (map['username'] as String?)?.trim() ?? '';
    final subject = (map['sub'] as String?)?.trim() ?? '';

    if (username.isNotEmpty) return username;
    if (subject.isNotEmpty) return subject;

    return null;
  } catch (_) {
    return null;
  }
}
