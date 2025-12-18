class Env {
  static const String apiBaseUrl =
      String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  /// Optional path prefix for all APIs (e.g. /api or /api/v1).
  static const String apiPathPrefix =
      String.fromEnvironment('API_PATH_PREFIX', defaultValue: '/api');

  /// Optional auth router prefix (e.g. /auth).
  static const String authPathPrefix =
      String.fromEnvironment('AUTH_PATH_PREFIX', defaultValue: '/auth');

  static const bool useBackendAuth =
      bool.fromEnvironment('USE_BACKEND_AUTH', defaultValue: false);
}
