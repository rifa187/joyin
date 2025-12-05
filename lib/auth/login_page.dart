import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// IMPORT PROVIDER BARU
import '../providers/auth_provider.dart';

// WIDGETS & PAGES
import '../../widgets/buttons.dart';
import '../../widgets/misc.dart';
import '../../widgets/gaps.dart';
import 'dart:math' as math;
import 'forgot_password_page.dart';
import 'register_page.dart';
import '../core/app_colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final email = TextEditingController();
  final pass = TextEditingController();
  bool _obscureText = true;
  late final AnimationController _loaderController;

  @override
  void dispose() {
    _loaderController.dispose();
    email.dispose();
    pass.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loaderController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  // Helper Widget TextField (TETAP SAMA SEPERTI KODE KAMU)
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? _obscureText : false,
      style: GoogleFonts.poppins(color: AppColors.textPrimary),
      cursorColor: AppColors.primary,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.textSecondary,
                ),
                onPressed: () => setState(() => _obscureText = !_obscureText),
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Panggil AuthProvider (Si Otak)
    final authProvider = Provider.of<AuthProvider>(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: AppColors.surface,
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
                            color: AppColors.textPrimary,
                          ),
                        ),
                        gap(6),
                        Text(
                          'Masukkan email dan password untuk masuk',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        gap(26),

                        // INPUT EMAIL
                        _buildTextField(controller: email, hint: 'Masukkan Alamat Email'),
                        gap(16),

                        // INPUT PASSWORD
                        _buildTextField(controller: pass, hint: 'Masukkan Password Anda', isPassword: true),
                        gap(10),

                        // FORGOT PASSWORD
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const ForgotPasswordPage()),
                              );
                            },
                            style: TextButton.styleFrom(padding: EdgeInsets.zero),
                            child: Text(
                              'Lupa Password?',
                              style: GoogleFonts.poppins(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.w600,
                                fontSize: 12.5,
                              ),
                            ),
                          ),
                        ),
                        gap(8),

                        // TOMBOL MASUK
                        Container(
                          width: double.infinity,
                          height: 54,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: const LinearGradient(
                              colors: [AppColors.grad1, AppColors.grad3],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withAlpha((255 * 0.3).round()),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            // 2. LOGIKA DI PINDAH KE SINI
                            // Cek status loading dari Provider
                            onPressed: authProvider.isLoading 
                              ? null 
                              : () {
                                  // Validasi UI sederhana boleh tetap disini
                                  if (email.text.trim().isEmpty || pass.text.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Mohon isi Email dan Password'), backgroundColor: AppColors.error),
                                    );
                                    return;
                                  }
                                  // Panggil fungsi di Provider
                                  authProvider.signIn(email.text.trim(), pass.text, context);
                                },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            ),
                            child: authProvider.isLoading
                                ? _joyLoader(size: 26, stroke: 4)
                                : Text(
                                    'Masuk',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                        ),
                        
                        gap(20),
                        const DividerWithText(text: 'atau'),
                        gap(14),

                        GoogleButton(
                          label: 'Masuk dengan Google',
                          // 3. Panggil fungsi Google Sign In Provider
                          onTap: () => authProvider.signInWithGoogle(context),
                        ),

                        gap(20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Belum punya akun? ",
                              style: GoogleFonts.poppins(color: AppColors.textSecondary),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const RegisterPage()),
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
          
          // Overlay Loading (Optional, karena tombol sudah loading)
          if (authProvider.isLoading)
            Container(
              color: Colors.black.withOpacity(0.55),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 26),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _joyLoader(size: 58, stroke: 8),
                      gap(18),
                      Text(
                        'Masuk ke akun...',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _joyLoader({double size = 32, double stroke = 6}) {
    return AnimatedBuilder(
      animation: _loaderController,
      builder: (context, child) {
        final angle = _loaderController.value * 2 * math.pi;
        return Transform.rotate(
          angle: angle,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const SweepGradient(
                colors: [
                  AppColors.grad1,
                  AppColors.grad3,
                  AppColors.grad1,
                ],
                stops: [0.0, 0.65, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withAlpha((255 * 0.25).round()),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: size - stroke * 2,
                height: size - stroke * 2,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
