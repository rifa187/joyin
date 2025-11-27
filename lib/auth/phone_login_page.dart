import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';

class PhoneLoginPage extends StatefulWidget {
  const PhoneLoginPage({super.key});

  @override
  State<PhoneLoginPage> createState() => _PhoneLoginPageState();
}

class _PhoneLoginPageState extends State<PhoneLoginPage> {
  // Controller untuk input nomor dan OTP
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  bool _isLoading = false;
  bool _isCodeSent = false; // Penanda apakah kode sudah dikirim
  String? _verificationId; // Token rahasia dari Firebase

  // === FUNGSI 1: KIRIM KODE OTP ===
  void _verifyPhoneNumber() async {
    setState(() => _isLoading = true);

    String phoneNumber = _phoneController.text.trim();
    
    // Pastikan format nomor pakai +62. Jika user ketik 0812..., ubah jadi +62812...
    if (phoneNumber.startsWith('0')) {
      phoneNumber = "+62${phoneNumber.substring(1)}";
    }

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      
      // 1. Verifikasi Otomatis (Instan di Android)
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        if (mounted) _goToDashboard();
      },
      
      // 2. Jika Gagal (Misal: Kuota habis / Format salah)
      verificationFailed: (FirebaseAuthException e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal: ${e.message}"), backgroundColor: Colors.red),
        );
      },
      
      // 3. Jika Kode Terkirim (User diminta input OTP)
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
          _isCodeSent = true; // Tampilkan form OTP
          _isLoading = false;
        });
      },
      
      // 4. Timeout (Kode kadaluarsa)
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  // === FUNGSI 2: VERIFIKASI KODE YANG DIINPUT ===
  void _signInWithOTP() async {
    if (_verificationId == null || _otpController.text.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      // Gabungkan Kode OTP + ID Verifikasi
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _otpController.text,
      );

      // Login ke Firebase
      await _auth.signInWithCredential(credential);
      if (mounted) _goToDashboard();
      
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kode OTP Salah!"), backgroundColor: Colors.red),
      );
    }
  }

  void _goToDashboard() {
    // Hapus semua history halaman dan masuk ke Dashboard
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    // Style standar PinPut
    final defaultPinTheme = PinTheme(
      width: 56, height: 56,
      textStyle: const TextStyle(fontSize: 22, color: Colors.black, fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_isCodeSent ? "Verifikasi OTP" : "Login No. HP", style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // LOGO ATAU GAMBAR HEADER
            Icon(
              _isCodeSent ? Icons.lock_clock_outlined : Icons.phone_android_outlined,
              size: 80,
              color: const Color(0xFF4DB6AC), // Warna Joyin
            ),
            const SizedBox(height: 30),

            // === STATE 1: INPUT NOMOR HP ===
            if (!_isCodeSent) ...[
              Text("Masukkan Nomor HP Aktif", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text("Kami akan mengirimkan kode verifikasi via SMS.", textAlign: TextAlign.center, style: GoogleFonts.poppins(color: Colors.grey)),
              const SizedBox(height: 30),
              
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(fontSize: 18, letterSpacing: 1.2),
                decoration: InputDecoration(
                  labelText: "Nomor HP",
                  hintText: "Contoh: 08123456789",
                  prefixIcon: const Icon(Icons.call),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 30),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyPhoneNumber,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4DB6AC),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text("Kirim Kode", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ]

            // === STATE 2: INPUT KODE OTP ===
            else ...[
               Text("Masukkan Kode OTP", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text("Dikirim ke ${_phoneController.text}", style: GoogleFonts.poppins(color: Colors.grey)),
              const SizedBox(height: 30),

              Pinput(
                controller: _otpController,
                length: 6, // Kode Firebase biasanya 6 digit
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: defaultPinTheme.copyWith(
                  decoration: defaultPinTheme.decoration!.copyWith(border: Border.all(color: const Color(0xFF4DB6AC))),
                ),
                onCompleted: (val) => _signInWithOTP(),
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _signInWithOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4DB6AC),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text("Verifikasi", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              
              TextButton(
                onPressed: () {
                  setState(() {
                    _isCodeSent = false;
                    _otpController.clear();
                  });
                },
                child: const Text("Nomor Salah? Ganti Nomor"),
              )
            ]
          ],
        ),
      ),
    );
  }
}