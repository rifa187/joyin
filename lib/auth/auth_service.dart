import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthService {
  // TODO: Replace with your backend base URL
  final String _backendBaseUrl = 'http://localhost:3000'; 

  // This method will initiate the Google OAuth flow by launching a URL
  Future<void> signInWithGoogle() async {
    final String googleAuthUrl = '$_backendBaseUrl/google';
    if (await canLaunchUrl(Uri.parse(googleAuthUrl))) {
      await launchUrl(Uri.parse(googleAuthUrl), mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $googleAuthUrl';
    }
  }

  // TODO: Implement signOut if needed for backend authentication
  Future<void> signOut() async {
    // For backend, you might need to call a logout endpoint
    // and clear local tokens (e.g., from SharedPreferences)
    debugPrint('Backend signOut not implemented yet.');
  }
}