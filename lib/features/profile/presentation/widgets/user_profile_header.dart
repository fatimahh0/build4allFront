import 'package:flutter/material.dart';
import 'package:build4front/features/auth/domain/entities/user_entity.dart';
import 'package:build4front/core/network/globals.dart' as g;

class UserProfileHeader extends StatelessWidget {
  final UserEntity user;
  const UserProfileHeader({super.key, required this.user});

  // Base host without /api (e.g. http://192.168.1.8:8080)
  String _serverRootNoApi() {
    final base = (g.appServerRoot ?? '').trim();
    if (base.isEmpty) return '';
    return base
        .replaceFirst(RegExp(r'/api/?$'), '')
        .replaceFirst(RegExp(r'/+$'), '');
  }

  // If path is absolute, return it; else join host + / + path
  String? _buildImageUrl(String? pathOrUrl) {
    if (pathOrUrl == null || pathOrUrl.isEmpty) return null;

    // Already absolute?
    if (RegExp(r'^https?://', caseSensitive: false).hasMatch(pathOrUrl)) {
      return pathOrUrl;
    }

    final host = _serverRootNoApi();
    if (host.isEmpty) return null;
    final p = pathOrUrl.replaceFirst(RegExp(r'^/+'), '');
    return '$host/$p';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const size = 96.0;

    final url = _buildImageUrl(user.profilePictureUrl);
    final status = (user.status ?? 'ACTIVE').toString();

    return Column(
      children: [
        // avatar
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.surface,
            border: Border.all(
              color: theme.colorScheme.outlineVariant,
              width: 1,
            ),
          ),
          child: ClipOval(
            child: (url == null)
                ? Icon(
                    Icons.person,
                    size: size * 0.46,
                    color: theme.colorScheme.onSurfaceVariant,
                  )
                : Image.network(
                    url,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.person,
                      size: size * 0.46,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 12),

        // display name
        Text(
          user.displayName,
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),

        // ✅ status only (no public/private)
        Text(
          'Status: $status',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onBackground.withOpacity(0.8),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
