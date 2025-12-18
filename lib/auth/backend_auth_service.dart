import 'package:dio/dio.dart';
import 'package:joyin/core/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:joyin/core/env.dart';

class BackendAuthService {
  final Dio _dio = Dio();
  final String _baseUrl;

  BackendAuthService() : _baseUrl = _getBackendUrl() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.headers['Content-Type'] = 'application/json';
  }

  static String _getBackendUrl() {
    if (Env.apiBaseUrl.isNotEmpty) return Env.apiBaseUrl;

    if (kIsWeb) {
      return 'http://localhost:3000/api'; // For web, localhost works
    } else if (Platform.isAndroid) {
      // For Android emulator, 10.0.2.2 points to the host machine (still local)
      // Set API_BASE_URL via --dart-define for physical devices instead of hardcoding IPs
      return 'http://10.0.2.2:3000/api';
    }
    // Default or other platforms
    return 'http://localhost:3000/api';
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
          id: data['id']?.toString() ?? '',
          email: data['email'] ?? email,
          displayName: data['name'] ?? data['email'] ?? '',
          phoneNumber: data['phone'],
          dateOfBirth: data['birthDate'],
          role: data['role']?.toString(),
          plan: data['plan']?.toString(),
          photoUrl: data['avatar'],
          hasPurchasedPackage:
              (data['plan'] != null && data['plan'] != 'free') || data['hasPurchasedPackage'] == true,
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
