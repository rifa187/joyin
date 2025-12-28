import '../core/api_client.dart';

class SnapTransactionResult {
  final String token;
  final String orderId;

  const SnapTransactionResult({
    required this.token,
    required this.orderId,
  });
}

class PaymentApiService {
  final ApiClient _client;

  PaymentApiService({ApiClient? client}) : _client = client ?? ApiClient();

  Future<SnapTransactionResult> createSnapTransaction({
    required String planId,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/payments/snap',
      data: {'planId': planId},
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final payload = data['data'];
      if (payload is Map<String, dynamic>) {
        final token = payload['transaction_token']?.toString();
        final orderId = payload['order_id']?.toString();
        if (token != null && token.isNotEmpty && orderId != null && orderId.isNotEmpty) {
          return SnapTransactionResult(token: token, orderId: orderId);
        }
      }
    }
    throw Exception('Token transaksi tidak ditemukan.');
  }

  Future<Map<String, dynamic>> syncSnapPayment({
    required String orderId,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/payments/snap/sync',
      data: {'orderId': orderId},
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final payload = data['data'];
      if (payload is Map<String, dynamic>) {
        return payload;
      }
    }
    return {};
  }
}
