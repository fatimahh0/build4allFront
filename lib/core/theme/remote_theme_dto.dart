import 'dart:convert';

class RemoteThemeDto {
  final String? menuType;
  final Map<String, dynamic> valuesMobile;

  const RemoteThemeDto({required this.menuType, required this.valuesMobile});

  factory RemoteThemeDto.fromJson(Map<String, dynamic> json) {
    // ✅ Case 1: full schema (what your app expects)
    final vm = json['valuesMobile'];
    if (vm is Map<String, dynamic>) {
      return RemoteThemeDto(
        menuType: json['menuType'] as String?,
        valuesMobile: vm,
      );
    }

    // ✅ Case 2: flat schema (what CI/backend currently sends)
    // Example: { "primary":"#2563EB", "onPrimary":"#FFFFFF", ... }
    final hasFlatColors = json.containsKey('primary') ||
        json.containsKey('onPrimary') ||
        json.containsKey('background') ||
        json.containsKey('surface');

    if (hasFlatColors) {
      return RemoteThemeDto(
        menuType: json['menuType'] as String? ?? 'bottom',
        valuesMobile: {
          "colors": {
            "primary": json["primary"],
            "onPrimary": json["onPrimary"],
            "background": json["background"],
            "surface": json["surface"],
            "label": json["label"] ?? json["onBackground"],
            "body": json["body"] ?? json["onBackground"],
            "border": json["border"] ?? json["primary"],
            "error": json["error"],
            "danger": json["danger"] ?? json["error"],
            "muted": json["muted"],
            "success": json["success"],
          },
          // keep defaults for these unless backend provides them later
          "card": json["card"] ?? {},
          "search": json["search"] ?? {},
          "button": json["button"] ?? {},
        },
      );
    }

    // ✅ Unknown schema → empty (will fallback)
    return const RemoteThemeDto(menuType: null, valuesMobile: {});
  }

  factory RemoteThemeDto.fromBase64Json(String base64Str) {
    if (base64Str.trim().isEmpty) {
      return const RemoteThemeDto(menuType: null, valuesMobile: {});
    }
    final raw = utf8.decode(base64Decode(base64Str));
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return RemoteThemeDto.fromJson(decoded);
  }
}
