import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

// IMPORT FILE KAMU
import '../auth/firebase_auth_service.dart';
// Import model dengan alias agar tidak bentrok dengan Firebase User
import '../core/user_model.dart' as app_model; 
import '../providers/user_provider.dart';
import '../dashboard/dashboard_page.dart';
import '../core/app_colors.dart';

class AuthProvider with ChangeNotifier {
  // --- STATE ---
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _verificationId; 
  final FirebaseAuthService _authService = FirebaseAuthService();
  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ===========================================================================
  // 🔥 FITUR UTAMA: REGISTER SIMPLE (EMAIL & PASS) - GRATIS
  // ===========================================================================

  Future<void> registerWithEmail({
    required String name,
    required String email,
    required String phone,
    required String password,
    required BuildContext context,
  }) async {
    _setLoading(true);
    try {
      // 1. Buat Akun di Firebase Auth (Email & Password)
      firebase_auth.UserCredential userCredential = 
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      if (user != null) {
        // 2. Update Nama Display User
        await user.updateDisplayName(name);

        // 3. Simpan Data Lengkap ke Firestore
        // PENTING: Gunakan key 'phoneNumber' & 'name' agar sesuai dengan User Model
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': name, // Sesuai model
          'email': email,
          'phoneNumber': phone, // Sesuai model (jangan pakai 'phone')
          'role': 'user',
          'photoUrl': null,
          'dateOfBirth': null,
          'createdAt': FieldValue.serverTimestamp(),
          'hasPurchasedPackage': false,
        });

        // 4. Sukses! Load Data & Masuk ke Dashboard
        if (context.mounted) {
          _showSnackBar(context, 'Pendaftaran Berhasil!', isError: false);
          
          // Gunakan fungsi load dari UserProvider agar konsisten
          await Provider.of<UserProvider>(context, listen: false).loadUserData(user.uid);
          
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const DashboardPage()),
            (route) => false,
          );
        }
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      String msg = e.message ?? "Terjadi kesalahan";
      if (e.code == 'email-already-in-use') msg = "Email sudah terdaftar.";
      if (e.code == 'weak-password') msg = "Password terlalu lemah.";
      if (e.code == 'invalid-email') msg = "Format email salah.";
      
      if (context.mounted) _showSnackBar(context, msg, isError: true);
    } catch (e) {
      if (context.mounted) _showSnackBar(context, "Error: $e", isError: true);
    } finally {
      _setLoading(false);
    }
  }

  // ===========================================================================
  // FITUR STANDAR LAINNYA (LOGIN, PROFILE, DLL)
  // ===========================================================================

  // --- 1. LOGIN EMAIL & PASSWORD ---
  Future<void> signIn(String email, String password, BuildContext context) async {
    _setLoading(true);
    try {
      firebase_auth.UserCredential credential = 
          await _authService.signInWithEmailAndPassword(email, password);

      if (credential.user != null && context.mounted) {
        // Load data user dari Firestore via UserProvider
        await Provider.of<UserProvider>(context, listen: false).loadUserData(credential.user!.uid);

        Navigator.of(context).pushAndRemoveUntil(
           MaterialPageRoute(builder: (_) => const DashboardPage()),
           (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, e.toString().replaceAll('Exception: ', ''), isError: true);
      }
    } finally {
      _setLoading(false);
    }
  }

  // --- 2. LOGOUT (SUDAH DIPERBAIKI) ---
  Future<void> logout() async {
    // 1. Sign out dari Firebase
    await _firebaseAuth.signOut();
    // 2. Clear data di UserProvider (opsional tapi bagus untuk memory)
    // Provider.of<UserProvider>(context, listen:false).clearUser(); 
    // (Butuh context, biasanya ditangani UI setelah navigasi)
  }

  // --- 3. UBAH PASSWORD ---
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required BuildContext context,
  }) async {
    _setLoading(true);
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw Exception("User tidak ditemukan");

      final cred = firebase_auth.EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPassword);

      if (context.mounted) {
        _showSnackBar(context, 'Password berhasil diubah!', isError: false);
        Navigator.of(context).pop();
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        String message = 'Gagal mengubah password.';
        if (e.toString().contains('wrong-password')) message = 'Password lama anda salah.';
        else if (e.toString().contains('weak-password')) message = 'Password baru terlalu lemah.';
        _showSnackBar(context, message, isError: true);
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // --- 4. UPLOAD FOTO PROFIL ---
  Future<void> uploadProfilePicture(BuildContext context, XFile imageFile) async {
    _setLoading(true);
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return;

      final bytes = await imageFile.readAsBytes();
      final String base64Image = base64Encode(bytes);

      // Update di Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'photoUrl': base64Image,
      });

      // Update di State Aplikasi (Provider)
      if (context.mounted) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        // Pastikan copyWith menggunakan parameter yang benar ('photoUrl')
        if (userProvider.user != null) {
          final updatedUser = userProvider.user!.copyWith(photoUrl: base64Image);
          userProvider.setUser(updatedUser);
        }
        
        _showSnackBar(context, 'Foto profil berhasil diperbarui!', isError: false);
      }
    } catch (e) {
      if (context.mounted) _showSnackBar(context, 'Gagal upload: $e', isError: true);
    } finally {
      _setLoading(false);
    }
  }

  // --- 5. UPDATE DATA PROFIL (Teks) ---
  Future<void> updateUserData({
    required String name,
    required String phone,
    required String dob,
    required BuildContext context,
  }) async {
    _setLoading(true);
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return;

      // Update di Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'name': name,
        'phoneNumber': phone, // Gunakan key 'phoneNumber'
        'dateOfBirth': dob,
      });

      // Update Display Name di Firebase Auth (Opsional)
      await user.updateDisplayName(name);

      // Update di State Aplikasi (Provider)
      if (context.mounted) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        if (userProvider.user != null) {
          // Sesuaikan dengan nama parameter di User.copyWith
          final updatedUser = userProvider.user!.copyWith(
            name: name,
            phoneNumber: phone,
            dateOfBirth: dob,
          );
          userProvider.setUser(updatedUser);
        }
        
        _showSnackBar(context, 'Profil berhasil diperbarui!', isError: false);
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) _showSnackBar(context, 'Gagal update profil: $e', isError: true);
    } finally {
      _setLoading(false);
    }
  }

  // --- 6. LOGIN GOOGLE ---
  Future<void> signInWithGoogle(BuildContext context) async {
    _setLoading(true);
    try {
      firebase_auth.UserCredential credential = await _authService.signInWithGoogle();
      if (credential.user != null && context.mounted) {
         await Provider.of<UserProvider>(context, listen: false).loadUserData(credential.user!.uid);
         Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const DashboardPage()),
            (route) => false,
         );
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, e.toString().replaceAll('Exception: ', ''), isError: true);
      }
    } finally {
      _setLoading(false);
    }
  }

  // --- 7. LOGIN NO HP (Legacy) ---
  Future<void> sendOtp(String phoneNumber, BuildContext context) async {
    _setLoading(true);
    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (firebase_auth.PhoneAuthCredential credential) async {
          await _firebaseAuth.signInWithCredential(credential);
          _setLoading(false);
        },
        verificationFailed: (firebase_auth.FirebaseAuthException e) {
          _setLoading(false);
          _showSnackBar(context, 'Gagal kirim OTP: ${e.message}', isError: true);
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _setLoading(false);
          _showSnackBar(context, 'Kode OTP terkirim!', isError: false);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      _setLoading(false);
      if (context.mounted) _showSnackBar(context, e.toString(), isError: true);
    }
  }

  // --- HELPERS ---
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}