import 'package:dio/dio.dart';
import 'api_client.dart';

class AuthApiService {
  AuthApiService(this.client);
  final ApiClient client;

  Future<String> login(String email, String password) async {
    try {
      final res = await client.dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      final data = res.data as Map<String, dynamic>;
      final token = data['token'] ?? data['access_token'];
      if (token is! String || token.isEmpty) {
        throw Exception('Token tidak ditemukan di response login.');
      }
      return token;
    } on DioException catch (e) {
      final msg = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['message'] ?? e.message)
          : e.message;
      throw Exception('Login gagal: $msg');
    }
  }
}
