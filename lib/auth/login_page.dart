import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// IMPORT FIREBASE & SERVICE
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:joyin/auth/firebase_auth_service.dart';
import 'package:joyin/core/user_model.dart' as app_model;
import 'package:joyin/providers/user_provider.dart';

// WIDGETS & PAGES
// Catatan: RoundField kita ganti dengan _buildTextField lokal agar style warna baru langsung jalan
import '../../widgets/buttons.dart'; 
import '../../widgets/misc.dart';
import '../../widgets/gaps.dart';
import 'forgot_password_page.dart';
import 'register_page.dart';
import '../dashboard/dashboard_page.dart';
import '../core/app_colors.dart'; // Import AppColors yang baru

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final pass = TextEditingController();
  
  bool isLoading = false;
  bool _obscureText = true; // Untuk toggle hide/show password
  
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
        backgroundColor: AppColors.error, // Menggunakan warna Error dari AppColors
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
      firebase_auth.UserCredential credential = 
          await _authService.signInWithEmailAndPassword(
            email.text.trim(), 
            pass.text
          );

      if (credential.user != null) {
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
  Future<void> _fetchUserDataAndNavigate(String uid) async {
    try {
      final userData = await _authService.getUserData(uid);

      if (userData == null) {
        throw Exception("Data profil pengguna tidak ditemukan.");
      }

      final currentUser = app_model.User(
        uid: uid,
        email: userData['email'] ?? '',
        displayName: userData['name'] ?? 'No Name', 
        phoneNumber: userData['phone'] ?? '',
        hasPurchasedPackage: userData['hasPurchasedPackage'] ?? false,
        photoUrl: userData['photoUrl'], 
      );

      if (!mounted) return;
      Provider.of<UserProvider>(context, listen: false).setUser(currentUser);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_purchased_package', currentUser.hasPurchasedPackage);

      if (!mounted) return;
      
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const DashboardPage()),
        (route) => false,
      );

    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', '')); 
    }
  }

  // --- HELPER WIDGET UNTUK TEXT FIELD (AGAR WARNA KONSISTEN) ---
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? _obscureText : false,
      style: GoogleFonts.poppins(color: AppColors.textPrimary),
      cursorColor: AppColors.primary, // Kursor warna hijau
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.background, // Background abu-abu muda
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        
        // Border saat diam
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        
        // Border saat diklik (Fokus) -> Warna Primary
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),

        // Icon mata untuk password
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.textSecondary,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: AppColors.surface, // Menggunakan warna Surface (Putih)
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
                            color: AppColors.textPrimary,
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
                            color: AppColors.textPrimary, // Warna Teks Utama
                          ),
                        ),
                        gap(6),
                        Text(
                          'Masukkan email dan password untuk masuk',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: AppColors.textSecondary, // Warna Teks Sekunder
                          ),
                        ),
                        gap(26),

                        // INPUT EMAIL
                        _buildTextField(
                          controller: email, 
                          hint: 'Masukkan Alamat Email'
                        ),
                        gap(16),

                        // INPUT PASSWORD
                        _buildTextField(
                          controller: pass, 
                          hint: 'Masukkan Password Anda',
                          isPassword: true,
                        ),
                        gap(10),

                        // FORGOT PASSWORD
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
                                color: AppColors.secondary, // Hijau Tosca Gelap
                                fontWeight: FontWeight.w600,
                                fontSize: 12.5,
                              ),
                            ),
                          ),
                        ),
                        gap(8),

                        // --- TOMBOL MASUK DENGAN GRADIENT ---
                        Container(
                          width: double.infinity,
                          height: 54,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24), // Radius sesuai desain lama
                            gradient: const LinearGradient(
                              colors: [AppColors.grad1, AppColors.grad3], // Gradient Baru
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _signIn,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: isLoading 
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  'Masuk',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    fontSize: 16
                                  ),
                                ),
                          ),
                        ),
                        
                        gap(20),
                        DividerWithText(
                          text: 'atau',
                          // Pastikan DividerWithText support parameter warna jika ada, 
                          // atau biarkan default.
                        ),
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
                                color: AppColors.textSecondary,
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
                                  color: AppColors.secondary,
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

          // OVERLAY LOADING (Opsional, karena tombol sudah ada loadingnya)
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ),
        ],
      ),
    );
  }
}