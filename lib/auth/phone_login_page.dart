import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart'; // Pastikan sudah install package 'pinput'

class PhoneLoginPage extends StatefulWidget {
  const PhoneLoginPage({super.key});

  @override
  State<PhoneLoginPage> createState() => _PhoneLoginPageState();
}

class _PhoneLoginPageState extends State<PhoneLoginPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  bool _isLoading = false;
  bool _isCodeSent = false; // Untuk mengecek apakah OTP sudah dikirim
  String? _verificationId; // Token verifikasi dari Firebase

  // Fungsi 1: Mengirim Kode ke Nomor HP
  void _verifyPhoneNumber() async {
    setState(() => _isLoading = true);

    String phoneNumber = _phoneController.text.trim();
    // Pastikan format nomor diawali +62
    if (!phoneNumber.startsWith('+')) {
      phoneNumber = "+62${phoneNumber.startsWith('0') ? phoneNumber.substring(1) : phoneNumber}";
    }

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      
      // 1. Jika Android otomatis mendeteksi SMS (Login Instan)
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        if (mounted) {
           Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text("Login Otomatis Berhasil!")),
           );
        }
      },
      
      // 2. Jika Gagal (Biasanya karena SHA-1 belum diset atau kuota habis)
      verificationFailed: (FirebaseAuthException e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal: ${e.message}"), backgroundColor: Colors.red),
        );
      },
      
      // 3. Jika Kode Berhasil Dikirim (User harus input OTP)
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
          _isCodeSent = true; // Ubah tampilan ke Input OTP
          _isLoading = false;
        });
      },
      
      // 4. Timeout
      codeAutoRetrievalTimeout: (String verificationId) {
        // Biarkan kosong atau handle jika perlu
        _verificationId = verificationId;
      },
    );
  }

  // Fungsi 2: Verifikasi Kode OTP yang diinput User
  void _signInWithOTP() async {
    if (_verificationId == null || _otpController.text.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      // Membuat credential dari Kode OTP dan Verification ID
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _otpController.text,
      );

      // Login ke Firebase
      await _auth.signInWithCredential(credential);

      if (mounted) {
        // Sukses Login -> Pindah ke Dashboard
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kode OTP Salah!"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login No. HP")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // === BAGIAN 1: INPUT NOMOR HP (Muncul jika kode belum dikirim) ===
            if (!_isCodeSent) ...[
              Text(
                "Masukkan Nomor HP",
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  hintText: "Contoh: 08123456789",
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyPhoneNumber,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Kirim Kode", style: TextStyle(color: Colors.white)),
                ),
              ),
            ] 
            
            // === BAGIAN 2: INPUT OTP (Muncul setelah kode dikirim) ===
            else ...[
              Text(
                "Masukkan Kode OTP",
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Pinput(
                controller: _otpController,
                length: 6,
                onCompleted: (val) => _signInWithOTP(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _signInWithOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Verifikasi & Login", style: TextStyle(color: Colors.white)),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isCodeSent = false;
                    _otpController.clear();
                  });
                },
                child: const Text("Ganti Nomor"),
              )
            ]
          ],
        ),
      ),
    );
  }
}