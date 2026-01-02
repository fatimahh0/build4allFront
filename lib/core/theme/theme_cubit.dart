import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../config/env.dart';
import 'remote_theme_dto.dart';
import 'app_theme_tokens.dart';
import 'app_theme_builder.dart';

class ThemeState {
  final ThemeData themeData;
  final AppThemeTokens tokens;
  final bool isLoaded;

  const ThemeState({
    required this.themeData,
    required this.tokens,
    required this.isLoaded,
  });

  ThemeState copyWith({
    ThemeData? themeData,
    AppThemeTokens? tokens,
    bool? isLoaded,
  }) {
    return ThemeState(
      themeData: themeData ?? this.themeData,
      tokens: tokens ?? this.tokens,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }

  factory ThemeState.initial() {
    final tokens = AppThemeTokens.fallback();
    return ThemeState(
      themeData: AppThemeBuilder.build(tokens),
      tokens: tokens,
      isLoaded: false,
    );
  }
}

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(ThemeState.initial()) {
    loadFromEnv();
  }

  void loadFromEnv() {
    try {
      if (Env.themeJsonB64.isEmpty) {
        emit(state.copyWith(isLoaded: true));
        return;
      }

      final remote = RemoteThemeDto.fromBase64Json(Env.themeJsonB64);
      final tokens = AppThemeTokens.fromRemote(remote);
      final themeData = AppThemeBuilder.build(tokens);

      emit(ThemeState(themeData: themeData, tokens: tokens, isLoaded: true));
    } catch (e) {
      // so you don't go insane next time
      // ignore: avoid_print
      print("Theme load failed: $e");
      emit(state.copyWith(isLoaded: true));
    }
  }
}
