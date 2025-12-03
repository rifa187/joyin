import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Ganti import ini jika lokasi widget fields/gaps kamu berbeda
import '../widgets/fields.dart';
import '../widgets/gaps.dart';

// IMPORT HALAMAN OTP
import 'otp_verification_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  // === LOGIKA UTAMA: KIRIM OTP RESET PASSWORD ===
  void _handleForgotPassword() {
    final email = emailController.text.trim();

    // 1. Validasi Email Kosong & Format
    if (email.isEmpty) {
      _showSnackBar('Email harus diisi', isError: true);
      return;
    }
    
    // Validasi format email sederhana
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      _showSnackBar('Format email tidak valid', isError: true);
      return;
    }

    // 2. Navigasi ke Halaman OTP
    // Kita kirim isRegister: false -> Agar OTP Page tahu ini mode Reset Password
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OtpVerificationPage(
          email: email,
          isRegister: false, // MODE RESET PASSWORD
        ),
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF63D1BE), Color(0xFFD6F28F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(28, 20, 28, 20 + bottomInset),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // TOMBOL BACK
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.chevron_left, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // KARTU PUTIH UTAMA
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 30,
                            offset: const Offset(0, 18),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // ICON GEMBOK
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: const BoxDecoration(
                              color: Color(0xFFE8FBF6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.lock_reset,
                              color: Color(0xFF63D1BE),
                              size: 30,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // JUDUL
                          Text(
                            'Lupa Password',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          
                          // DESKRIPSI
                          Text(
                            'Masukkan email akun Joyin Anda dan kami akan mengirimkan kode OTP untuk reset password.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF7C8BA0),
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // INPUT EMAIL
                          // PERBAIKAN DI SINI: Gunakan 'keyboardType' bukan 'inputType'
                          RoundField(
                            c: emailController,
                            hint: 'Masukkan Alamat Email',
                            keyboardType: TextInputType.emailAddress, // <--- FIXED
                            prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
                          ),
                          const SizedBox(height: 18),
                          
                          // TOMBOL KIRIM KODE
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _handleForgotPassword,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF63D1BE),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(22),
                                ),
                              ),
                              child: Text(
                                'Kirim Kode OTP',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          Text(
                            'Pastikan email aktif agar kami dapat mengirim kode verifikasi.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: const Color(0xFF8B8B8B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // TEXT BAWAH
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Kembali ke halaman sebelumnya',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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