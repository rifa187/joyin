import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class HealthService {
  Uri _url() => Uri.parse('${ApiConfig.baseUrl}/health');

  Future<Map<String, dynamic>> check() async {
    final res = await http.get(_url(), headers: {
      'Accept': 'application/json',
    });

    if (res.statusCode >= 200 && res.statusCode < 300) {
      // kalau backend balikin JSON
      try {
        final decoded = jsonDecode(res.body);
        if (decoded is Map<String, dynamic>) return decoded;
        return {'data': decoded};
      } catch (_) {
        // kalau backend balikin teks biasa
        return {'message': res.body};
      }
    }

    throw Exception('Health gagal: ${res.statusCode} ${res.body}');
  }
}
