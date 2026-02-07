import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:build4front/core/theme/theme_cubit.dart';
import 'package:build4front/l10n/app_localizations.dart';
import 'package:build4front/common/widgets/app_toast.dart';

import 'package:build4front/features/auth/presentation/login/bloc/auth_bloc.dart';
import 'package:build4front/features/auth/presentation/login/bloc/auth_state.dart';

import 'package:build4front/features/profile/presentation/bloc/user_profile_bloc.dart';
import 'package:build4front/features/profile/presentation/bloc/user_profile_state.dart';
import 'package:build4front/features/auth/domain/entities/user_entity.dart';

import 'package:build4front/core/network/globals.dart' as net;

class HomeBottomSection extends StatelessWidget {
  final String? ownerPhoneNumber;

  /// ✅ multi-app identity
  final String? appName;

  /// ✅ optional: identify instance (if you have it)
  final int? ownerProjectId;

  /// ✅ optional override
  final String? whatsappMessageOverride;

  /// ✅ enable/disable logs
  final bool debugLogs;

  const HomeBottomSection({
    super.key,
    this.ownerPhoneNumber,
    this.appName,
    this.ownerProjectId,
    this.whatsappMessageOverride,
    this.debugLogs = true,
  });

  void _log(String msg) {
    if (!debugLogs) return;
    debugPrint('[HomeBottomSection] $msg');
  }

  // -----------------------------
  // ✅ Same name logic as header
  // -----------------------------
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

  String? _resolveUserName(BuildContext context) {
    // 1) UserProfileBloc (like header)
    UserEntity? profileUser;
    try {
      final st = context.read<UserProfileBloc>().state;
      if (st is UserProfileLoaded) profileUser = st.user;
    } catch (_) {
      profileUser = null;
    }

    final nameFromProfile = _nameFromUserEntity(profileUser);
    _log('nameFromProfile=$nameFromProfile profileUser=${profileUser != null}');

    // 2) AuthBloc user
    final AuthState authSt = context.read<AuthBloc>().state;
    final dynamic authUser = authSt.user;
    String? nameFromAuth;

    if (authSt.isLoggedIn && authUser != null) {
      try {
        // If authUser is UserEntity, this works:
        if (authUser is UserEntity) {
          nameFromAuth = _nameFromUserEntity(authUser);
        } else {
          // dynamic access attempt
          final first = ('${authUser.firstName ?? ''}').trim();
          final last = ('${authUser.lastName ?? ''}').trim();
          final username = ('${authUser.username ?? ''}').trim();
          final email = ('${authUser.email ?? ''}').trim();
          final phone = ('${authUser.phoneNumber ?? ''}').trim();

          if (first.isNotEmpty || last.isNotEmpty) {
            nameFromAuth = ('$first $last').trim();
          } else if (username.isNotEmpty) {
            nameFromAuth = username;
          } else if (email.isNotEmpty) {
            nameFromAuth = email;
          } else if (phone.isNotEmpty) {
            nameFromAuth = phone;
          }
        }
      } catch (e) {
        _log('nameFromAuth error: $e');
        nameFromAuth = null;
      }
    }

    _log(
        'auth.isLoggedIn=${authSt.isLoggedIn} auth.userType=${authUser?.runtimeType} nameFromAuth=$nameFromAuth');

    // 3) JWT fallback
    final jwtName = _getUserNameFromJwt();
    _log('jwtName=$jwtName');

    final chosen = nameFromProfile ?? nameFromAuth ?? jwtName;

    _log('FINAL chosen name=$chosen');

    return chosen;
  }

  // -----------------------------
  // ✅ WhatsApp number normalizer
  // -----------------------------
  String? _normalizeForWhatsApp(String raw) {
    var s = raw.trim();
    if (s.isEmpty) return null;

    s = s.replaceAll(RegExp(r'[^0-9+]'), '');

    if (s.startsWith('+')) s = s.substring(1);
    if (s.startsWith('00')) s = s.substring(2);

    // ✅ Lebanon quick test: 8 digits => assume +961
    if (s.length == 8) return '961$s';

    if (s.length >= 10) return s;
    return null;
  }

  String _buildMessage(BuildContext context) {
    if ((whatsappMessageOverride ?? '').trim().isNotEmpty) {
      return whatsappMessageOverride!.trim();
    }

    final app = (appName ?? '').trim().isNotEmpty ? appName!.trim() : 'the app';
    final userName = _resolveUserName(context);
    final whoLine = (userName ?? '').trim().isNotEmpty
        ? 'User: $userName'
        : 'User: (guest)';

    final projLine =
        ownerProjectId != null ? 'Project: #$ownerProjectId' : null;

    return [
      'Hi 👋',
      'I’m contacting you from $app.',
      if (projLine != null) projLine,
      whoLine,
      '',
      'I need help with:',
    ].join('\n');
  }

  Future<void> _openWhatsApp(BuildContext context) async {
    final raw = (ownerPhoneNumber ?? '').trim();
    final phone = _normalizeForWhatsApp(raw);

    _log('tap contact: ownerPhoneRaw="$raw" normalized="$phone"');

    if (phone == null) {
      AppToast.show(
        context,
        'Invalid owner number. Use international format like +961XXXXXXXX.',
        isError: true,
      );
      return;
    }

    final msg = Uri.encodeComponent(_buildMessage(context));
    final uri = Uri.parse('https://wa.me/$phone?text=$msg');

    _log('opening WA uri=$uri');

    try {
      final ok = await launchUrl(
        uri,
        mode: LaunchMode.externalNonBrowserApplication, // ✅ Android best
      );

      _log('launchUrl ok=$ok');

      if (!ok) {
        AppToast.show(context, 'Could not open WhatsApp.', isError: true);
      }
    } catch (e) {
      _log('launch error: $e');
      AppToast.show(context, 'Could not open WhatsApp.', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final spacing = context.read<ThemeCubit>().state.tokens.spacing;
    final l10n = AppLocalizations.of(context)!;

    final cards = <_BottomCardModel>[
      _BottomCardModel(
        icon: Icons.chat_rounded,
        title: l10n.home_footer_contact_title,
        subtitle: 'WhatsApp',
        onTap: () => _openWhatsApp(context),
      ),
      _BottomCardModel(
        icon: Icons.credit_card_rounded,
        title: l10n.home_bottom_slide_secure_title,
      ),
      _BottomCardModel(
        icon: Icons.verified_rounded,
        title: l10n.home_bottom_benefit_authentic_products,
      ),
    ];

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (int i = 0; i < cards.length; i++) ...[
              _ProBottomCard(model: cards[i]),
              if (i != cards.length - 1) SizedBox(height: spacing.md),
            ],
            SizedBox(height: spacing.xs),
          ],
        ),
      ),
    );
  }
}

class _BottomCardModel {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  const _BottomCardModel({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
  });
}

class _ProBottomCard extends StatelessWidget {
  final _BottomCardModel model;

  const _ProBottomCard({required this.model});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final spacing = context.read<ThemeCubit>().state.tokens.spacing;

    final clickable = model.onTap != null;
    final subtitleText = (model.subtitle ?? '').trim();

    final titleStyle = t.titleSmall?.copyWith(fontWeight: FontWeight.w800);
    final subtitleStyle = t.bodySmall?.copyWith(
      color: c.onSurface.withOpacity(0.6),
      fontWeight: FontWeight.w600,
    );

    final card = Container(
      constraints:
          const BoxConstraints(minHeight: 92), // ✅ same “weight” for all
      padding:
          EdgeInsets.symmetric(horizontal: spacing.lg, vertical: spacing.md),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.outline.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: c.onSurface.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: c.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(model.icon, color: c.primary, size: 24),
          ),
          SizedBox(width: spacing.md),

          Expanded(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center, // ✅ nicer vertical alignment
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  model.title,
                  style: titleStyle,
                  maxLines: 2, // ✅ was 1 (this was the cut)
                  overflow:
                      TextOverflow.ellipsis, // ✅ still safe on tiny screens
                ),
                SizedBox(height: spacing.xs),

                // ✅ always reserve subtitle line height so all cards look same
                Opacity(
                  opacity: subtitleText.isNotEmpty ? 1 : 0,
                  child: Text(
                    subtitleText.isNotEmpty ? subtitleText : 'placeholder',
                    style: subtitleStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // ✅ keep arrow only for clickable (pro UX)
          if (clickable) ...[
            SizedBox(width: spacing.sm),
            Icon(Icons.chevron_right_rounded,
                color: c.onSurface.withOpacity(0.55)),
          ],
        ],
      ),
    );

    if (!clickable) return card;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: model.onTap,
        borderRadius: BorderRadius.circular(18),
        child: card,
      ),
    );
  }
}
