import 'dart:convert'; // ✅ PENTING: Untuk Base64 (Gratis)
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
  
  String? _verificationId; // Untuk OTP

  final FirebaseAuthService _authService = FirebaseAuthService();

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

  // --- 2. SIGN UP / DAFTAR ---
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required BuildContext context,
  }) async {
    _setLoading(true);
    try {
      firebase_auth.User? user = await _authService.signUpWithEmailAndData(
        email: email,
        password: password,
        name: name,
        phone: phone,
      );

      if (user != null && context.mounted) {
        _showSnackBar(context, 'Pendaftaran Berhasil!', isError: false);
        await _fetchUserDataAndNavigate(user.uid, context);
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, e.toString().replaceAll('Exception: ', ''), isError: true);
      }
    } finally {
      _setLoading(false);
    }
  }

  // --- 3. UBAH PASSWORD ---
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required BuildContext context,
  }) async {
    _setLoading(true);
    try {
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
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

  // --- 4. UPLOAD FOTO PROFIL (METODE BASE64 - GRATIS) ---
  Future<void> uploadProfilePicture(BuildContext context, XFile imageFile) async {
    _setLoading(true);
    try {
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // A. Ubah Gambar jadi Bytes -> Base64 String
      final bytes = await imageFile.readAsBytes();
      final String base64Image = base64Encode(bytes);

      // B. Simpan String Base64 ke Firestore
      // (Tanpa perlu Firebase Storage yang berbayar)
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'photoUrl': base64Image,
      });

      // C. Update Provider Lokal
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

  // --- 5. UPDATE DATA PROFIL (Teks) ---
  Future<void> updateUserData({
    required String name,
    required String phone,
    required String dob,
    required BuildContext context,
  }) async {
    _setLoading(true);
    try {
      final uid = firebase_auth.FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
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

  // --- 6. LOGIN GOOGLE ---
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

  // --- 7. FITUR OTP (Kirim Kode) ---
  Future<void> sendOtp(String phoneNumber, BuildContext context) async {
    _setLoading(true);
    try {
      await firebase_auth.FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (firebase_auth.PhoneAuthCredential credential) async {
          await firebase_auth.FirebaseAuth.instance.signInWithCredential(credential);
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

  // --- 8. FITUR OTP (Verifikasi Kode) ---
  Future<bool> verifyOtp(String smsCode, BuildContext context) async {
    _setLoading(true);
    try {
      if (_verificationId == null) throw Exception("Verification ID null");

      final credential = firebase_auth.PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );

      final userCredential = await firebase_auth.FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user != null && context.mounted) {
         await _fetchUserDataAndNavigate(userCredential.user!.uid, context);
         return true;
      }
      return false;
    } catch (e) {
      if (context.mounted) _showSnackBar(context, 'Kode OTP Salah', isError: true);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // --- PRIVATE HELPERS ---
  Future<void> _fetchUserDataAndNavigate(String uid, BuildContext context) async {
    try {
      final userData = await _authService.getUserData(uid);
      if (userData == null) throw Exception("Data profil tidak ditemukan.");

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