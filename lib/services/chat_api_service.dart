import 'package:dio/dio.dart';

import '../config/api_config.dart';

class ChatApiService {
  ChatApiService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: ApiConfig.baseUrl,
                connectTimeout: const Duration(seconds: 20),
                receiveTimeout: const Duration(seconds: 20),
              ),
            );

  final Dio _dio;

  Future<String> sendMessage({
    required String message,
    String? accessToken,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.premiumChatEndpoint,
        data: {'message': message},
        options: Options(
          headers: {
            if (accessToken != null && accessToken.isNotEmpty)
              'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      return _pickReply(response.data).trim();
    } on DioException catch (e) {
      final msg = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['message']?.toString() ??
              e.response?.data['error']?.toString())
          : null;
      throw Exception(msg ?? 'Gagal mengirim pesan ke server.');
    } catch (e) {
      throw Exception('Gagal mengirim pesan: $e');
    }
  }

  // Meniru fleksibilitas pickReplyFromN8n di backend
  String _pickReply(dynamic payload) {
    if (payload == null) return '';
    if (payload is String) return payload;
    if (payload is Map<String, dynamic>) {
      return (payload['reply'] ??
              payload['ai_response'] ??
              payload['data']?['ai_response'] ??
              payload['output'] ??
              payload['text'] ??
              payload['content'] ??
              payload['message'] ??
              payload['data']?['reply'] ??
              payload['json']?['reply'])
          ?.toString() ??
          payload.toString();
    }
    if (payload is List) {
      for (final item in payload) {
        final val = _pickReply(item);
        if (val.isNotEmpty) return val;
      }
      return payload.toString();
    }
    return payload.toString();
  }
}
