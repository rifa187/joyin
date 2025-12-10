import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthApiService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // URL Backend
  // Gunakan 10.0.2.2 untuk Android Emulator, localhost untuk iOS/Web/Windows
  // Jika test di Real Device, gunakan IP Address laptop (misal 192.168.1.x)
  static final String baseUrlString =
      (kIsWeb || Platform.isWindows || Platform.isMacOS || Platform.isLinux)
          ? 'http://localhost:3000'
          : 'http://10.0.2.2:3000';

  static final String _baseUrl = baseUrlString;

  AuthApiService() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);

    // Interceptor untuk Log & Header Token
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        debugPrint('🌐 [API Request] ${options.method} ${options.path}');
        // Ambil token dari storage
        final token = await _storage.read(key: 'accessToken');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint('✅ [API Response] ${response.statusCode} ${response.data}');
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        debugPrint('❌ [API Error] ${e.response?.statusCode} ${e.message}');
        debugPrint('   Data: ${e.response?.data}');
        return handler.next(e);
      },
    ));
  }

  // --- LOGIN ---
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post('/api/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200 && response.data['status'] == true) {
        final data = response.data['data'];

        // Simpan token
        await _storage.write(key: 'accessToken', value: data['accessToken']);
        await _storage.write(key: 'refreshToken', value: data['refreshToken']);

        return data; // Return full user data + tokens
      } else {
        throw Exception(response.data['message'] ?? 'Login gagal');
      }
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // --- REGISTER ---
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    String? referralCode,
  }) async {
    try {
      final response = await _dio.post('/api/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
        'referralCode': referralCode,
      });

      if (response.statusCode == 201 && response.data['status'] == true) {
        return response.data; // Usually just a message
      } else {
        throw Exception(response.data['message'] ?? 'Register gagal');
      }
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // --- VERIFY OTP ---
  Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    try {
      final response = await _dio.post('/api/otp/verify', data: {
        'email': email,
        'otp': otp,
      });

      if (response.statusCode == 200 && response.data['status'] == true) {
        final data = response.data[
            'data']; // Expecting { user, accessToken, refreshToken } from backend

        // Simpan token jika backend mengirimnya di sini
        if (data['accessToken'] != null) {
          await _storage.write(key: 'accessToken', value: data['accessToken']);
          await _storage.write(
              key: 'refreshToken', value: data['refreshToken']);
        }

        return data;
      } else {
        throw Exception(response.data['message'] ?? 'Verifikasi OTP gagal');
      }
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // --- LOGOUT ---
  Future<void> logout() async {
    try {
      // Optional: Call backend logout
      // await _dio.post('/auth/logout');
    } catch (e) {
      // Ignore network error on logout
    } finally {
      await _storage.deleteAll();
    }
  }

  // --- GET PROFILE ---
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _dio.get('/api/profile');
      if (response.statusCode == 200 && response.data['status'] == true) {
        return response.data['data'];
      }
      throw Exception(response.data['message']);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // --- UPDATE PROFILE (TEXT) ---
  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String phone,
    // Add other fields if needed by backend (e.g. languagePreference)
  }) async {
    try {
      final response = await _dio.put('/api/profile', data: {
        'name': name,
        'phone': phone,
      });

      if (response.statusCode == 200 && response.data['status'] == true) {
        return response.data['data'];
      }
      throw Exception(response.data['message'] ?? 'Update gagal');
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // --- UPLOAD AVATAR ---
  // Gunakan XFile dari image_picker agar kompatibel dengan Web & Mobile
  Future<String> uploadAvatar(dynamic file) async {
    try {
      FormData? formData;

      // Handle XFile (Cross Platform)
      if (file.runtimeType.toString().contains('XFile')) {
        // Note: We avoid importing image_picker here to keep service clean,
        // but strictly we expect XFile.
        // Better approach: Read bytes in Provider and pass bytes, or pass XFile.
        // Let's assume input is XFile from image_picker.
        final xFile = file;
        final bytes = await xFile.readAsBytes();
        final fileName = xFile.name;

        formData = FormData.fromMap({
          'avatar': MultipartFile.fromBytes(
            bytes,
            filename: fileName,
          ),
        });
      } else if (file is File) {
        // Fallback for dart:io File
        String fileName = file.path.split('/').last;
        formData = FormData.fromMap({
          'avatar': await MultipartFile.fromFile(
            file.path,
            filename: fileName,
          ),
        });
      } else {
        throw Exception("Tipe file tidak didukung");
      }

      final response = await _dio.put('/api/profile/avatar', data: formData);

      if (response.statusCode == 200 && response.data['status'] == true) {
        // Backend returns { status: true, data: { avatar: "/uploads/..." } }
        return response.data['data']['avatar'];
      }
      throw Exception(response.data['message'] ?? 'Upload gagal');
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // --- GET STORED TOKEN ---
  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'accessToken');
  }

  // --- HELPER ERROR ---
  String _handleError(DioException e) {
    if (e.response != null) {
      final body = e.response?.data;
      if (body is Map && body.containsKey('message')) {
        return body['message'];
      }
      return 'Terjadi kesalahan: ${e.response?.statusCode}';
    }
    return 'Gagal terhubung ke server. Cek koneksi internet anda.';
  }
}
