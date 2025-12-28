import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../hpp/hpp_model.dart';

class HppApiException implements Exception {
  final String message;
  final int? statusCode;

  const HppApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class HppApiService {
  HppApiService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: ApiConfig.baseUrl,
                connectTimeout: const Duration(seconds: 20),
                receiveTimeout: const Duration(seconds: 20),
              ),
            );

  final Dio _dio;

  Future<List<HppItem>> fetchItems(String accessToken) async {
    try {
      final response = await _dio.get(
        '/hpp',
        options: Options(headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
        }),
      );

      final payload = response.data;
      final data = payload is Map<String, dynamic> ? payload['data'] : payload;
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(HppItem.fromJson)
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw _toException(e, fallback: 'Gagal memuat data HPP.');
    }
  }

  Future<HppItem> createItem({
    required String accessToken,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final response = await _dio.post(
        '/hpp',
        data: payload,
        options: Options(headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
        }),
      );
      final data = response.data;
      final item = data is Map<String, dynamic> ? data['data'] : data;
      if (item is Map<String, dynamic>) {
        return HppItem.fromJson(item);
      }
      throw const HppApiException('Format response tidak dikenali.');
    } on DioException catch (e) {
      throw _toException(e, fallback: 'Gagal membuat HPP.');
    }
  }

  Future<HppItem> fetchItem({
    required String accessToken,
    required int id,
  }) async {
    try {
      final response = await _dio.get(
        '/hpp/$id',
        options: Options(headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
        }),
      );
      final data = response.data;
      final item = data is Map<String, dynamic> ? data['data'] : data;
      if (item is Map<String, dynamic>) {
        return HppItem.fromJson(item);
      }
      throw const HppApiException('Format response tidak dikenali.');
    } on DioException catch (e) {
      throw _toException(e, fallback: 'Gagal memuat detail HPP.');
    }
  }

  Future<HppItem> updateItem({
    required String accessToken,
    required int id,
    required Map<String, dynamic> payload,
  }) async {
    try {
      final response = await _dio.put(
        '/hpp/$id',
        data: payload,
        options: Options(headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
        }),
      );
      final data = response.data;
      final item = data is Map<String, dynamic> ? data['data'] : data;
      if (item is Map<String, dynamic>) {
        return HppItem.fromJson(item);
      }
      throw const HppApiException('Format response tidak dikenali.');
    } on DioException catch (e) {
      throw _toException(e, fallback: 'Gagal memperbarui HPP.');
    }
  }

  Future<void> deleteItem({
    required String accessToken,
    required int id,
  }) async {
    try {
      await _dio.delete(
        '/hpp/$id',
        options: Options(headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
        }),
      );
    } on DioException catch (e) {
      throw _toException(e, fallback: 'Gagal menghapus HPP.');
    }
  }

  HppApiException _toException(DioException e, {required String fallback}) {
    final statusCode = e.response?.statusCode;
    final responseData = e.response?.data;
    String message = fallback;

    if (responseData is Map<String, dynamic>) {
      message = responseData['message']?.toString() ??
          responseData['error']?.toString() ??
          fallback;
    }

    return HppApiException(message, statusCode: statusCode);
  }
}
