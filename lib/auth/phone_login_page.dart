import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import '../services/auth_service.dart';

class PhoneLoginPage extends StatefulWidget {
  const PhoneLoginPage({super.key});

  @override
  State<PhoneLoginPage> createState() => _PhoneLoginPageState();
}

class _PhoneLoginPageState extends State<PhoneLoginPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _isCodeSent = false;

  // Fungsi 1: Mengirim Kode ke Nomor HP (via Backend)
  void _sendOtp() async {
    setState(() => _isLoading = true);

    String phoneNumber = _phoneController.text.trim();
    // Pastikan format nomor diawali +62 atau sesuai format backend
    if (!phoneNumber.startsWith('+')) {
      phoneNumber =
          "+62${phoneNumber.startsWith('0') ? phoneNumber.substring(1) : phoneNumber}";
    }

    try {
      final success = await _authService.sendOtp(phoneNumber);
      if (success) {
        setState(() {
          _isCodeSent = true;
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Kode OTP berhasil dikirim!")),
          );
        }
      } else {
        throw Exception("Gagal mengirim kode.");
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Error: ${e.toString()}"),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  // Fungsi 2: Verifikasi Kode OTP (via Backend)
  void _verifyOtp() async {
    if (_otpController.text.isEmpty) return;

    setState(() => _isLoading = true);

    String phoneNumber = _phoneController.text.trim();
    if (!phoneNumber.startsWith('+')) {
      phoneNumber =
          "+62${phoneNumber.startsWith('0') ? phoneNumber.substring(1) : phoneNumber}";
    }

    try {
      final success =
          await _authService.verifyOtp(phoneNumber, _otpController.text);

      if (success) {
        if (mounted) {
          // Sukses Login -> Pindah ke Dashboard
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Login Berhasil!")),
          );
        }
      } else {
        throw Exception("OTP Salah atau Invalid");
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Gagal: ${e.toString()}"),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login No. HP (Bun Backend)")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // === BAGIAN 1: INPUT NOMOR HP ===
            if (!_isCodeSent) ...[
              Text(
                "Masukkan Nomor HP",
                style: GoogleFonts.poppins(
                    fontSize: 20, fontWeight: FontWeight.bold),
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
                  onPressed: _isLoading ? null : _sendOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Kirim Kode",
                          style: TextStyle(color: Colors.white)),
                ),
              ),
            ]

            // === BAGIAN 2: INPUT OTP ===
            else ...[
              Text(
                "Masukkan Kode OTP",
                style: GoogleFonts.poppins(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Pinput(
                controller: _otpController,
                length: 6,
                onCompleted: (val) => _verifyOtp(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Verifikasi & Login",
                          style: TextStyle(color: Colors.white)),
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
