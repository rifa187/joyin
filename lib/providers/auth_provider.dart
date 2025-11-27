import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

// IMPORT FILE KAMU
import '../auth/firebase_auth_service.dart';
import '../core/user_model.dart' as app_model;
import '../providers/user_provider.dart';
import '../dashboard/dashboard_page.dart';
import '../core/app_colors.dart';

class AuthProvider with ChangeNotifier {
  // --- STATE ---
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _verificationId; // Masih disimpan jika nanti butuh fitur lain
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
        // Kita simpan nomor HP di sini agar data kontak tetap ada
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': name,
          'email': email,
          'phone': phone, // Disimpan sebagai string biasa
          'role': 'user',
          'photoUrl': null,
          'dateOfBirth': null,
          'createdAt': FieldValue.serverTimestamp(),
          'hasPurchasedPackage': false,
        });

        // 4. Sukses! Masuk ke Dashboard
        if (context.mounted) {
          _showSnackBar(context, 'Pendaftaran Berhasil!', isError: false);
          await _fetchUserDataAndNavigate(user.uid, context);
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
        await _fetchUserDataAndNavigate(credential.user!.uid, context);
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, e.toString().replaceAll('Exception: ', ''), isError: true);
      }
    } finally {
      _setLoading(false);
    }
  }

  // --- 2. UBAH PASSWORD ---
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

  // --- 3. UPLOAD FOTO PROFIL (METODE BASE64) ---
  Future<void> uploadProfilePicture(BuildContext context, XFile imageFile) async {
    _setLoading(true);
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return;

      final bytes = await imageFile.readAsBytes();
      final String base64Image = base64Encode(bytes);

      await _firestore.collection('users').doc(user.uid).update({
        'photoUrl': base64Image,
      });

      if (context.mounted) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final updatedUser = userProvider.user!.copyWith(photoUrl: base64Image);
        userProvider.setUser(updatedUser);
        
        _showSnackBar(context, 'Foto profil berhasil diperbarui!', isError: false);
      }
    } catch (e) {
      if (context.mounted) _showSnackBar(context, 'Gagal upload: $e', isError: true);
    } finally {
      _setLoading(false);
    }
  }

  // --- 4. UPDATE DATA PROFIL (Teks) ---
  Future<void> updateUserData({
    required String name,
    required String phone,
    required String dob,
    required BuildContext context,
  }) async {
    _setLoading(true);
    try {
      final uid = _firebaseAuth.currentUser!.uid;

      await _firestore.collection('users').doc(uid).update({
        'name': name,
        'phone': phone,
        'dateOfBirth': dob,
      });

      if (context.mounted) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final updatedUser = userProvider.user!.copyWith(
          displayName: name,
          phoneNumber: phone,
          dateOfBirth: dob,
        );
        userProvider.setUser(updatedUser);
        
        _showSnackBar(context, 'Profil berhasil diperbarui!', isError: false);
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) _showSnackBar(context, 'Gagal update profil: $e', isError: true);
    } finally {
      _setLoading(false);
    }
  }

  // --- 5. LOGIN GOOGLE ---
  Future<void> signInWithGoogle(BuildContext context) async {
    _setLoading(true);
    try {
      firebase_auth.UserCredential credential = await _authService.signInWithGoogle();
      if (credential.user != null && context.mounted) {
        await _fetchUserDataAndNavigate(credential.user!.uid, context);
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, e.toString().replaceAll('Exception: ', ''), isError: true);
      }
    } finally {
      _setLoading(false);
    }
  }

  // --- 6. LOGIN NO HP (Legacy/Lama) ---
  // Catatan: Fungsi ini kemungkinan juga butuh Billing Blaze untuk kirim SMS.
  // Saya biarkan di sini agar kode login lama Anda tidak error, 
  // tapi untuk Register kita sudah pakai Email (Gratis).
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

  // --- PRIVATE HELPERS ---
  Future<void> _fetchUserDataAndNavigate(String uid, BuildContext context) async {
    try {
      final userData = await _authService.getUserData(uid);
      if (userData == null) return; 

      final currentUser = app_model.User(
        uid: uid,
        email: userData['email'] ?? '',
        displayName: userData['name'] ?? 'No Name', 
        phoneNumber: userData['phone'] ?? '',
        hasPurchasedPackage: userData['hasPurchasedPackage'] ?? false,
        photoUrl: userData['photoUrl'],
        dateOfBirth: userData['dateOfBirth'], 
      );

      if (!context.mounted) return;
      Provider.of<UserProvider>(context, listen: false).setUser(currentUser);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_purchased_package', currentUser.hasPurchasedPackage);

      if (!context.mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const DashboardPage()),
        (route) => false,
      );
    } catch (e) {
      throw Exception(e.toString());
    }
  }

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