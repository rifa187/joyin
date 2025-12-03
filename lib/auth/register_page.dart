import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// IMPORT PROVIDER
import '../providers/auth_provider.dart';

// WIDGETS & CONFIG
import '../../widgets/buttons.dart';
import '../../widgets/misc.dart';
import '../../widgets/gaps.dart';
import '../core/app_colors.dart';

// IMPORT HALAMAN OTP
import 'otp_verification_page.dart';

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
  
  // Visibility Toggles
  bool _obscurePass = true;
  bool _obscureConfirmPass = true;

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    phone.dispose();
    pass.dispose();
    pass2.dispose();
    super.dispose();
  }

  // === LOGIKA BARU: MENUJU OTP ===
  void _handleRegister() {
    // 1. Validasi Form Dasar
    if (name.text.isEmpty || email.text.isEmpty || phone.text.isEmpty || pass.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon lengkapi semua data'), backgroundColor: AppColors.error),
      );
      return;
    }
    
    // Validasi Password Sama
    if (pass.text != pass2.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password tidak sama'), backgroundColor: AppColors.error),
      );
      return;
    }

    // Validasi Checkbox
    if (!agree) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda harus menyetujui syarat & ketentuan'), backgroundColor: AppColors.error),
      );
      return;
    }

    // 2. NAVIGASI KE OTP (PERBAIKAN DI SINI)
    // Kita harus membawa SEMUA data (Nama, Email, Password, DAN NO HP) ke halaman sebelah.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OtpVerificationPage(
          email: email.text.trim(),
          isRegister: true,           
          name: name.text.trim(),     
          password: pass.text,  
          // TAMBAHAN PENTING: Kirim No HP agar bisa disimpan ke database nanti      
          phoneNumber: phone.text.trim(), 
        ),
      ),
    );
  }

  // Helper TextField (UI Tetap Sama)
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
    // Dengarkan perubahan loading dari Provider
    final authProvider = Provider.of<AuthProvider>(context);
    final isLoading = authProvider.isLoading;
    
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
                        'Buat akunmu (Gratis)',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(color: AppColors.textSecondary),
                      ),
                      gap(22),

                      // FORM INPUTS
                      _buildTextField(controller: name, hint: 'Masukkan Nama Anda', inputType: TextInputType.name),
                      gap(12),
                      _buildTextField(controller: email, hint: 'Masukkan Alamat Email', inputType: TextInputType.emailAddress),
                      gap(12),
                      _buildTextField(controller: phone, hint: 'Masukkan Nomor Telepon', inputType: TextInputType.phone),
                      gap(12),
                      
                      _buildTextField(
                        controller: pass, hint: 'Masukkan Password', 
                        isPassword: true, isObscure: _obscurePass,
                        onToggleVisibility: () => setState(() => _obscurePass = !_obscurePass),
                      ),
                      gap(12),
                      
                      _buildTextField(
                        controller: pass2, hint: 'Konfirmasi Password', 
                        isPassword: true, isObscure: _obscureConfirmPass,
                        onToggleVisibility: () => setState(() => _obscureConfirmPass = !_obscureConfirmPass),
                      ),
                      gap(12),

                      // Syarat & Kebijakan Checkbox
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 24, width: 24,
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
                                style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 13),
                                children: [
                                  const TextSpan(text: 'Saya mengerti '),
                                  TextSpan(
                                    text: 'syarat & kebijakan',
                                    style: GoogleFonts.poppins(color: AppColors.secondary, fontWeight: FontWeight.w600),
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
                            BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
                          ] : [],
                        ),
                        child: ElevatedButton(
                          onPressed: (agree && !isLoading) 
                            ? _handleRegister 
                            : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            disabledBackgroundColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          ),
                          child: isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text('Daftar Sekarang', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.white)),
                        ),
                      ),
                      
                      gap(18),
                      const DividerWithText(text: 'atau'),
                      gap(14),

                      GoogleButton(
                        label: 'Masuk dengan Google',
                        onTap: () => authProvider.signInWithGoogle(context),
                      ),
                      gap(20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Sudah punya akun? ", style: GoogleFonts.poppins(color: AppColors.textSecondary)),
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Text('Login', style: GoogleFonts.poppins(color: AppColors.secondary, fontWeight: FontWeight.w600)),
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

          // Overlay Loading Global
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.1),
              child: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
            ),
        ],
      ),
    );
  }
}