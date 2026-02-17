import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dlibphonenumber/dlibphonenumber.dart';

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

  /// Optional: if backend sends local numbers (no +country),
  /// you can pass "LB", "FR", "US", ...
  final String? ownerPhoneRegionIso2;

  /// Front-only fallback region if backend doesn’t provide region.
  /// Default = LB
  final String fallbackRegionIso2;

  /// multi-app identity
  final String? appName;

  /// optional: identify instance
  final int? ownerProjectId;

  /// ✅ NEW: link id (ownerProjectLinkId)
  final int? ownerProjectLinkId;

  /// ✅ NEW: support info (nice-to-have)
  final String? supportName;
  final String? supportEmail;

  /// optional override
  final String? whatsappMessageOverride;

  /// enable/disable logs
  final bool debugLogs;

  const HomeBottomSection({
    super.key,
    this.ownerPhoneNumber,
    this.ownerPhoneRegionIso2,
    this.fallbackRegionIso2 = 'LB',
    this.appName,
    this.ownerProjectId,
    this.ownerProjectLinkId,
    this.supportName,
    this.supportEmail,
    this.whatsappMessageOverride,
    this.debugLogs = true,
  });

  void _log(String msg) {
    if (!debugLogs) return;
    debugPrint('[HomeBottomSection] $msg');
  }

  // -----------------------------
  // ✅ User name resolver (Profile -> Auth -> JWT)
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
    // 1) Profile bloc
    UserEntity? profileUser;
    try {
      final st = context.read<UserProfileBloc>().state;
      if (st is UserProfileLoaded) profileUser = st.user;
    } catch (_) {
      profileUser = null;
    }
    final fromProfile = _nameFromUserEntity(profileUser);

    // 2) Auth bloc
    final AuthState authSt = context.read<AuthBloc>().state;
    final dynamic authUser = authSt.user;
    String? fromAuth;

    if (authSt.isLoggedIn && authUser != null) {
      try {
        if (authUser is UserEntity) {
          fromAuth = _nameFromUserEntity(authUser);
        } else {
          final first = ('${authUser.firstName ?? ''}').trim();
          final last = ('${authUser.lastName ?? ''}').trim();
          final username = ('${authUser.username ?? ''}').trim();
          final email = ('${authUser.email ?? ''}').trim();
          final phone = ('${authUser.phoneNumber ?? ''}').trim();

          if (first.isNotEmpty || last.isNotEmpty) {
            fromAuth = ('$first $last').trim();
          } else if (username.isNotEmpty) {
            fromAuth = username;
          } else if (email.isNotEmpty) {
            fromAuth = email;
          } else if (phone.isNotEmpty) {
            fromAuth = phone;
          }
        }
      } catch (_) {
        fromAuth = null;
      }
    }

    // 3) JWT fallback
    final fromJwt = _getUserNameFromJwt();

    final chosen = fromProfile ?? fromAuth ?? fromJwt;
    _log('resolveUserName => "$chosen"');
    return chosen;
  }

  // -----------------------------
  // ✅ Region resolver
  // priority: param -> fallbackRegionIso2 -> locale country -> platform locale -> LB
  // -----------------------------
  String _resolveRegionIso2(BuildContext context) {
    final fromParam = (ownerPhoneRegionIso2 ?? '').trim().toUpperCase();
    if (fromParam.isNotEmpty) return fromParam;

    final fromFallback = fallbackRegionIso2.trim().toUpperCase();
    if (fromFallback.isNotEmpty) return fromFallback;

    try {
      final loc = (Localizations.localeOf(context).countryCode ?? '')
          .trim()
          .toUpperCase();
      if (loc.isNotEmpty) return loc;
    } catch (_) {}

    final loc2 =
        (WidgetsBinding.instance.platformDispatcher.locale.countryCode ?? '')
            .trim()
            .toUpperCase();

    return loc2.isNotEmpty ? loc2 : 'LB';
  }

  // -----------------------------
  // ✅ WhatsApp normalizer (E.164 -> digits only)
  // Accepts:
  // +96170123123
  // 0096170123123
  // 96170123123
  // 70123123 (needs region LB)
  // -----------------------------
  String? _normalizeForWhatsApp(BuildContext context, String raw) {
    var s = raw.trim();
    if (s.isEmpty) return null;

    final low = s.toLowerCase();
    if (low == 'null' || low == 'n/a' || low == 'none') return null;

    // keep digits and +
    s = s.replaceAll(RegExp(r'[^0-9+]'), '');

    // 00xxxx -> +xxxx
    if (s.startsWith('00')) s = '+${s.substring(2)}';

    final util = PhoneNumberUtil.instance;
    final region = _resolveRegionIso2(context);

    _log('normalize raw="$raw" cleaned="$s" region="$region"');

    String? okToDigits(String e164) {
      final digits = e164.startsWith('+') ? e164.substring(1) : e164;
      if (!RegExp(r'^\d{8,15}$').hasMatch(digits)) return null;
      return digits;
    }

    if (s.startsWith('+')) {
      try {
        final num = util.parse(s, 'ZZ');
        if (!util.isValidNumber(num)) return null;
        final e164 = util.format(num, PhoneNumberFormat.e164);
        return okToDigits(e164);
      } catch (e) {
        _log('intl parse error: $e');
      }
    }

    if (RegExp(r'^\d+$').hasMatch(s)) {
      try {
        final numLocal = util.parse(s, region);
        if (util.isValidNumber(numLocal)) {
          final e164 = util.format(numLocal, PhoneNumberFormat.e164);
          return okToDigits(e164);
        }
      } catch (e) {
        _log('local parse error: $e');
      }

      try {
        final numIntl = util.parse('+$s', 'ZZ');
        if (util.isValidNumber(numIntl)) {
          final e164 = util.format(numIntl, PhoneNumberFormat.e164);
          return okToDigits(e164);
        }
      } catch (e) {
        _log('digits->intl parse error: $e');
      }
    }

    return null;
  }

 String _buildMessage(BuildContext context) {
  final app = (appName ?? '').trim().isNotEmpty ? appName!.trim() : 'Build4All';
  final userName = (_resolveUserName(context) ?? '').trim();
  final identity = userName.isNotEmpty ? userName : 'Guest';

  final proj = ownerProjectId != null ? '#$ownerProjectId' : 'N/A';
  final link = ownerProjectLinkId != null ? '#$ownerProjectLinkId' : 'N/A';

  final now = DateTime.now();
  final ts =
      '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} '
      '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

  return [
    'Hello Support,',
    '',
    'I need assistance with an issue in $app.',
    '',
    '• Project ID: $proj',
    '• Link ID: $link',
    '• User: $identity',
    '• Time: $ts',
    '',
    'Issue:',
    '- ',
    '',
    'Thank you.',
  ].join('\n');
}


  Future<void> _openWhatsApp(BuildContext context) async {
    final raw = (ownerPhoneNumber ?? '').trim();
    final region = _resolveRegionIso2(context);

    if (raw.isEmpty || raw.toLowerCase() == 'null') {
      AppToast.show(
        context,
        'Owner support number is not configured.',
        isError: true,
      );
      _log('tap blocked: raw is empty/null');
      return;
    }

    final phone = _normalizeForWhatsApp(context, raw);
    _log('tap: raw="$raw" region="$region" normalized="$phone"');

    if (phone == null) {
      AppToast.show(
        context,
        'Invalid support number.\n'
        '✅ Best: +<country><number> like +96170123123\n'
        '✅ If local: we interpret using region="$region".\n'
        '🔎 Raw received: "$raw"',
        isError: true,
      );
      return;
    }

    final msg = Uri.encodeComponent(_buildMessage(context));

    final appUri = Uri.parse('whatsapp://send?phone=$phone&text=$msg');
    final webUri = Uri.parse('https://wa.me/$phone?text=$msg');

    try {
      if (await canLaunchUrl(appUri)) {
        final ok =
            await launchUrl(appUri, mode: LaunchMode.externalApplication);
        _log('launch whatsapp:// ok=$ok');
        if (ok) return;
      }

      final ok2 = await launchUrl(webUri, mode: LaunchMode.externalApplication);
      _log('launch wa.me ok=$ok2');

      if (!ok2) {
        AppToast.show(context, 'Could not open WhatsApp.', isError: true);
      }
    } catch (e) {
      _log('launch error: $e');
      AppToast.show(context, 'Could not open WhatsApp.', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.read<ThemeCubit>().state.tokens.spacing;
    final l10n = AppLocalizations.of(context)!;

    final hasPhone = (ownerPhoneNumber ?? '').trim().isNotEmpty &&
        (ownerPhoneNumber ?? '').trim().toLowerCase() != 'null';

    final cards = <_BottomCardModel>[
      _BottomCardModel(
        icon: Icons.chat_rounded,
        title: l10n.home_footer_contact_title,
        subtitle: hasPhone ? 'WhatsApp' : l10n.home_bookings_placeholder,
        onTap: hasPhone ? () => _openWhatsApp(context) : null,
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
      constraints: const BoxConstraints(minHeight: 92),
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
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  model.title,
                  style: titleStyle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: spacing.xs),
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
