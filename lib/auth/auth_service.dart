import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:joyin/config/api_config.dart';

class AuthService {
  final String _backendBaseUrl = ApiConfig.authBaseUrl;

  // This method will initiate the Google OAuth flow by launching a URL
  Future<void> signInWithGoogle() async {
    final redirectUri = 'joyin://oauth-callback';
    final googleAuthUrl =
        '$_backendBaseUrl/google?redirect_uri=$redirectUri';
    final uri = Uri.parse(googleAuthUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }

    throw 'Could not launch $googleAuthUrl';
  }

  // TODO: Implement signOut if needed for backend authentication
  Future<void> signOut() async {
    // For backend, you might need to call a logout endpoint
    // and clear local tokens (e.g., from SharedPreferences)
    debugPrint('Backend signOut not implemented yet.');
  }
}
