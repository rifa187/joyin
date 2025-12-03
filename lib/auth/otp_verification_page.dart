import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart'; // WAJIB: Untuk simpan ke database
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

// --- IMPORT MODEL & PROVIDER ---
// Menggunakan alias 'model' agar tidak bentrok dengan class User milik Firebase
import '../core/user_model.dart' as model; 
import '../providers/user_provider.dart';

// --- IMPORT HALAMAN ---
import '../dashboard/dashboard_page.dart';
import 'new_password_page.dart'; // Halaman untuk input password baru
import 'sendgrid_service.dart';

class OtpVerificationPage extends StatefulWidget {
  final String email;
  final bool isRegister; // TRUE = Daftar, FALSE = Lupa Password
  final String? password;
  final String? name;
  final String? phoneNumber;

  const OtpVerificationPage({
    super.key,
    required this.email,
    required this.isRegister,
    this.password,
    this.name,
    this.phoneNumber,
  });

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final TextEditingController _pinController = TextEditingController();
  final SendGridService _sendGrid = SendGridService();

  bool _isLoading = false;
  String? _generatedOtp;

  @override
  void initState() {
    super.initState();
    // Langsung kirim OTP saat halaman dibuka
    _generateAndSendOtp();
  }

  // --- 1. GENERATE & KIRIM OTP VIA EMAIL ---
  Future<void> _generateAndSendOtp() async {
    setState(() => _isLoading = true);
    
    // Generate 4 digit angka acak
    String code = (Random().nextInt(9000) + 1000).toString();

    setState(() {
      _generatedOtp = code;
    });

    // Panggil Service SendGrid
    bool isSent = await _sendGrid.sendOtpEmail(widget.email, code);

    if (mounted) {
      setState(() => _isLoading = false);
      if (isSent) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text("Kode OTP terkirim ke email! Cek Inbox/Spam."),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.orange,
            content: Text("Gagal kirim email. Cek koneksi internet."),
          ),
        );
      }
    }
  }

  // --- 2. VERIFIKASI KODE ---
  Future<void> _verifyOtp() async {
    String inputUser = _pinController.text;
    if (inputUser.length < 4) return;

    setState(() => _isLoading = true);

    // Cek kecocokan kode (Bypass '1234' untuk testing jika perlu)
    bool isValid = (inputUser == _generatedOtp) || (inputUser == "1234");

    if (!isValid) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red, 
            content: Text("Kode OTP Salah!"),
          ),
        );
      }
      return;
    }

    // --- JIKA KODE BENAR ---
    if (widget.isRegister) {
      // ---> SKENARIO 1: REGISTER BARU (Simpan Data & Masuk Dashboard)
      await _handleRegisterProcess();
    } else {
      // ---> SKENARIO 2: LUPA PASSWORD (Pindah ke NewPasswordPage)
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => NewPasswordPage(email: widget.email),
          ),
        );
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  // --- LOGIC REGISTER & SIMPAN FIRESTORE ---
  Future<void> _handleRegisterProcess() async {
    try {
      // 1. Buat Akun Firebase Auth
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: widget.email,
        password: widget.password!,
      );

      User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        // 2. Update Display Name
        await firebaseUser.updateDisplayName(widget.name);

        // 3. Siapkan Data User (Pakai Model Kita)
        model.User newUser = model.User(
          uid: firebaseUser.uid,
          email: widget.email,
          name: widget.name ?? 'No Name',
          phoneNumber: widget.phoneNumber, // Simpan No HP
          photoUrl: '',
          createdAt: DateTime.now(),
        );

        // 4. Simpan ke Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid)
            .set(newUser.toJson());

        // 5. Update Provider & Navigasi
        if (mounted) {
          await Provider.of<UserProvider>(context, listen: false)
              .loadUserData(firebaseUser.uid);

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const DashboardPage()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal Register: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56, height: 56,
      textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isRegister ? "Verifikasi Pendaftaran" : "Reset Password"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              "Masukkan Kode OTP", 
              style: Theme.of(context).textTheme.headlineSmall
            ),
            const SizedBox(height: 10),
            Text(
              "Kode dikirim ke ${widget.email}",
              textAlign: TextAlign.center, 
              style: const TextStyle(color: Colors.grey)
            ),
            const SizedBox(height: 30),
            
            // INPUT OTP
            Pinput(
              length: 4,
              controller: _pinController,
              defaultPinTheme: defaultPinTheme,
              onCompleted: (_) => _verifyOtp(),
            ),
            
            const SizedBox(height: 30),
            
            // TOMBOL VERIFIKASI
            if (_isLoading)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: _verifyOtp,
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                child: const Text("Verifikasi"),
              ),
              
            const SizedBox(height: 20),
            
            // TOMBOL KIRIM ULANG
            TextButton(
              onPressed: _isLoading ? null : _generateAndSendOtp,
              child: const Text("Kirim Ulang Kode"),
            )
          ],
        ),
      ),
    );
  }
}