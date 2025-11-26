import 'dart:convert';

class RemoteThemeDto {
  final String? menuType;
  final Map<String, dynamic> valuesMobile;

  const RemoteThemeDto({required this.menuType, required this.valuesMobile});

  factory RemoteThemeDto.fromJson(Map<String, dynamic> json) {
    return RemoteThemeDto(
      menuType: json['menuType'] as String?,
      valuesMobile:
          (json['valuesMobile'] as Map<String, dynamic>?) ??
          <String, dynamic>{},
    );
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
