import 'package:dio/dio.dart';

import '../config/api_config.dart';

class ReferralApiService {
  final Dio _dio = Dio();

  ReferralApiService() {
    _dio.options.baseUrl = ApiConfig.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
  }

  Future<Map<String, dynamic>> getMyReferralDetails(String accessToken) async {
    try {
      final response = await _dio.get(
        '/referrals/me',
        options: Options(headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
        }),
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception('Ambil referral gagal: ${e.message}');
    }
  }
}
