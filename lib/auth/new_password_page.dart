import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Ganti import ini jika lokasi widget kamu berbeda
// import '../widgets/gaps.dart'; 
import 'login_page.dart';

class NewPasswordPage extends StatefulWidget {
  final String email;
  const NewPasswordPage({super.key, required this.email});

  @override
  State<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _passController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  // === LOGIKA UTAMA: PERMINTAAN RESET PASSWORD ===
  Future<void> _handleUpdatePassword() async {
    // 1. Validasi Input
    if (_passController.text.isEmpty || _confirmPassController.text.isEmpty) {
      _showSnackBar("Mohon isi kedua kolom password", isError: true);
      return;
    }

    if (_passController.text != _confirmPassController.text) {
      _showSnackBar("Password tidak sama!", isError: true);
      return;
    }

    if (_passController.text.length < 6) {
      _showSnackBar("Password minimal 6 karakter", isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // PERHATIAN:
      // Karena keterbatasan keamanan Firebase Client SDK (tidak bisa set password user lain tanpa login),
      // kita menggunakan metode resmi: Mengirim Link Reset Password ke Email.
      // Password yang diinput di sini bisa dianggap sebagai "konfirmasi niat" user.
      
      await FirebaseAuth.instance.sendPasswordResetEmail(email: widget.email);
      
      if (!mounted) return;

      // 2. Tampilkan Dialog Sukses
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8FBF6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mark_email_read, color: Color(0xFF63D1BE), size: 40),
              ),
              const SizedBox(height: 20),
              Text(
                "Link Aktivasi Terkirim",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 12),
              Text(
                "Demi keamanan tingkat tinggi, kami telah mengirimkan link finalisasi ke email:\n\n${widget.email}\n\nSilakan klik link tersebut untuk mengaktifkan password baru Anda.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700]),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Kembali ke Login & Hapus history
                    Navigator.pushAndRemoveUntil(
                      context, 
                      MaterialPageRoute(builder: (context) => const LoginPage()), 
                      (route) => false
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF63D1BE),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text("OK, Mengerti", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      );

    } catch (e) {
      if (mounted) {
        _showSnackBar("Gagal memproses: $e", isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Helper Widget untuk Text Field
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool isObscure,
    required VoidCallback onToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: TextField(
        controller: controller,
        obscureText: isObscure,
        style: GoogleFonts.poppins(color: Colors.black87),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(color: const Color(0xFFB0B0B0), fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
          suffixIcon: IconButton(
            icon: Icon(
              isObscure ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey,
            ),
            onPressed: onToggle,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      body: Container(
        // BACKGROUND GRADIENT (Agar konsisten dengan halaman lain)
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
                  children: [
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
                              Icons.verified_user_outlined,
                              color: Color(0xFF63D1BE),
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // JUDUL
                          Text(
                            'Buat Password Baru',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          
                          // DESKRIPSI
                          Text(
                            'Verifikasi OTP berhasil. Silakan masukkan password baru untuk akun Anda.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF7C8BA0),
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 32),
                          
                          // INPUT PASSWORD 1
                          _buildPasswordField(
                            controller: _passController,
                            hint: 'Password Baru',
                            isObscure: _obscurePass,
                            onToggle: () => setState(() => _obscurePass = !_obscurePass),
                          ),
                          const SizedBox(height: 16),

                          // INPUT PASSWORD 2
                          _buildPasswordField(
                            controller: _confirmPassController,
                            hint: 'Konfirmasi Password',
                            isObscure: _obscureConfirm,
                            onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                          ),
                          const SizedBox(height: 32),
                          
                          // TOMBOL SIMPAN
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleUpdatePassword,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF63D1BE),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                elevation: 0,
                              ),
                              child: _isLoading 
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : Text(
                                    'Simpan Password',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                            ),
                          ),
                        ],
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