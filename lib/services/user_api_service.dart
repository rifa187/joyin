import 'package:dio/dio.dart';
import 'api_client.dart';

class UserApiService {
  UserApiService(this.client);
  final ApiClient client;

  Future<Map<String, dynamic>> fetchMe() async {
    try {
      final res = await client.dio.get('/users/me');
      if (res.data is Map<String, dynamic>) {
        return res.data as Map<String, dynamic>;
      }
      throw Exception('Response /users/me tidak valid');
    } on DioException catch (e) {
      final msg = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['message'] ?? e.message)
          : e.message;
      throw Exception('Gagal mengambil profil: $msg');
    }
  }
}
