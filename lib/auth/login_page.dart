import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joyin/auth/auth_service.dart';
import 'package:joyin/auth/backend_auth_service.dart';
import 'package:joyin/package/package_info.dart';
import 'package:joyin/screens/payment_screen.dart';
import 'package:provider/provider.dart';
import 'package:joyin/providers/user_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:joyin/core/user_model.dart';
import '../dashboard/dashboard_page.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:joyin/auth/firebase_auth_service.dart';
import 'package:joyin/auth/local_auth_service.dart'; // Import LocalAuthService
import '../widgets/buttons.dart';
import '../widgets/fields.dart';
import '../widgets/misc.dart';
import '../widgets/gaps.dart';
import '../screens/pilih_paket_screen.dart';
import 'register_page.dart';
import 'forgot_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.selectedPackage});
  final PackageInfo? selectedPackage;
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final pass = TextEditingController();

  // Services for Web
  final AuthService _authService = AuthService(); // Use for Google login (web)
  final BackendAuthService _backendAuthService =
      BackendAuthService(); // Use for email/pass (web)

  // Service for Android
  final FirebaseAuthService _firebaseAuthService =
      FirebaseAuthService(); // Use for Android Google login
  final LocalAuthService _localAuthService =
      LocalAuthService(); // Use for Android manual login

  @override
  void initState() {
    super.initState();
    _checkCurrentUserAndNavigate();
  }

  void _checkCurrentUserAndNavigate() {
    final firebaseUser = fb_auth.FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      // If user is already logged in, handle the success flow immediately.
      // Use a post-frame callback to safely navigate after the build phase.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final appUser = _convertFirebaseUserToAppUser(firebaseUser);
          _handleLoginSuccess(appUser);
        }
      });
    }
  }

  @override
  void dispose() {
    email.dispose();
    pass.dispose();
    super.dispose();
  }

  // Helper to convert Firebase User to App User model
  User _convertFirebaseUserToAppUser(fb_auth.User firebaseUser) {
    return User(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName,
      phoneNumber: firebaseUser.phoneNumber,
      dateOfBirth: null, // Firebase User doesn't directly provide birthDate
      hasPurchasedPackage: false,
    );
  }

  Future<void> _handleLoginSuccess(User user) async {
    if (!mounted) return;
    Provider.of<UserProvider>(context, listen: false).setUser(user);

    if (widget.selectedPackage != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => PaymentScreen(
            packageName: widget.selectedPackage!.name,
            packagePrice: widget.selectedPackage!.price,
            packageFeatures: widget.selectedPackage!.features,
          ),
        ),
      );
    } else {
      final prefs = await SharedPreferences.getInstance();
      final hasPurchased = prefs.getBool('has_purchased_package') ?? false;

      if (hasPurchased) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardPage()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const PilihPaketScreen()),
        );
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _login() async {
    final em = email.text.trim();
    final pw = pass.text;

    if (em.isEmpty || pw.isEmpty) {
      if (!mounted) return;
      _showErrorSnackBar('Email dan password harus diisi');
      return;
    }

    try {
      if (kIsWeb) {
        // Web Login using custom backend
        final user = await _backendAuthService.login(em, pw);
        if (user != null) {
          await _handleLoginSuccess(user);
        } else {
          if (!mounted) return;
          _showErrorSnackBar(
            'Gagal masuk. Email tidak ditemukan atau password salah.',
          );
        }
      } else if (Platform.isAndroid) {
        // Android Login using LocalAuthService
        final user = await _localAuthService.signIn(em, pw);
        if (user != null) {
          await _handleLoginSuccess(user);
        } else {
          if (!mounted) return;
          _showErrorSnackBar(
            'Gagal masuk. Email atau password salah.',
          );
        }
      } else {
        // Fallback for other platforms or if platform is not Android/Web
        _showErrorSnackBar('Login not supported on this platform.');
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _loginWithGoogle() async {
    try {
      if (kIsWeb) {
        // Web Google Login using custom backend
        await _authService.signInWithGoogle();
        // The actual login success will be handled by deep linking when the backend redirects.
        // For web, we might need to listen for auth state changes or a redirect.
        // For now, just show a success message or navigate if the backend handles it.
        _showErrorSnackBar(
            'Google login initiated. Please complete in browser.');
      } else if (Platform.isAndroid) {
        // Android Google Login using Firebase
        final userCredential = await _firebaseAuthService.signInWithGoogle();
        if (userCredential.user != null) {
          final appUser = _convertFirebaseUserToAppUser(userCredential.user!);
          await _handleLoginSuccess(appUser);
        }
      } else {
        // Fallback for other platforms
        _showErrorSnackBar('Google login not supported on this platform.');
      }
    } on fb_auth.FirebaseAuthException catch (e) {
      if (!mounted) return;
      _showErrorSnackBar(e.message ?? 'Firebase Google authentication error.');
    } catch (e) {
      _showErrorSnackBar('Terjadi kesalahan saat masuk dengan Google: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Back button, now part of the body
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    gap(20), // Add some space after the back button
                    Text(
                      'LOGIN',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    gap(6),
                    Text(
                      'Masukkan email dan password untuk masuk',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF8892A0),
                      ),
                    ),
                    gap(26),
                    RoundField(c: email, hint: 'Masukkan Alamat Email'),
                    gap(12),
                    RoundField(
                      c: pass,
                      hint: 'Masukkan Password Anda',
                      ob: true,
                    ),
                    gap(10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ForgotPasswordPage(),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        child: Text(
                          'Lupa Password?',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF20BFA2),
                            fontWeight: FontWeight.w600,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                    ),
                    gap(8),
                    ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF63D1BE),
                        foregroundColor: Colors.white,
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: Text(
                        'Masuk',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                      ),
                    ),
                    gap(20),
                    const DividerWithText(text: 'atau'),
                    gap(14),
                    GoogleButton(
                      label: 'Masuk dengan Google',
                      onTap: _loginWithGoogle,
                    ),
                    gap(20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Belum punya akun? ",
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF8B8B8B),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => RegisterPage(
                                selectedPackage: widget.selectedPackage,
                              ),
                            ),
                          ),
                          child: Text(
                            'Daftar',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF20BFA2),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

