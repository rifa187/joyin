import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../core/env.dart';
import '../services/api_client.dart';
import '../services/auth_api_service.dart';
import '../services/user_api_service.dart';

// SERVICES & MODELS
import '../services/auth_api_service.dart';
import '../core/user_model.dart' as app_model;
import '../providers/user_provider.dart';
import '../providers/package_provider.dart';
import '../dashboard/dashboard_gate.dart';
import '../auth/otp_verification_page.dart'; // We will create this
import '../core/app_colors.dart';

class AuthProvider with ChangeNotifier {
  // --- STATE ---
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final AuthApiService _apiService = AuthApiService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // --- 1. LOGIN EMAIL & PASSWORD ---
  Future<void> signIn(
      String email, String password, BuildContext context) async {
    _setLoading(true);
    try {
      final data = await _apiService.login(email, password);

      print('📦 LOGIN RESPONSE DATA: $data'); // Debug print

      if (context.mounted) {
        // PERBAIKAN: Backend mengembalikan data flat (termasuk token & user fields di root data)
        // struct: { accessToken, refreshToken, email, name, phone, role, plan, avatar, ... }
        final userJson = data;

        final user = app_model.User.fromJson(userJson);

        await _handleAuthSuccess(user, context);
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, e.toString().replaceAll('Exception: ', ''),
            isError: true);
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
    String? referralCode,
    required BuildContext context,
  }) async {
    _setLoading(true);
    try {
      final response = await _apiService.register(
        email: email,
        password: password,
        name: name,
        phone: phone,
        referralCode: referralCode,
      );

      if (context.mounted) {
        _showSnackBar(context,
            response['message'] ?? 'Registrasi berhasil. Cek email untuk OTP.',
            isError: false);

        // Navigate to OTP Page
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => OtpVerificationPage(email: email),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, e.toString().replaceAll('Exception: ', ''),
            isError: true);
      }
    } finally {
      _setLoading(false);
    }
  }

  // --- 3. VERIFY OTP ---
  Future<void> verifyOtp(String email, String otp, BuildContext context) async {
    _setLoading(true);
    try {
      final data = await _apiService.verifyOtp(email, otp);

      if (context.mounted) {
        _showSnackBar(context, 'Verifikasi berhasil!', isError: false);

        // Data 'user' dari backend
        // Deteksi apakah user ada di dalam field 'user' atau root (flat)
        Map<String, dynamic> userJson;
        if (data.containsKey('user') && data['user'] is Map) {
          userJson = data['user'];
        } else {
          // Fallback: asumsikan struktur flat (seperti pada login)
          userJson = data;
        }

        final user = app_model.User.fromJson(userJson);

        await _handleAuthSuccess(user, context);
      }
    } catch (e) {
      print('❌ Error verifyOtp: $e');
      if (context.mounted) {
        _showSnackBar(context, e.toString().replaceAll('Exception: ', ''),
            isError: true);
      }
    } finally {
      _setLoading(false);
    }
  }

  // --- 4. CHECK AUTH STATUS (Persistent Login) ---
  Future<bool> checkAuthStatus(BuildContext context) async {
    try {
      final token = await _apiService.getAccessToken();
      if (token != null && token.isNotEmpty) {
        // Jika token ada, kita anggap user masih login.
        // Idealnya: panggil endpoint /profile untuk refresh data user.
        // Untuk sekarang, return true agar tidak ditendang ke onboarding.
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // --- 5. LOGOUT ---
  Future<void> signOut(BuildContext context) async {
    await _apiService.logout();
    if (context.mounted) {
      Provider.of<UserProvider>(context, listen: false).clearUser();
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  // --- PLACEHOLDERS FOR MISSING FEATURES ---

  Future<void> signInWithGoogle(BuildContext context) async {
    // TODO: Implement Google Sign In via Backend
    _showSnackBar(context, 'Login Google belum tersedia di backend ini.',
        isError: true);
  }

  Future<void> updateUserData({
    required String name,
    required String phone,
    required String dob,
    required BuildContext context,
  }) async {
    _setLoading(true);
    try {
      // 1. Call API
      final updatedData =
          await _apiService.updateProfile(name: name, phone: phone);

      // 2. Update Local State
      if (context.mounted) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);

        // Copy existing user with new data
        final newUser = userProvider.user?.copyWith(
          displayName: updatedData['name'],
          phoneNumber: updatedData['phone'],
          // Note: dateOfBirth not sent/returned by backend API in this snippet,
          // but we can assume it might be added later.
          // For now we trust what we sent or keep existing if API doesn't return it.
        );

        if (newUser != null) {
          userProvider.setUser(newUser);
        }

        _showSnackBar(context, 'Profil berhasil diperbarui!', isError: false);
        Navigator.of(context).pop(); // Tutup halaman edit
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, e.toString(), isError: true);
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> uploadProfilePicture(
      BuildContext context, XFile imageFile) async {
    _setLoading(true);
    try {
      // 1. Call API Upload
      final avatarUrl = await _apiService.uploadAvatar(imageFile);

      // 2. Update Local User State
      if (context.mounted) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        // Construct full URL if backend returns relative path
        // Assuming backend returns "/uploads/..." and we need to prepend base URL for display?
        // Actually, user model just stores string. The UI handles "http" or "base64".
        // Ideally we store full path or handle relative path in UI (ProfileAvatar).
        // Let's store what backend gives.

        // Perbaiki: Backend biasa return relative path "/uploads/files...".
        // Kita simpan itu. UI ProfileAvatar harus smart enough tambah Base URL
        // ATAU kita tambah Base URL disini.
        // Kita simpan FULL URL agar mudah.
        // Namun AuthApiService base URL private.
        // Mari simpan relative path, nanti AuthApiService atau UI yang resolve.

        // TAPI, UI profile_avatar.dart kita tadi logicnya:
        // if startsWith('http') -> NetworkImage.
        // Jadi kita harus simpan Full URL.

        // Hack: Hardcode base url for now or expose it
        final fullUrl = AuthApiService.baseUrlString + avatarUrl;

        final newUser = userProvider.user?.copyWith(photoUrl: fullUrl);
        if (newUser != null) userProvider.setUser(newUser);

        _showSnackBar(context, 'Foto berhasil diupload!', isError: false);
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, e.toString(), isError: true);
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required BuildContext context,
  }) async {
    // TODO: Implement Change Password
    _showSnackBar(context, 'Ubah Password belum tersedia.', isError: true);
    return false;
  }

  // --- HELPERS ---

  Future<void> _handleAuthSuccess(
      app_model.User user, BuildContext context) async {
    // A. Simpan ke UserProvider
    Provider.of<UserProvider>(context, listen: false).setUser(user);

    // B. Cek Preferensi Paket (Jika ada logic paket lokal)
    // (Bisa disesuaikan jika paket datang dari backend)
    final packageProvider =
        Provider.of<PackageProvider>(context, listen: false);
    if (user.hasPurchasedPackage) {
      // Logic sync paket jika perlu
    }

    // C. Navigasi ke Dashboard
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const DashboardGate()),
      (route) => false,
    );
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _showSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  bool get _useBackendAuth => Env.useBackendAuth && Env.apiBaseUrl.isNotEmpty;

  void _ensureApi() {
    if (_apiClient != null) return;
    if (Env.apiBaseUrl.isEmpty) {
      throw Exception('API_BASE_URL belum diset. Tambahkan --dart-define=API_BASE_URL=https://api.example.com');
    }
    _apiClient = ApiClient(Env.apiBaseUrl);
    _authApi = AuthApiService(_apiClient!);
    _userApi = UserApiService(_apiClient!);
  }

  Future<void> _handleBackendLogin(String email, String password, BuildContext context) async {
    _ensureApi();
    final authApi = _authApi!;
    final userApi = _userApi!;
    final prefs = await SharedPreferences.getInstance();

    final token = await authApi.login(email, password);
    _apiClient!.setToken(token);
    await prefs.setString('auth_token', token);

    final userJson = await userApi.fetchMe();
    final mappedUser = app_model.User(
      uid: (userJson['id'] ?? userJson['uid'] ?? '') as String,
      email: userJson['email'] as String?,
      displayName: userJson['name'] as String? ?? userJson['fullName'] as String?,
      phoneNumber: userJson['phone'] as String? ?? userJson['phoneNumber'] as String?,
      photoUrl: userJson['photoUrl'] as String? ?? userJson['avatar'] as String?,
      dateOfBirth: userJson['dateOfBirth'] as String?,
      hasPurchasedPackage: (userJson['hasPurchasedPackage'] ?? userJson['isSubscribed'] ?? false) as bool,
      isAdmin: (userJson['role'] == 'admin') || (userJson['isAdmin'] == true),
    );

    if (!context.mounted) return;
    Provider.of<UserProvider>(context, listen: false).setUser(mappedUser);
    await prefs.setBool('has_purchased_package', mappedUser.hasPurchasedPackage);

    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const DashboardGate()),
      (route) => false,
    );
  }
}
