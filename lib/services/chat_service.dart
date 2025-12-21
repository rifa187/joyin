import 'chat_api_service.dart';
import 'token_storage.dart';

class ChatService {
  ChatService({ChatApiService? api, TokenStorage? tokenStorage})
      : _api = api ?? ChatApiService(),
        _tokenStorage = tokenStorage ?? TokenStorage();

  final ChatApiService _api;
  final TokenStorage _tokenStorage;

  Future<String> sendToBot({
    required String message,
    String? accessToken,
  }) async {
    final token = accessToken?.isNotEmpty == true
        ? accessToken
        : await _tokenStorage.getAccessToken();
    return _api.sendMessage(
      message: message,
      accessToken: token,
    );
  }
}
