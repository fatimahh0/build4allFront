import 'package:flutter/material.dart';
import 'app_theme_tokens.dart';

class AppThemeBuilder {
  static ThemeData build(AppThemeTokens tokens) {
    final c = tokens.colors;
    final b = tokens.button;
    final card = tokens.card;
    final text = tokens.typography;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: c.primary,
      primary: c.primary,
      onPrimary: c.onPrimary,
      background: c.background,
      surface: c.surface,
      error: c.error,
      secondary: c.primary,
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

      textTheme: TextTheme(
        headlineSmall: text.headlineSmall,
        titleMedium: text.titleMedium,
        bodyMedium: text.bodyMedium,
        bodySmall: text.bodySmall,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.primary,
          foregroundColor: c.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(b.radius),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(card.radius),
          borderSide: BorderSide(color: c.border.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(card.radius),
          borderSide: BorderSide(color: c.border.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(card.radius),
          borderSide: BorderSide(color: c.primary, width: 1.4),
        ),
      ),
    );
  }
}
