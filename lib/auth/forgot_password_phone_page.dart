import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';

class ForgotPasswordPhonePage extends StatefulWidget {
  const ForgotPasswordPhonePage({super.key});

  @override
  State<ForgotPasswordPhonePage> createState() => _ForgotPasswordPhonePageState();
}

class _ForgotPasswordPhonePageState extends State<ForgotPasswordPhonePage> {
  // === CONTROLLERS ===
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();

  // === FIREBASE ===
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // === STATE MANAGEMENT ===
  // 0: Input HP, 1: Input OTP, 2: Input Password Baru
  int _currentState = 0; 
  bool _isLoading = false;
  String? _verificationId;

  // === LOGIC 1: KIRIM OTP ===
  void _sendOtp() async {
    setState(() => _isLoading = true);
    String phone = _phoneController.text.trim();
    
    // Format nomor HP (+62)
    if (phone.startsWith('0')) {
      phone = "+62${phone.substring(1)}";
    }

    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (credential) async {
        // Android: Otomatis verifikasi
        await _auth.signInWithCredential(credential);
        if (mounted) {
          setState(() {
            _isLoading = false;
            _currentState = 2; // Langsung ke Ubah Password
          });
        }
      },
      verificationFailed: (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: ${e.message}")));
      },
      codeSent: (verificationId, resendToken) {
        setState(() {
          _verificationId = verificationId;
          _currentState = 1; // Pindah ke layar OTP
          _isLoading = false;
        });
      },
      codeAutoRetrievalTimeout: (verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  // === LOGIC 2: VERIFIKASI OTP ===
  void _verifyOtp() async {
    if (_verificationId == null) return;
    setState(() => _isLoading = true);

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _otpController.text,
      );

      // Kita login-kan user sementara untuk memverifikasi identitas
      await _auth.signInWithCredential(credential);
      
      // Jika berhasil login, berarti nomor HP benar milik dia
      setState(() {
        _currentState = 2; // Pindah ke layar Password Baru
        _isLoading = false;
      });

    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Kode OTP Salah!")));
    }
  }

  // === LOGIC 3: UPDATE PASSWORD ===
  void _updatePassword() async {
    if (_newPasswordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password minimal 6 karakter")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Update password user yang sedang login
        await user.updatePassword(_newPasswordController.text);
        
        if (mounted) {
          // Sukses! Kembali ke Login atau Dashboard
          Navigator.of(context).pop(); // Tutup halaman Forgot Pass
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Password Berhasil Diubah! Silakan Login."), backgroundColor: Colors.green)
          );
        }
      }
    } catch (e) {
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal update: ${e.toString()}")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Styling Pinput
    final defaultPinTheme = PinTheme(
      width: 56, height: 56,
      textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
    );

    return Scaffold(
      // Background Gradient Hijau seperti gambar
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4DB6AC), Color(0xFF81C784)], // Sesuaikan warna Joyin
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 60),
              // Tombol Back
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // === CARD PUTIH ===
              Container(
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(30),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))
                  ],
                ),
                child: Column(
                  children: [
                    // Ikon Lingkaran
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2F1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _currentState == 0 ? Icons.phone_android : 
                        _currentState == 1 ? Icons.lock_clock : Icons.key,
                        size: 40,
                        color: const Color(0xFF4DB6AC),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Judul & Deskripsi Dinamis
                    Text(
                      _currentState == 0 ? "Lupa Password?" : 
                      _currentState == 1 ? "Verifikasi OTP" : "Password Baru",
                      style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _currentState == 0 ? "Masukkan nomor HP Anda untuk mereset password." :
                      _currentState == 1 ? "Masukkan kode 6 digit yang dikirim ke ${_phoneController.text}" :
                      "Silakan buat password baru untuk akun Anda.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 30),

                    // === FORM INPUT SESUAI STATE ===
                    if (_currentState == 0) ...[
                      // INPUT NO HP
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: "Contoh: 08123456789",
                          prefixIcon: const Icon(Icons.phone_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                      ),
                    ] else if (_currentState == 1) ...[
                      // INPUT OTP
                      Pinput(
                        controller: _otpController,
                        length: 6,
                        defaultPinTheme: defaultPinTheme,
                        focusedPinTheme: defaultPinTheme.copyWith(
                          decoration: defaultPinTheme.decoration!.copyWith(
                            border: Border.all(color: const Color(0xFF4DB6AC)),
                          ),
                        ),
                        onCompleted: (val) => _verifyOtp(),
                      ),
                    ] else ...[
                      // INPUT PASSWORD BARU
                      TextField(
                        controller: _newPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: "Password Baru",
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                      ),
                    ],

                    const SizedBox(height: 30),

                    // === TOMBOL AKSI ===
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : () {
                          if (_currentState == 0) _sendOtp();
                          else if (_currentState == 1) _verifyOtp();
                          else _updatePassword();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4DB6AC), // Hijau Tosca
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 5,
                          shadowColor: const Color(0xFF4DB6AC).withOpacity(0.4),
                        ),
                        child: _isLoading
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text(
                                _currentState == 0 ? "Kirim Kode" : 
                                _currentState == 1 ? "Verifikasi" : "Simpan Password",
                                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                      ),
                    ),
                    
                    if (_currentState == 1)
                      TextButton(
                        onPressed: () => setState(() => _currentState = 0),
                        child: const Text("Ganti Nomor HP", style: TextStyle(color: Colors.grey)),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}