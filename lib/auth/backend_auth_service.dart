import 'package:dio/dio.dart';
import 'package:joyin/core/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class BackendAuthService {
  final Dio _dio = Dio();
  final String _baseUrl;

  BackendAuthService() : _baseUrl = _getBackendUrl() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.headers['Content-Type'] = 'application/json';
  }

  static String _getBackendUrl() {
    if (kIsWeb) {
      return 'http://localhost:3000'; // For web, localhost works
    } else if (Platform.isAndroid) {
      // For Android emulator, 10.0.2.2 points to the host machine
      // For physical Android device, replace with your machine's IP address (e.g., 'http://192.168.1.X:3000')
      return 'http://10.0.2.2:3000';
    }
    // Default or other platforms
    return 'http://localhost:3000';
  }

  Future<User?> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        final accessToken = data['accessToken'];
        final refreshToken = data['refreshToken'];

        // Store tokens securely (e.g., using shared_preferences for now)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', accessToken);
        await prefs.setString('refresh_token', refreshToken);

        return User(
          uid: data['id'] ?? '',
          email: data['email'],
          displayName: data['name'],
          phoneNumber: data['phone'],
          dateOfBirth: data['birthDate'] != null ? DateTime.parse(data['birthDate']).toIso8601String() : null,
          hasPurchasedPackage: false, // This will be updated later
        );
      }
      return null;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message'] ?? 'Login failed');
      }
      throw Exception('Network error or unexpected issue during login');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<String> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required DateTime birthDate,
    String? referralCode,
  }) async {
    try {
      final response = await _dio.post(
        '/register',
        data: {
          'email': email,
          'password': password,
          'name': name,
          'phone': phone,
          'birthDate': birthDate.toIso8601String(),
          'referralCode': referralCode,
        },
      );

      if (response.statusCode == 201) {
        return response.data['message'] ?? 'Registration successful. Please verify your email.';
      }
      throw Exception(response.data['message'] ?? 'Registration failed');
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message'] ?? 'Registration failed');
      }
      throw Exception('Network error or unexpected issue during registration');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // TODO: Implement logout and refresh token logic if needed
  // For logout, you might want to clear tokens from SharedPreferences
  // For refresh, you'd send the refresh token to your backend's /refresh endpoint
}
