import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

// IMPORT FILE KAMU
import '../auth/firebase_auth_service.dart';
import '../core/user_model.dart' as app_model;
import '../providers/user_provider.dart';
import '../dashboard/dashboard_page.dart';
import '../core/app_colors.dart'; // Untuk warna snackbar

class AuthProvider with ChangeNotifier {
  // --- STATE (Status Loading) ---
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final FirebaseAuthService _authService = FirebaseAuthService();

  // --- LOGIC: LOGIN EMAIL & PASSWORD ---
  Future<void> signIn(String email, String password, BuildContext context) async {
    _setLoading(true);

    try {
      firebase_auth.UserCredential credential = 
          await _authService.signInWithEmailAndPassword(email, password);

      if (credential.user != null) {
        // Jika sukses login firebase, ambil data user dari database
        if (context.mounted) {
          await _fetchUserDataAndNavigate(credential.user!.uid, context);
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, e.toString().replaceAll('Exception: ', ''), isError: true);
      }
    } finally {
      _setLoading(false);
    }
  }

  // --- LOGIC: SIGN UP / DAFTAR ---
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required BuildContext context,
  }) async {
    _setLoading(true);

    try {
      // 1. Panggil Service untuk Buat Akun
      firebase_auth.User? user = await _authService.signUpWithEmailAndData(
        email: email,
        password: password,
        name: name,
        phone: phone,
      );

      if (user != null) {
        // 2. Jika sukses, tampilkan notifikasi
        if (context.mounted) {
          _showSnackBar(context, 'Pendaftaran Berhasil!', isError: false);
          
          // 3. Simpan Data & Masuk Dashboard
          await _fetchUserDataAndNavigate(user.uid, context);
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, e.toString().replaceAll('Exception: ', ''), isError: true);
      }
    } finally {
      _setLoading(false);
    }
  }

  // --- LOGIC: UBAH PASSWORD ---
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required BuildContext context,
  }) async {
    _setLoading(true);
    try {
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      final cred = firebase_auth.EmailAuthProvider.credential(
        email: user!.email!,
        password: currentPassword,
      );

      // 1. Re-autentikasi (Cek password lama)
      await user.reauthenticateWithCredential(cred);

      // 2. Update Password
      await user.updatePassword(newPassword);

      if (context.mounted) {
        _showSnackBar(context, 'Password berhasil diubah!', isError: false);
        Navigator.of(context).pop(); // Tutup Dialog setelah sukses
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        String message = 'Gagal mengubah password.';
        if (e.toString().contains('wrong-password')) {
          message = 'Password lama anda salah.';
        } else if (e.toString().contains('weak-password')) {
          message = 'Password baru terlalu lemah.';
        }
        _showSnackBar(context, message, isError: true);
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // --- LOGIC: LOGIN GOOGLE ---
  Future<void> signInWithGoogle(BuildContext context) async {
    _setLoading(true);

    try {
      firebase_auth.UserCredential credential = await _authService.signInWithGoogle();
      if (credential.user != null) {
        if (context.mounted) {
          await _fetchUserDataAndNavigate(credential.user!.uid, context);
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, e.toString().replaceAll('Exception: ', ''), isError: true);
      }
    } finally {
      _setLoading(false);
    }
  }

  // --- PRIVATE LOGIC: AMBIL DATA USER & PINDAH HALAMAN ---
  Future<void> _fetchUserDataAndNavigate(String uid, BuildContext context) async {
    try {
      final userData = await _authService.getUserData(uid);

      if (userData == null) throw Exception("Data profil pengguna tidak ditemukan.");

      final currentUser = app_model.User(
        uid: uid,
        email: userData['email'] ?? '',
        displayName: userData['name'] ?? 'No Name', 
        phoneNumber: userData['phone'] ?? '',
        hasPurchasedPackage: userData['hasPurchasedPackage'] ?? false,
        photoUrl: userData['photoUrl'], 
      );

      // 1. Simpan ke UserProvider (State Global)
      if (!context.mounted) return;
      Provider.of<UserProvider>(context, listen: false).setUser(currentUser);
      
      // 2. Simpan status paket ke Shared Preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_purchased_package', currentUser.hasPurchasedPackage);

      // 3. Pindah ke Dashboard
      if (!context.mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const DashboardPage()),
        (route) => false,
      );

    } catch (e) {
      throw Exception(e.toString());
    }
  }

  //Helper untuk loading
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners(); // Memberitahu UI untuk update tampilan
  }

  // Helper SnackBar
  void _showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : Colors.green, // Pakai AppColors
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}