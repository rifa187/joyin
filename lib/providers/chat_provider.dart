import 'package:flutter/material.dart';

import '../chat/chat_message.dart';
import '../services/chat_service.dart';
import 'auth_provider.dart';

class ChatProvider extends ChangeNotifier {
  ChatProvider({
    ChatService? service,
  }) : _service = service ?? ChatService();

  final ChatService _service;

  AuthProvider? _authProvider;
  bool _isSending = false;
  String? _error;
  final List<ChatMessage> _messages = [];

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isSending => _isSending;
  String? get error => _error;

  void bindAuth(AuthProvider auth) {
    _authProvider = auth;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    final message = text.trim();
    if (message.isEmpty || _isSending) return;

    _isSending = true;
    _error = null;
    final now = DateTime.now();
    final userMsg = ChatMessage(
      id: 'user-${now.microsecondsSinceEpoch}',
      sender: ChatSender.user,
      content: message,
      timestamp: now,
    );
    _messages.add(userMsg);
    notifyListeners();

    try {
      final reply = await _service.sendToBot(
        message: message,
        accessToken: _authProvider?.accessToken,
      );

      _messages.add(
        ChatMessage(
          id: 'bot-${DateTime.now().microsecondsSinceEpoch}',
          sender: ChatSender.bot,
          content: reply.isEmpty
              ? 'Bot tidak mengirim balasan.'
              : reply,
          timestamp: DateTime.now(),
        ),
      );
    } catch (e) {
      _error = e.toString();
      _messages.add(
        ChatMessage(
          id: 'bot-error-${DateTime.now().microsecondsSinceEpoch}',
          sender: ChatSender.bot,
          content: 'Gagal menghubungi server: ${e.toString()}',
          timestamp: DateTime.now(),
        ),
      );
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }
}
