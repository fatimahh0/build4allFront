import 'dart:convert';
import 'package:flutter/material.dart';

import 'remote_theme_dto.dart';

Color _parseColor(String? hex, String fallback) {
  var v = (hex ?? fallback).replaceAll('#', '');
  if (v.length == 6) v = 'FF$v';
  return Color(int.parse(v, radix: 16));
}

/* ------------------------------------ */
/*              COLOR TOKENS            */
/* ------------------------------------ */

class ColorTokens {
  final Color primary;
  final Color onPrimary;
  final Color background;
  final Color surface;
  final Color label;
  final Color body;
  final Color border;
  final Color error;

  const ColorTokens({
    required this.primary,
    required this.onPrimary,
    required this.background,
    required this.surface,
    required this.label,
    required this.body,
    required this.border,
    required this.error,
  });
}

/* ------------------------------------ */
/*               CARD TOKENS            */
/* ------------------------------------ */

class CardTokens {
  final double radius;
  final double elevation;
  final double padding;
  final double imageHeight;
  final bool showShadow;
  final bool showBorder;

  const CardTokens({
    required this.radius,
    required this.elevation,
    required this.padding,
    required this.imageHeight,
    required this.showShadow,
    required this.showBorder,
  });
}

/* ------------------------------------ */
/*              SEARCH TOKENS           */
/* ------------------------------------ */

class SearchTokens {
  final double radius;
  final double borderWidth;
  final bool dense;

  const SearchTokens({
    required this.radius,
    required this.borderWidth,
    required this.dense,
  });
}

/* ------------------------------------ */
/*              BUTTON TOKENS           */
/* ------------------------------------ */

class ButtonTokens {
  final double radius;
  final double height;
  final double textSize;
  final bool fullWidth;

  const ButtonTokens({
    required this.radius,
    required this.height,
    required this.textSize,
    required this.fullWidth,
  });
}

/* ------------------------------------ */
/*            THEME TOKENS ROOT         */
/* ------------------------------------ */

class AppThemeTokens {
  final ColorTokens colors;
  final CardTokens card;
  final SearchTokens search;
  final ButtonTokens button;

  const AppThemeTokens({
    required this.colors,
    required this.card,
    required this.search,
    required this.button,
  });

  factory AppThemeTokens.fromRemote(RemoteThemeDto remote) {
    final vm = remote.valuesMobile;
    final colorsMap = (vm['colors'] as Map<String, dynamic>?) ?? {};
    final cardMap = (vm['card'] as Map<String, dynamic>?) ?? {};
    final searchMap = (vm['search'] as Map<String, dynamic>?) ?? {};
    final buttonMap = (vm['button'] as Map<String, dynamic>?) ?? {}; // ← NEW

    final colors = ColorTokens(
      primary: _parseColor(colorsMap['primary'], '#16A34A'),
      onPrimary: _parseColor(colorsMap['onPrimary'], '#FFFFFF'),
      background: _parseColor(colorsMap['background'], '#FFFFFF'),
      surface: _parseColor(colorsMap['surface'], '#FFFFFF'),
      label: _parseColor(colorsMap['label'], '#111827'),
      body: _parseColor(colorsMap['body'], '#374151'),
      border: _parseColor(
        colorsMap['border'],
        colorsMap['primary'] ?? '#16A34A',
      ),
      error: _parseColor(colorsMap['error'], '#DC2626'),
    );

    final card = CardTokens(
      radius: (cardMap['radius'] as num?)?.toDouble() ?? 16,
      elevation: (cardMap['elevation'] as num?)?.toDouble() ?? 4,
      padding: (cardMap['padding'] as num?)?.toDouble() ?? 12,
      imageHeight: (cardMap['imageHeight'] as num?)?.toDouble() ?? 120,
      showShadow: cardMap['showShadow'] as bool? ?? true,
      showBorder: cardMap['showBorder'] as bool? ?? true,
    );

    final search = SearchTokens(
      radius: (searchMap['radius'] as num?)?.toDouble() ?? 16,
      borderWidth: (searchMap['borderWidth'] as num?)?.toDouble() ?? 1.4,
      dense: searchMap['dense'] as bool? ?? true,
    );

    final button = ButtonTokens(
      radius: (buttonMap['radius'] as num?)?.toDouble() ?? 16,
      height: (buttonMap['height'] as num?)?.toDouble() ?? 48,
      textSize: (buttonMap['textSize'] as num?)?.toDouble() ?? 15,
      fullWidth: buttonMap['fullWidth'] as bool? ?? true,
    );

    return AppThemeTokens(
      colors: colors,
      card: card,
      search: search,
      button: button,
    );
  }

  factory AppThemeTokens.fallback() {
    return AppThemeTokens(
      colors: ColorTokens(
        primary: _parseColor(null, '#16A34A'),
        onPrimary: _parseColor(null, '#FFFFFF'),
        background: _parseColor(null, '#FFFFFF'),
        surface: _parseColor(null, '#FFFFFF'),
        label: _parseColor(null, '#111827'),
        body: _parseColor(null, '#374151'),
        border: _parseColor(null, '#16A34A'),
        error: _parseColor(null, '#DC2626'),
      ),
      card: const CardTokens(
        radius: 16,
        elevation: 4,
        padding: 12,
        imageHeight: 120,
        showShadow: true,
        showBorder: true,
      ),
      search: const SearchTokens(radius: 16, borderWidth: 1.4, dense: true),
      button: const ButtonTokens(
        radius: 16,
        height: 48,
        textSize: 15,
        fullWidth: true,
      ),
    );
  }
}
