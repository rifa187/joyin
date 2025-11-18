import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/*
ApiClient adalah "jantung" dari koneksi aplikasi Anda ke backend.
ApiClient menggunakan pola Singleton untuk memastikan hanya ada SATU instance
Dio yang mengelola semua koneksi.

Fitur utamanya adalah "Interceptor" yang bekerja seperti middleware:
1. SECARA OTOMATIS menambahkan 'Authorization' (Access Token) ke setiap request.
2. SECARA OTOMATIS mendeteksi error 401 (Unauthorized) saat Access Token kedaluwarsa.
3. SECARA OTOMATIS memanggil endpoint '/auth/refresh' menggunakan Refresh Token.
4. SECARA OTOMATIS menyimpan token baru dan mengulangi request yang gagal.
5. Jika Refresh Token juga gagal, ia akan menghapus token dan (nantinya) bisa 
   mengarahkan pengguna ke halaman Login.
*/

class ApiClient {
  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(milliseconds: 5000),
        receiveTimeout: const Duration(milliseconds: 5000),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          final accessToken = await _storage.read(key: 'accessToken');
          if (accessToken != null) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            debugPrint('Token kedaluwarsa. Mencoba refresh...');

            final refreshToken = await _storage.read(key: 'refreshToken');
            if (refreshToken == null) {
              debugPrint('Refresh token tidak ada. Logout.');
              await _clearTokens();
              return handler.next(e);
            }

            try {
              final refreshDio = Dio(BaseOptions(baseUrl: _baseUrl));
              final refreshResponse = await refreshDio.post(
                '/auth/refresh',
                data: {'refreshToken': refreshToken},
              );

              if (refreshResponse.statusCode == 200) {
                final data = refreshResponse.data;
                if (data is Map<String, dynamic>) {
                  final newAccessToken = data['accessToken'] as String?;
                  final newRefreshToken = data['refreshToken'] as String?;

                  if (newAccessToken != null && newRefreshToken != null) {
                    await _persistTokens(
                      accessToken: newAccessToken,
                      refreshToken: newRefreshToken,
                    );

                    final originalRequest = e.requestOptions;
                    originalRequest.headers['Authorization'] =
                        'Bearer $newAccessToken';

                    final response = await _dio.fetch(originalRequest);
                    return handler.resolve(response);
                  }
                }
              }

              debugPrint(
                'Refresh token gagal dengan status ${refreshResponse.statusCode}',
              );
            } catch (refreshError, stackTrace) {
              debugPrint('Refresh token error: $refreshError');
              debugPrintStack(stackTrace: stackTrace);
            }

            await _clearTokens();
          }

          return handler.next(e);
        },
      ),
    );
  }

  static final ApiClient _instance = ApiClient._internal();

  factory ApiClient() => _instance;

  late final Dio _dio;
  final _storage = const FlutterSecureStorage();

  static const String _baseUrl = 'http://10.0.2.2:3000/api/v1';

  Dio get client => _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<void> _persistTokens({
    String? accessToken,
    String? refreshToken,
  }) async {
    if (accessToken != null) {
      await _storage.write(key: 'accessToken', value: accessToken);
    }
    if (refreshToken != null) {
      await _storage.write(key: 'refreshToken', value: refreshToken);
    }
  }

  Future<void> _clearTokens() async {
    await _storage.delete(key: 'accessToken');
    await _storage.delete(key: 'refreshToken');
  }
}
