import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../config/api_config.dart';

class ProfileApiService {
  final Dio _dio = Dio();

  ProfileApiService() {
    _dio.options.baseUrl = ApiConfig.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
  }

  /// GET /users/me
  Future<Map<String, dynamic>> me(String accessToken) async {
    try {
      final response = await _dio.get(
        '/users/me',
        options: Options(headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
        }),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception('GetMe gagal: ${e.message}');
    }
  }

  /// PUT /users/me (Update Profile)
  Future<Map<String, dynamic>> updateProfile(
      String accessToken, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(
        '/users/me',
        data: data,
        options: Options(headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
        }),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception('Update gagal: ${e.message}');
    }
  }

  /// POST /users/me/avatar (Upload Avatar)
  Future<Map<String, dynamic>> uploadAvatar(
      String accessToken, XFile file) async {
    try {
      String fileName = file.path.split('/').last;
      FormData formData = FormData.fromMap({
        "avatar": await MultipartFile.fromFile(file.path, filename: fileName),
      });

      final response = await _dio.post(
        '/users/me/avatar',
        data: formData,
        options: Options(headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
        }),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception('Upload gagal: ${e.message}');
    }
  }
}
