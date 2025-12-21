import '../core/env.dart';

class ApiConfig {
  static String _joinBase(String base, String path) {
    if (path.isEmpty) return base;
    if (base.endsWith('/') && path.startsWith('/')) {
      return '$base${path.substring(1)}';
    }
    if (!base.endsWith('/') && !path.startsWith('/')) {
      return '$base/$path';
    }
    return '$base$path';
  }

  /// Base URL dengan path prefix (mis. /api atau /api/v1).
  static final String baseUrl =
      _joinBase(Env.apiBaseUrl, Env.apiPathPrefix);

  /// Base URL khusus auth (mis. /auth).
  static final String authBaseUrl =
      _joinBase(baseUrl, Env.authPathPrefix);

  static const String sendOtpEndpoint = "/send-otp";
  static const String verifyOtpEndpoint = "/verify-otp";
  static const String premiumChatEndpoint = "/ai/chat";
}
