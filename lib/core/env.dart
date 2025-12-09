class Env {
  static const String apiBaseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: '');

  static const bool useBackendAuth =
      bool.fromEnvironment('USE_BACKEND_AUTH', defaultValue: false);
}
