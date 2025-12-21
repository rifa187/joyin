import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../services/auth_api_service.dart';
import '../services/profile_api_service.dart';
import '../services/token_storage.dart';
import '../core/user_model.dart';
import '../auth/otp_verification_page.dart';
import '../core/env.dart';

class AuthProvider extends ChangeNotifier {
  final AuthApiService _api = AuthApiService();
  final TokenStorage _tokenStorage = TokenStorage();
  final ProfileApiService _profileApi = ProfileApiService();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: Env.googleWebClientId.isEmpty ? null : Env.googleWebClientId,
  );

  Map<String, dynamic> _extractUserPayload(Map<String, dynamic> data) {
    final userData = data['user'];
    if (userData is Map<String, dynamic>) {
      return userData;
    }
    final payload = data['data'];
    if (payload is Map<String, dynamic>) {
      return payload;
    }
    return data;
  }

  User _mergeUser(User incoming) {
    final current = _user;
    if (current == null) return incoming;

    final incomingName = incoming.displayName.trim();
    final fallbackName = current.displayName.trim();
    final resolvedName = (incomingName.isEmpty || incomingName == 'User')
        ? fallbackName
        : incomingName;

    final resolvedPhoto = incoming.photoUrl ?? current.photoUrl;
    final resolvedPhone = incoming.phoneNumber ?? current.phoneNumber;
    final resolvedDob = incoming.dateOfBirth ?? current.dateOfBirth;
    final resolvedRole = incoming.role ?? current.role;
    final resolvedPlan = incoming.plan ?? current.plan;

    return current.copyWith(
      displayName: resolvedName,
      photoUrl: resolvedPhoto,
      phoneNumber: resolvedPhone,
      dateOfBirth: resolvedDob,
      role: resolvedRole,
      plan: resolvedPlan,
      hasPurchasedPackage:
          incoming.hasPurchasedPackage || current.hasPurchasedPackage,
    );
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _initialized = false;
  bool get initialized => _initialized;

  String? _error;
  String? get error => _error;

  String? _accessToken;
  String? get accessToken => _accessToken;

  User? _user;
  User? get user => _user;

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  /// Login ke backend Bun -> simpan token
  Future<void> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.login(email: email, password: password);

      final payload = (response['data'] is Map<String, dynamic>)
          ? response['data'] as Map<String, dynamic>
          : response.cast<String, dynamic>();

      final accessToken =
          (payload['accessToken'] ?? payload['token'])?.toString();
      final refreshToken = payload['refreshToken']?.toString();

      if (accessToken == null || accessToken.isEmpty) {
        throw Exception(
          'Backend tidak mengirim accessToken/token. '
          'Cek response login backend kamu.',
        );
      }

      await _tokenStorage.save(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );

      _accessToken = accessToken;

      // Gunakan data login untuk set user terlebih dahulu
      _user = User.fromJson(payload);

      // Coba refresh profil dari backend jika endpoint tersedia
      try {
        final meData = await _profileApi.me(accessToken);
        _user = _mergeUser(User.fromJson(_extractUserPayload(meData)));
      } catch (_) {
        // Abaikan jika endpoint tidak tersedia; sudah punya data dari login
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Register lalu arahkan ke halaman OTP (email)
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    String? referralCode,
    required BuildContext context,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _api.register(
        email: email,
        password: password,
        name: name,
        phone: phone,
        referralCode: referralCode,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Registrasi berhasil. Cek email untuk OTP lalu verifikasi.',
          ),
        ),
      );
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OtpVerificationPage(email: email),
        ),
      );
    } catch (e) {
      _error = e.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registrasi gagal: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Saat app dibuka -> cek token di storage -> kalau ada, ambil /users/me
  Future<void> restoreSession() async {
    _error = null;

    try {
      final token = await _tokenStorage.getAccessToken();
      if (token == null || token.isEmpty) {
        _accessToken = null;
        _user = null;
        return;
      }

      _accessToken = token;

      final meData = await _profileApi.me(token);
      _user = _mergeUser(User.fromJson(_extractUserPayload(meData)));
    } catch (e) {
      // token invalid -> bersihkan
      await logout();
      _error = e.toString();
    } finally {
      _initialized = true;
      notifyListeners();
    }
  }

  Future<void> refreshProfile() async {
    _error = null;

    try {
      final token = _accessToken ?? await _tokenStorage.getAccessToken();
      if (token == null || token.isEmpty) {
        return;
      }

      _accessToken = token;
      final meData = await _profileApi.me(token);
      _user = _mergeUser(User.fromJson(_extractUserPayload(meData)));
    } catch (e) {
      _error = e.toString();
    } finally {
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _tokenStorage.clear();
    _accessToken = null;
    _user = null;
    notifyListeners();
  }

  /// Compatibility with main.dart AuthWrapper
  Future<bool> checkAuthStatus(BuildContext context) async {
    await restoreSession();
    return _accessToken != null;
  }

  // --- METHODS FOR EDIT PROFILE PAGE ---

  Future<void> updateUserData({
    required String name,
    required String phone,
    String? dob,
    required BuildContext context,
  }) async {
    if (_accessToken == null) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final trimmedDob = (dob ?? '').trim();
      final data = {
        'name': name,
        'phone': phone,
        if (trimmedDob.isNotEmpty)
          // Only send birthDate if user set it; backend may ignore this field.
          'birthDate': trimmedDob,
      };

      final updatedData = await _profileApi.updateProfile(_accessToken!, data);

      if (updatedData['user'] is Map<String, dynamic>) {
        _user = User.fromJson(updatedData['user'] as Map<String, dynamic>);
      } else {
        _user = User.fromJson(updatedData);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui')),
      );
      Navigator.pop(context);
    } catch (e) {
      _error = e.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Gagal update: $e'), backgroundColor: Colors.red),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> uploadProfilePicture(BuildContext context, XFile file) async {
    if (_accessToken == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      final updatedData = await _profileApi.uploadAvatar(_accessToken!, file);

      if (updatedData['user'] is Map<String, dynamic>) {
        _user = User.fromJson(updatedData['user'] as Map<String, dynamic>);
      } else {
        _user = User.fromJson(updatedData);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto profil berhasil diupload')),
      );
    } catch (e) {
      _error = e.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Gagal upload: $e'), backgroundColor: Colors.red),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Change password (placeholder; adjust to backend when available)
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required BuildContext context,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: hit backend change-password endpoint when available.
      await Future<void>.delayed(const Duration(milliseconds: 400));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password berhasil diubah (placeholder)')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      _error = e.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengubah password: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> verifyOtp(String email, String otp, BuildContext context) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _api.verifyOtp(email: email, otp: otp);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP terverifikasi. Silakan login.'),
        ),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      _error = e.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Verifikasi gagal: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signInWithGoogle(BuildContext context) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (Env.googleWebClientId.isEmpty) {
        throw Exception('GOOGLE_WEB_CLIENT_ID belum di-set.');
      }

      await _googleSignIn.signOut();

      final account = await _googleSignIn.signIn();
      if (account == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw Exception('idToken Google tidak ditemukan.');
      }

      final response = await _api.loginWithGoogle(idToken: idToken);
      final payload = (response['data'] is Map<String, dynamic>)
          ? response['data'] as Map<String, dynamic>
          : response.cast<String, dynamic>();

      final accessToken =
          (payload['accessToken'] ?? payload['token'])?.toString();
      final refreshToken = payload['refreshToken']?.toString();

      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('Backend tidak mengembalikan accessToken.');
      }

      await _tokenStorage.save(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );

      _accessToken = accessToken;
      _user = User.fromJson(payload);

      try {
        final meData = await _profileApi.me(accessToken);
        _user = _mergeUser(User.fromJson(_extractUserPayload(meData)));
      } catch (_) {}

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Google Sign-In gagal: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }
}
