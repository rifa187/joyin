import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:joyin/auth/backend_auth_service.dart';
import 'package:joyin/core/user_model.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:joyin/auth/local_auth_service.dart';


import '../../widgets/buttons.dart';
import '../../widgets/fields.dart';
import '../../widgets/misc.dart';
import '../../widgets/gaps.dart';
import 'forgot_password_page.dart';
import '../dashboard/dashboard_page.dart';
import '../screens/pilih_paket_screen.dart';
import 'package:joyin/providers/user_provider.dart';


class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final name = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController(); // hanya UI
  final pass = TextEditingController();
  final pass2 = TextEditingController();
  bool agree = false;
  final BackendAuthService _backendAuthService = BackendAuthService();
  final LocalAuthService _localAuthService = LocalAuthService();


  @override
  void dispose() {
    name.dispose();
    email.dispose();
    phone.dispose();
    pass.dispose();
    pass2.dispose();
    super.dispose();
  }

  Future<void> _handleRegistrationSuccess(User user) async {
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final hasPurchased = prefs.getBool('has_purchased_package') ?? false;

    final updatedUser = user.copyWith(hasPurchasedPackage: hasPurchased);
    if (!mounted) return;
    Provider.of<UserProvider>(context, listen: false).setUser(updatedUser);

    if (!mounted) return;

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

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _signUp() async {
    if (!agree) {
      if (!mounted) return;
      _showErrorSnackBar('Anda harus menyetujui syarat & kebijakan');
      return;
    }

    final nm = name.text.trim();
    final em = email.text.trim();
    final ph = phone.text.trim();
    final pw = pass.text;

    if (nm.isEmpty || em.isEmpty || ph.isEmpty || pw.isEmpty || pw != pass2.text) {
      if (!mounted) return;
      _showErrorSnackBar('Lengkapi semua data & pastikan password sama');
      return;
    }

    // TODO: Integrate birthDate input into the UI
    final dummyBirthDate = DateTime(2000, 1, 1); // Placeholder for now

    try {
      if (kIsWeb) {
        final message = await _backendAuthService.register(
          email: em,
          password: pw,
          name: nm,
          phone: ph,
          birthDate: dummyBirthDate,
          // referralCode: 'optional_referral_code', // Uncomment and provide if needed
        );

        if (!mounted) return;
        _showErrorSnackBar(message);
        // Assuming successful registration leads to login page or verification page
        Navigator.of(context).pop(); // Go back to login page
      } else if (Platform.isAndroid) {
        final user = await _localAuthService.signUp(
          em,
          pw,
          displayName: nm,
          phoneNumber: ph,
        );
        if (user != null) {
          await _handleRegistrationSuccess(user);
        } else {
          _showErrorSnackBar('Pendaftaran lokal gagal.');
        }
      } else {
        _showErrorSnackBar('Registration not supported on this platform.');
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      if (kIsWeb) {
        _showErrorSnackBar('Google login for registration via custom backend not fully implemented.');
      }
      else if (Platform.isAndroid) {
        _showErrorSnackBar('Google registration tidak didukung untuk akun lokal.');
      }
      else {
        _showErrorSnackBar('Google registration not supported on this platform.');
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(28, 18, 28, 18 + bottomInset),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.chevron_left),
                    ),
                  ),
                  gap(4),
                  Text(
                    'Sign Up',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  gap(4),
                  Text(
                    'Buat akunmu',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(color: const Color(0xFF8892A0)),
                  ),
                  gap(22),
                  RoundField(c: name, hint: 'Masukkan Nama Anda'),
                  gap(12),
                  RoundField(c: email, hint: 'Masukkan Alamat Email'),
                  gap(12),
                  RoundField(c: phone, hint: 'Masukkan Nomor Telepon'),
                  gap(12),
                  RoundField(c: pass, hint: 'Masukkan Password', ob: true),
                  gap(12),
                  RoundField(c: pass2, hint: 'Konfirmasi Password', ob: true),
                  gap(12),
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: agree,
                        onChanged: (v) => setState(() => agree = v ?? false),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF8B8B8B),
                            ),
                            children: [
                              const TextSpan(text: 'Saya mengerti '),
                              TextSpan(
                                text: 'syarat & kebijakan',
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF20BFA2),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  gap(6),
                  ElevatedButton(
                    onPressed: agree ? _signUp : null,
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
                      'Daftar',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                    ),
                  ),
                  gap(18),
                  const DividerWithText(text: 'atau'),
                  gap(14),
                  GoogleButton(
                    label: 'Masuk dengan Google',
                    onTap: _signInWithGoogle,
                  ),
                  gap(20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Sudah punya akun? ",
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF8B8B8B),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Text(
                          'Login',
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
    );
  }
}
