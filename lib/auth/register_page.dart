import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// IMPORT FIREBASE & MODEL
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth; 
import 'package:joyin/auth/firebase_auth_service.dart'; 
import 'package:joyin/core/user_model.dart' as app_model; 
import 'package:joyin/providers/user_provider.dart';

// WIDGETS & CONFIG
import '../../widgets/buttons.dart';
import '../../widgets/misc.dart';
import '../../widgets/gaps.dart';
import 'forgot_password_page.dart';
import '../dashboard/dashboard_page.dart';
// import '../screens/pilih_paket_screen.dart'; // Tidak butuh ini lagi di sini
import '../core/app_colors.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Controllers
  final name = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final pass = TextEditingController();
  final pass2 = TextEditingController();
  
  bool agree = false;
  bool isLoading = false;

  // Visibility Toggles
  bool _obscurePass = true;
  bool _obscureConfirmPass = true;

  // Service Firebase
  final FirebaseAuthService _authService = FirebaseAuthService();

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    phone.dispose();
    pass.dispose();
    pass2.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // --- BAGIAN YANG DIPERBARUI (ALUR NAVIGASI) ---
  Future<void> _handleRegistrationSuccess(String uid, String userEmail, String userName) async {
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    // Kita tetap ambil statusnya (untuk keperluan data), tapi tidak dipakai untuk if-else navigasi
    final hasPurchased = prefs.getBool('has_purchased_package') ?? false;

    final newUser = app_model.User(
      uid: uid,
      email: userEmail,
      displayName: userName,
      phoneNumber: phone.text.trim(),
      hasPurchasedPackage: hasPurchased,
      photoUrl: null,
      dateOfBirth: null,
      packageDurationMonths: null,
    );

    Provider.of<UserProvider>(context, listen: false).setUser(newUser);

    if (!mounted) return;

    // PERUBAHAN DI SINI:
    // Langsung tembak ke DashboardPage, menghapus semua halaman login/register dari back stack
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const DashboardPage()),
      (route) => false, 
    );
  }

  Future<void> _signUp() async {
    if (!agree) {
      _showErrorSnackBar('Anda harus menyetujui syarat & kebijakan');
      return;
    }

    final nm = name.text.trim();
    final em = email.text.trim();
    final ph = phone.text.trim();
    final pw = pass.text;

    if (nm.isEmpty || em.isEmpty || ph.isEmpty || pw.isEmpty) {
      _showErrorSnackBar('Mohon lengkapi semua data');
      return;
    }

    if (pw != pass2.text) {
      _showErrorSnackBar('Konfirmasi password tidak sama');
      return;
    }

    setState(() => isLoading = true);

    try {
      firebase_auth.User? user = await _authService.signUpWithEmailAndData(
        email: em,
        password: pw,
        name: nm,
        phone: ph,
      );

      if (user != null) {
        if (!mounted) return;
        // Opsional: Tampilkan snackbar sukses sebentar atau langsung pindah
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pendaftaran Berhasil!'),
            backgroundColor: AppColors.success,
          ),
        );
        
        await _handleRegistrationSuccess(user.uid, em, nm);
      }

    } catch (e) {
      _showErrorSnackBar(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    _showErrorSnackBar('Fitur Google Login sedang dalam pengembangan UI.');
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool isPassword = false,
    bool? isObscure,
    VoidCallback? onToggleVisibility,
    TextInputType inputType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? (isObscure ?? true) : false,
      keyboardType: inputType,
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
                  (isObscure ?? true) ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.textSecondary,
                ),
                onPressed: onToggleVisibility,
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          SafeArea(
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
                      // HEADER
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.chevron_left),
                          color: AppColors.textPrimary,
                        ),
                      ),
                      gap(4),
                      
                      Text(
                        'Sign Up',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      gap(4),
                      Text(
                        'Buat akunmu',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(color: AppColors.textSecondary),
                      ),
                      gap(22),

                      // FORM INPUTS
                      _buildTextField(
                        controller: name, 
                        hint: 'Masukkan Nama Anda',
                        inputType: TextInputType.name
                      ),
                      gap(12),
                      _buildTextField(
                        controller: email, 
                        hint: 'Masukkan Alamat Email',
                        inputType: TextInputType.emailAddress
                      ),
                      gap(12),
                      _buildTextField(
                        controller: phone, 
                        hint: 'Masukkan Nomor Telepon',
                        inputType: TextInputType.phone
                      ),
                      gap(12),
                      
                      _buildTextField(
                        controller: pass, 
                        hint: 'Masukkan Password', 
                        isPassword: true,
                        isObscure: _obscurePass,
                        onToggleVisibility: () => setState(() => _obscurePass = !_obscurePass),
                      ),
                      gap(12),
                      
                      _buildTextField(
                        controller: pass2, 
                        hint: 'Konfirmasi Password', 
                        isPassword: true,
                        isObscure: _obscureConfirmPass,
                        onToggleVisibility: () => setState(() => _obscureConfirmPass = !_obscureConfirmPass),
                      ),
                      gap(12),

                      // Lupa Password
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
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                      ),
                      gap(8),

                      // Syarat & Kebijakan Checkbox
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 24,
                            width: 24,
                            child: Checkbox(
                              value: agree,
                              onChanged: (v) => setState(() => agree = v ?? false),
                              activeColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.border, width: 1.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: GoogleFonts.poppins(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                                children: [
                                  const TextSpan(text: 'Saya mengerti '),
                                  TextSpan(
                                    text: 'syarat & kebijakan',
                                    style: GoogleFonts.poppins(
                                      color: AppColors.secondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      gap(20),

                      // BUTTON DAFTAR
                      Container(
                        width: double.infinity,
                        height: 54,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: LinearGradient(
                            colors: agree 
                              ? [AppColors.grad1, AppColors.grad3] 
                              : [Colors.grey.shade300, Colors.grey.shade400],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: agree ? [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ] : [],
                        ),
                        child: ElevatedButton(
                          onPressed: (agree && !isLoading) ? _signUp : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            disabledBackgroundColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: Text(
                            'Daftar',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
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
                              color: AppColors.textSecondary,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Text(
                              'Login',
                              style: GoogleFonts.poppins(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      gap(20),
                    ],
                  ),
                ),
              ),
            ),
          ),

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