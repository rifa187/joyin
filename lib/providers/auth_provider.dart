import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uni_links/uni_links.dart';

import '../services/auth_api_service.dart';
import '../services/profile_api_service.dart';
import '../services/token_storage.dart';
import '../core/user_model.dart';
import '../auth/otp_verification_page.dart';
import '../auth/auth_service.dart' as oauth;

class AuthProvider extends ChangeNotifier {
  final AuthApiService _api = AuthApiService();
  final TokenStorage _tokenStorage = TokenStorage();
  final ProfileApiService _profileApi = ProfileApiService();
  final oauth.AuthService _oauth = oauth.AuthService();

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
        if (meData['user'] is Map<String, dynamic>) {
          _user = User.fromJson(meData['user'] as Map<String, dynamic>);
        } else {
          _user = User.fromJson(meData);
        }
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
      if (meData['user'] is Map<String, dynamic>) {
        _user = User.fromJson(meData['user'] as Map<String, dynamic>);
      } else {
        _user = User.fromJson(meData);
      }
    } catch (e) {
      // token invalid -> bersihkan
      await logout();
      _error = e.toString();
    } finally {
      _initialized = true;
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
      final data = {
        'name': name,
        'phone': phone,
        // Backend key for birthDate might be 'birthDate' or 'date_of_birth'
        // Checking User.fromJson, it maps 'birthDate'.
        // But we are sending. 'ProfileApiService' expects Map to send.
        // Let's assume backend accepts 'birthDate'.
        if (dob != null) 'birthDate': dob,
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
    StreamSubscription<Uri?>? sub;
    final completer = Completer<bool>();

    _isLoading = true;
    _error = null;
    notifyListeners();

    void completeOnce(bool value) {
      if (!completer.isCompleted) completer.complete(value);
    }

    Future<void> handleUri(Uri? uri) async {
      if (uri == null) return;
      if (uri.scheme != 'joyin' || uri.host != 'oauth-callback') {
        return;
      }

      await sub?.cancel();

      final accessToken = uri.queryParameters['accessToken'];
      final refreshToken = uri.queryParameters['refreshToken'];

      if (accessToken == null || accessToken.isEmpty) {
        _error = 'Access token tidak ditemukan di callback';
        _isLoading = false;
        notifyListeners();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_error!),
            backgroundColor: Colors.red,
          ),
        );
        completeOnce(false);
        return;
      }

      try {
        await _tokenStorage.save(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );

        _accessToken = accessToken;

        // Ambil profil dari backend bila tersedia.
        try {
          final meData = await _profileApi.me(accessToken);
          if (meData['user'] is Map<String, dynamic>) {
            _user = User.fromJson(meData['user'] as Map<String, dynamic>);
          } else {
            _user = User.fromJson(meData as Map<String, dynamic>);
          }
        } catch (_) {
          // Fallback ke data query param jika /users/me gagal.
          _user = User.fromJson({
            'id': uri.queryParameters['id'] ?? '',
            'email': uri.queryParameters['email'] ?? '',
            'name': uri.queryParameters['name'] ?? '',
            'avatar': uri.queryParameters['avatar'],
            'role': uri.queryParameters['role'],
            'plan': uri.queryParameters['plan'],
            'birthDate': uri.queryParameters['birthDate'],
            'phone': uri.queryParameters['phone'],
          });
        }

        _isLoading = false;
        notifyListeners();
        completeOnce(true);
      } catch (e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google Sign-In gagal: $e'),
            backgroundColor: Colors.red,
          ),
        );
        completeOnce(false);
      }
    }

    sub = uriLinkStream.listen(
      (uri) {
        unawaited(handleUri(uri));
      },
      onError: (err) {
        _error = err.toString();
        _isLoading = false;
        notifyListeners();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google Sign-In gagal: $err'),
            backgroundColor: Colors.red,
          ),
        );
        completeOnce(false);
      },
      cancelOnError: true,
    );

    try {
      await _oauth.signInWithGoogle();
    } catch (e) {
      await sub.cancel();
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

    final result = await completer.future.timeout(
      const Duration(minutes: 2),
      onTimeout: () {
        _error = 'Google Sign-In timeout';
        _isLoading = false;
        notifyListeners();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Google Sign-In timeout'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      },
    );

    await sub.cancel();
    return result;
  }
}
