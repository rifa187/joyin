import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';

class AuthService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AuthService() {
    _dio.options.baseUrl = ApiConfig.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
  }

  // Kirim OTP
  Future<bool> sendOtp(String phoneNumber) async {
    try {
      final response = await _dio.post(
        ApiConfig.sendOtpEndpoint,
        data: {'phone': phoneNumber},
      );

      // Asumsi backend mengembalikan 200 OK jika berhasil
      return response.statusCode == 200;
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'Gagal mengirim OTP: ${e.message}');
    } catch (e) {
      throw Exception("Terjadi kesalahan koneksi");
    }
  }

  // Verifikasi OTP
  Future<bool> verifyOtp(String phoneNumber, String otp) async {
    try {
      final response = await _dio.post(
        ApiConfig.verifyOtpEndpoint,
        data: {
          'phone': phoneNumber,
          'otp': otp,
        },
      );

      if (response.statusCode == 200) {
        // Simpan token jika ada (contoh: response.data['token'])
        // await _storage.write(key: 'token', value: response.data['token']);
        return true;
      }
      return false;
    } on DioException catch (e) {
      throw Exception(
          e.response?.data['message'] ?? 'OTP Salah atau Gagal: ${e.message}');
    } catch (e) {
      throw Exception("Terjadi kesalahan koneksi");
    }
  }

  // Logout (Opsional)
  Future<void> logout() async {
    await _storage.deleteAll();
  }
}
