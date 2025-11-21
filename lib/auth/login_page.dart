import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// PERHATIKAN: Kita SUDAH TIDAK BUTUH import 'cloud_firestore' di sini!
// UI jadi lebih ringan dan bersih.

// IMPORT FIREBASE & SERVICE
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:joyin/auth/firebase_auth_service.dart';
import 'package:joyin/core/user_model.dart' as app_model;
import 'package:joyin/providers/user_provider.dart';

// WIDGETS & PAGES
import '../../widgets/buttons.dart';
import '../../widgets/fields.dart';
import '../../widgets/misc.dart';
import '../../widgets/gaps.dart';
import 'forgot_password_page.dart';
import 'register_page.dart';
import '../dashboard/dashboard_page.dart';
import '../core/app_colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final pass = TextEditingController();
  
  bool isLoading = false;
  
  // Panggil Service Firebase
  final FirebaseAuthService _authService = FirebaseAuthService();

  @override
  void dispose() {
    email.dispose();
    pass.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // --- FUNGSI LOGIN MANUAL ---
  Future<void> _signIn() async {
    if (email.text.trim().isEmpty || pass.text.isEmpty) {
      _showErrorSnackBar('Mohon isi Email dan Password');
      return;
    }

    setState(() => isLoading = true);

    try {
      // 1. Login ke Auth
      firebase_auth.UserCredential credential = 
          await _authService.signInWithEmailAndPassword(
            email.text.trim(), 
            pass.text
          );

      if (credential.user != null) {
        // 2. Ambil Data Profil (Sekarang kodenya lebih pendek)
        await _fetchUserDataAndNavigate(credential.user!.uid);
      }

    } catch (e) {
      _showErrorSnackBar(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // --- FUNGSI LOGIN GOOGLE ---
  Future<void> _signInWithGoogle() async {
     setState(() => isLoading = true);
     try {
       firebase_auth.UserCredential credential = await _authService.signInWithGoogle();
       if (credential.user != null) {
         await _fetchUserDataAndNavigate(credential.user!.uid);
       }
     } catch (e) {
       _showErrorSnackBar(e.toString().replaceAll('Exception: ', ''));
     } finally {
       if (mounted) setState(() => isLoading = false);
     }
  }

  // --- LOGIKA MAPPING DATA & NAVIGASI ---
  // (Sekarang fungsi ini tidak menyentuh Firestore langsung)
  Future<void> _fetchUserDataAndNavigate(String uid) async {
    try {
      // A. Panggil Service untuk minta data (Clean!)
      final userData = await _authService.getUserData(uid);

      if (userData == null) {
        throw Exception("Data profil pengguna tidak ditemukan.");
      }

      // B. Masukkan ke dalam User Model Aplikasi
      final currentUser = app_model.User(
        uid: uid,
        email: userData['email'] ?? '',
        displayName: userData['name'] ?? 'No Name', 
        phoneNumber: userData['phone'] ?? '',
        hasPurchasedPackage: userData['hasPurchasedPackage'] ?? false,
        photoUrl: userData['photoUrl'], 
      );

      // C. Simpan ke Provider & SharedPrefs
      if (!mounted) return;
      Provider.of<UserProvider>(context, listen: false).setUser(currentUser);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_purchased_package', currentUser.hasPurchasedPackage);

      // D. Navigasi
      if (!mounted) return;
      
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const DashboardPage()),
        (route) => false,
      );

    } catch (e) {
      // Lempar error lagi biar ditangkap oleh _signIn
      throw Exception(e.toString().replaceAll('Exception: ', '')); 
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(28, 20, 28, 20 + bottomInset),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: IconButton(
                            icon: const Icon(Icons.chevron_left),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                        gap(20),

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
                        RoundField(c: pass, hint: 'Masukkan Password Anda', ob: true),
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
                          onPressed: isLoading ? null : _signIn,
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
                          onTap: _signInWithGoogle,
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
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const RegisterPage(),
                                  ),
                                );
                              },
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

          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFF63D1BE)),
              ),
            ),
        ],
      ),
    );
  }
}