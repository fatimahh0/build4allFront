// lib/features/home/presentation/widgets/home_header.dart
import 'dart:convert';

import 'package:build4front/app/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4front/core/network/globals.dart' as net;
import 'package:build4front/core/theme/theme_cubit.dart';

// ✅ Profile bloc/state/entity (optional)
import 'package:build4front/features/profile/presentation/bloc/user_profile_bloc.dart';
import 'package:build4front/features/profile/presentation/bloc/user_profile_state.dart';
import 'package:build4front/features/auth/domain/entities/user_entity.dart';

class HomeHeader extends StatelessWidget {
  final String appName;
  final String? fullName;
  final String? avatarUrl;
  final String welcomeText;

  // ✅ NEW: tap to go profile tab
  final VoidCallback? onProfileTap;

  const HomeHeader({
    super.key,
    required this.appName,
    this.fullName,
    this.avatarUrl,
    required this.welcomeText,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    final themeState = context.read<ThemeCubit>().state;
    final spacing = themeState.tokens.spacing;

    // ✅ Try read user from UserProfileBloc (if provided)
    UserEntity? profileUser;
    try {
      final st = context.watch<UserProfileBloc>().state;
      if (st is UserProfileLoaded) profileUser = st.user;
    } catch (_) {
      profileUser = null;
    }

    final nameFromProfile = _nameFromUserEntity(profileUser);
    final nameFromWidget = (fullName != null && fullName!.trim().isNotEmpty)
        ? fullName!.trim()
        : null;

    final jwtUserName = _getUserNameFromJwt();
    final ownerName = net.getOwnerNameFromJwt();

    final displayName =
        nameFromProfile ??
        nameFromWidget ??
        jwtUserName ??
        ownerName ??
        (appName.trim().isNotEmpty ? appName.trim() : 'Owner');

    final profileAvatar = (profileUser?.profilePictureUrl ?? '').trim();
    final widgetAvatar = (avatarUrl ?? '').trim();
    final chosenAvatar = profileAvatar.isNotEmpty
        ? profileAvatar
        : widgetAvatar;

    String? resolvedAvatar;
    if (chosenAvatar.isNotEmpty) resolvedAvatar = net.resolveUrl(chosenAvatar);

    final avatar = (resolvedAvatar != null && resolvedAvatar.trim().isNotEmpty)
        ? CircleAvatar(
            radius: 22,
            backgroundColor: c.primary.withOpacity(0.15),
            backgroundImage: NetworkImage(resolvedAvatar),
            onBackgroundImageError: (_, __) {},
          )
        : CircleAvatar(
            radius: 22,
            backgroundColor: c.primary.withOpacity(0.15),
            child: Icon(Icons.person_rounded, color: c.primary),
          );

    // ✅ Make ONLY the left part clickable (avatar + texts)
    final leftClickable = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onProfileTap, // ✅ switch tab from MainShell
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: spacing.xs,
            horizontal: spacing.xs,
          ),
          child: Row(
            children: [
              avatar,
              SizedBox(width: spacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(welcomeText, style: t.labelLarge),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.55,
                    child: Text(
                      displayName,
                      style: t.titleMedium,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    return Container(
      margin: EdgeInsets.only(bottom: spacing.md),
      child: Row(
        children: [
          Expanded(child: leftClickable),
         IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(AppRouter.notifications);
            },
            icon: const Icon(Icons.notifications_none_rounded),
          ),

        ],
      ),
    );
  }

  String? _nameFromUserEntity(UserEntity? user) {
    if (user == null) return null;
    final first = (user.firstName ?? '').trim();
    final last = (user.lastName ?? '').trim();
    final username = (user.username ?? '').trim();
    final email = (user.email ?? '').trim();
    final phone = (user.phoneNumber ?? '').trim();

    if (first.isNotEmpty || last.isNotEmpty) return ('$first $last').trim();
    if (username.isNotEmpty) return username;
    if (email.isNotEmpty) return email;
    if (phone.isNotEmpty) return phone;
    return null;
  }
}

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

    if (first.isNotEmpty || last.isNotEmpty) return ('$first $last').trim();
    if (username.isNotEmpty) return username;
    if (subject.isNotEmpty) return subject;

    return null;
  } catch (_) {
    return null;
  }
}
