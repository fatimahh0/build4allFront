// lib/features/home/presentation/widgets/home_header.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:build4front/core/network/globals.dart' as net;
import 'package:build4front/core/theme/theme_cubit.dart';

class HomeHeader extends StatelessWidget {
  final String appName;
  final String? fullName;
  final String? avatarUrl;
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

    final displayName = (fullName == null || fullName!.trim().isEmpty)
        ? appName
        : fullName!;

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
              // TODO: open notifications screen
            },
            icon: const Icon(Icons.notifications_none_rounded),
          ),
        ],
      ),
    );
  }
}
