import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

// IMPORT MODEL USER TERBARU
import '../core/user_model.dart';

class BackendAuthService {
  final Dio _dio = Dio();
  final String _baseUrl;

  BackendAuthService() : _baseUrl = _getBackendUrl() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.headers['Content-Type'] = 'application/json';
    // Timeout handling (Opsional tapi disarankan)
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
  }

  static String _getBackendUrl() {
    if (kIsWeb) {
      return 'http://localhost:3000'; 
    } else if (Platform.isAndroid) {
      // 10.0.2.2 khusus emulator Android untuk akses localhost komputer
      return 'http://10.0.2.2:3000';
    }
    // Untuk iOS atau Device Fisik, ganti dengan IP Address Laptop (contoh: 192.168.1.x)
    return 'http://localhost:3000';
  }

  // --- LOGIN ---
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

        // Simpan token
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', accessToken);
        await prefs.setString('refresh_token', refreshToken);

        // MAPPING JSON KE USER MODEL (Sesuai user_model.dart terbaru)
        return User(
          uid: data['id']?.toString() ?? '', // Pastikan String
          email: data['email'] ?? '',
          name: data['name'] ?? 'No Name', // FIXED: displayName -> name
          phoneNumber: data['phone'], // Backend kirim 'phone', model terima 'phoneNumber'
          // Jika backend kirim format ISO String (yyyy-MM-dd...), simpan langsung
          dateOfBirth: data['birthDate'], 
          photoUrl: data['photoUrl'],
          hasPurchasedPackage: false, // Default, nanti diupdate logic payment
        );
      }
      return null;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message'] ?? 'Login failed');
      }
      throw Exception('Network error: Gagal terhubung ke server');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // --- REGISTER ---
  Future<String> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String birthDate, // Terima String (YYYY-MM-DD) agar lebih mudah dikirim
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
          'birthDate': birthDate,
          'referralCode': referralCode,
        },
      );

      if (response.statusCode == 201) {
        return response.data['message'] ?? 'Registration successful';
      }
      throw Exception(response.data['message'] ?? 'Registration failed');
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message'] ?? 'Registration failed');
      }
      throw Exception('Network error during registration');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // --- LOGOUT (HAPUS TOKEN) ---
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
    } catch (e) {
      // Ignore error saat logout lokal
    }
  }
}