import 'dart:convert';
import 'dart:developer' as dev;
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class AuthApiService {
  static const String _loginPath = '/login';
  static const String _registerPath = '/register';
  static const String _verifyOtpPath = '/otp/verify';
  static const String _forgotPasswordPath = '/password/forgot';
  static const String _resetPasswordPath = '/password/reset';
  static const String _changePasswordPath = '/password/change';

  Uri _authUrl(String path) => Uri.parse('${ApiConfig.authBaseUrl}$path');
  Uri _url(String path) => Uri.parse('${ApiConfig.baseUrl}$path');

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final res = await http.post(
      _authUrl(_loginPath),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Login gagal: ${res.statusCode} ${res.body}');
    }

    final decoded = jsonDecode(res.body);
    if (decoded is Map<String, dynamic>) return decoded;

    // kalau backend balikin array/string, bungkus aja
    return {'data': decoded};
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    String? referralCode,
  }) async {
    final res = await http.post(
      _authUrl(_registerPath),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
        'name': name,
        'phone': phone,
        if (referralCode != null && referralCode.isNotEmpty)
          'referralCode': referralCode,
      }),
    );

    dev.log(
      'register ${_authUrl(_registerPath)} -> ${res.statusCode} ${res.body}',
      name: 'AuthApiService',
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Register gagal: ${res.statusCode} ${res.body}');
    }

    final decoded = jsonDecode(res.body);
    if (decoded is Map<String, dynamic>) return decoded;
    return {'data': decoded};
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final res = await http.post(
      _url(_verifyOtpPath),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'otp': otp,
      }),
    );

    dev.log(
      'verifyOtp ${_url(_verifyOtpPath)} -> ${res.statusCode} ${res.body}',
      name: 'AuthApiService',
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Verifikasi OTP gagal: ${res.statusCode} ${res.body}');
    }

    final decoded = jsonDecode(res.body);
    if (decoded is Map<String, dynamic>) return decoded;
    return {'data': decoded};
  }

  Future<void> forgotPassword({required String email}) async {
    final res = await http.post(
      _url(_forgotPasswordPath),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'email': email}),
    );

    dev.log(
      'forgotPassword ${_url(_forgotPasswordPath)} -> ${res.statusCode} ${res.body}',
      name: 'AuthApiService',
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Forgot password gagal: ${res.statusCode} ${res.body}');
    }
  }

  Future<void> resetPassword({
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final res = await http.post(
      _url(_resetPasswordPath),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'token': token,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      }),
    );

    dev.log(
      'resetPassword ${_url(_resetPasswordPath)} -> ${res.statusCode} ${res.body}',
      name: 'AuthApiService',
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Reset password gagal: ${res.statusCode} ${res.body}');
    }
  }

  Future<void> changePassword({
    required String accessToken,
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final res = await http.put(
      _url(_changePasswordPath),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({
        'oldPassword': oldPassword,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      }),
    );

    dev.log(
      'changePassword ${_url(_changePasswordPath)} -> ${res.statusCode} ${res.body}',
      name: 'AuthApiService',
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Change password gagal: ${res.statusCode} ${res.body}');
    }
  }
}
