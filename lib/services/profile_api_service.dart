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

  /// GET /profile
  Future<Map<String, dynamic>> me(String accessToken) async {
    try {
      final response = await _dio.get(
        '/profile',
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

  /// PUT /profile (Update Profile)
  Future<Map<String, dynamic>> updateProfile(
      String accessToken, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(
        '/profile',
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

  /// PUT /profile/avatar (Upload Avatar)
  Future<Map<String, dynamic>> uploadAvatar(
      String accessToken, XFile file) async {
    try {
      String fileName = file.path.split('/').last;
      FormData formData = FormData.fromMap({
        "avatar": await MultipartFile.fromFile(file.path, filename: fileName),
      });

      final response = await _dio.put(
        '/profile/avatar',
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
