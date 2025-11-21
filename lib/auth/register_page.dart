import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// IMPORT FIREBASE & MODEL
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth; 
import 'package:joyin/auth/firebase_auth_service.dart'; 
import 'package:joyin/core/user_model.dart' as app_model; 
import 'package:joyin/providers/user_provider.dart';

// WIDGETS
import '../../widgets/buttons.dart';
import '../../widgets/fields.dart';
import '../../widgets/misc.dart';
import '../../widgets/gaps.dart';
import 'forgot_password_page.dart';
import '../dashboard/dashboard_page.dart';
import '../screens/pilih_paket_screen.dart';

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
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // --- FUNGSI INI YANG KITA PERBAIKI ---
  Future<void> _handleRegistrationSuccess(String uid, String userEmail, String userName) async {
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final hasPurchased = prefs.getBool('has_purchased_package') ?? false;

    // Membuat Object User Model (SUDAH DISESUAIKAN DENGAN FILE ANDA)
    final newUser = app_model.User(
      uid: uid,                         // Benar: pakai 'uid'
      email: userEmail,
      displayName: userName,            // Benar: pakai 'displayName'
      phoneNumber: phone.text.trim(),   // Benar: pakai 'phoneNumber'
      hasPurchasedPackage: hasPurchased,
      photoUrl: null,                   // Default null
      dateOfBirth: null,                // Default null
      packageDurationMonths: null,      // Default null
    );

    // Simpan ke Provider
    Provider.of<UserProvider>(context, listen: false).setUser(newUser);

    if (!mounted) return;

    // Navigasi
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

  Future<void> _signUp() async {
    // 1. Validasi
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

    // 2. Loading ON
    setState(() => isLoading = true);

    try {
      // 3. Panggil Service Firebase
      firebase_auth.User? user = await _authService.signUpWithEmailAndData(
        email: em,
        password: pw,
        name: nm,
        phone: ph,
      );

      if (user != null) {
        // 4. Sukses
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pendaftaran Berhasil!')),
        );
        
        // Update state aplikasi & pindah halaman
        await _handleRegistrationSuccess(user.uid, em, nm);
      }

    } catch (e) {
      // 5. Error
      _showErrorSnackBar(e.toString().replaceAll('Exception: ', ''));
    } finally {
      // 6. Loading OFF
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    // Logika Google Sign In akan dipanggil di sini nanti
    // await _authService.signInWithGoogle();
    _showErrorSnackBar('Fitur Google Login sedang dalam pengembangan UI.');
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
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
                            activeColor: const Color(0xFF63D1BE),
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
                        onPressed: (agree && !isLoading) ? _signUp : null,
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

          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF63D1BE),
                ),
              ),
            ),
        ],
      ),
    );
  }
}