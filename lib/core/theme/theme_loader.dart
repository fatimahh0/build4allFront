import 'dart:convert';
import 'package:flutter/material.dart';
import '../config/env.dart';

/// Simple value object holding the main theme colors parsed from THEME_JSON.
class ThemeColors {
  final Color primary;
  final Color onPrimary;
  final Color background;
  final Color surface;
  final Color label;
  final Color body;
  final Color border;
  final Color error;

  const ThemeColors({
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

Color _parseColor(String? hex, String fallback) {
  var value = (hex ?? fallback).replaceAll('#', '');
  if (value.length == 6) value = 'FF$value';
  return Color(int.parse(value, radix: 16));
}

class ThemeLoader {
  static ThemeData loadTheme() {
    final ThemeColors colors = _loadColorsFromJson();
    return _buildTheme(colors);
  }

  static ThemeColors _defaultColors() {
    return ThemeColors(
      primary: _parseColor(null, '#16A34A'),
      onPrimary: _parseColor(null, '#FFFFFF'),
      background: _parseColor(null, '#FFFFFF'),
      surface: _parseColor(null, '#FFFFFF'),
      label: _parseColor(null, '#111827'),
      body: _parseColor(null, '#374151'),
      border: _parseColor(null, '#16A34A'),
      error: _parseColor(null, '#DC2626'),
    );
  }

  static ThemeColors _loadColorsFromJson() {
    // 1) جرّب تقرأ JSON عادي من THEME_JSON
    String raw = Env.themeJson.trim();

    // 2) إذا فاضي أو {} و في B64 → فكّ Base64
    if ((raw.isEmpty || raw == '{}') && Env.themeJsonB64.isNotEmpty) {
      try {
        raw = utf8.decode(base64Decode(Env.themeJsonB64));
      } catch (_) {
        raw = '';
      }
    }

    // 3) إذا بعدو فاضي → default
    if (raw.isEmpty || raw == '{}') {
      return _defaultColors();
    }

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;

      final Map<String, dynamic> colorsMap =
          (decoded['valuesMobile']?['colors'] as Map<String, dynamic>?) ??
          (decoded['colors'] as Map<String, dynamic>?) ??
          decoded;

      return ThemeColors(
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
    } catch (e) {
      // لو JSON معفّن → default
      return _defaultColors();
    }
  }

  static ThemeData _buildTheme(ThemeColors c) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: c.primary,
      primary: c.primary,
      onPrimary: c.onPrimary,
      secondary: c.primary,
      background: c.background,
      surface: c.surface,
      error: c.error,
      onSecondary: c.onPrimary,
      onBackground: c.body,
      onSurface: c.body,
      onError: c.onPrimary,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: c.background,
      appBarTheme: AppBarTheme(
        backgroundColor: c.surface,
        foregroundColor: c.label,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.primary,
          foregroundColor: c.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
