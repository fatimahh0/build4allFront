class Env {
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080',
  );

  static const wsPath = String.fromEnvironment(
    'WS_PATH',
    defaultValue: '/api/ws',
  );

  /// "user" / "business" / "both"  (used by backend filters sometimes)
  static const appRole = String.fromEnvironment(
    'APP_ROLE',
    defaultValue: 'both',
  );

  /// How to send ownerProjectLinkId to backend:
  /// "header" | "query" | "body" | "off"
  static const ownerAttachMode = String.fromEnvironment(
    'OWNER_ATTACH_MODE',
    defaultValue: 'header',
  );

  static const ownerProjectLinkId = String.fromEnvironment(
    'OWNER_PROJECT_LINK_ID',
    defaultValue: '1',
  );

  static const projectId = String.fromEnvironment(
    'PROJECT_ID',
    defaultValue: '0',
  );

  static const appName = String.fromEnvironment(
    'APP_NAME',
    defaultValue: 'Build4All App',
  );

  static const appLogoUrl = String.fromEnvironment(
    'APP_LOGO_URL',
    defaultValue: '',
  );

  static const themeJson = String.fromEnvironment(
    'THEME_JSON',
    defaultValue: '{}',
  );

  static const navJson = String.fromEnvironment('NAV_JSON', defaultValue: '[]');

  static const enabledFeaturesJson = String.fromEnvironment(
    'ENABLED_FEATURES_JSON',
    defaultValue: '[]',
  );

  static const appType = String.fromEnvironment(
    'APP_TYPE',
    defaultValue: 'ACTIVITIES',
  );

  static const themeId = String.fromEnvironment('THEME_ID', defaultValue: '0');

  static const themeJsonB64 = String.fromEnvironment(
    'THEME_JSON_B64',
    defaultValue: '',
  );

  static const navJsonB64 = String.fromEnvironment(
    'NAV_JSON_B64',
    defaultValue: '',
  );

  static const enabledFeaturesJsonB64 = String.fromEnvironment(
    'ENABLED_FEATURES_JSON_B64',
    defaultValue: '',
  );

  /// 🆕 Home layout config as Base64 JSON string
  static const homeJsonB64 = String.fromEnvironment(
    'HOME_JSON_B64',
    defaultValue: '',
  );
}
