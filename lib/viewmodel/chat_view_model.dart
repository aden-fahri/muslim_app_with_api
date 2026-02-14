import 'package:flutter/material.dart';
import 'package:muslim_app/model/chat_message_model.dart';
import 'package:muslim_app/repository/chat_repository.dart';

class ChatViewModel extends ChangeNotifier {
  final ChatRepository _repository = ChatRepository();

  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  ChatViewModel(ChatRepository read);

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;

  Future<void> sendMessage(String text) async {
    text = text.trim();
    if (text.isEmpty) return;

    _messages.add(ChatMessage(text: text, isUser: true));
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _repository.sendMessage(text);
      _messages.add(ChatMessage(text: response, isUser: false));
    } catch (e) {
      _messages.add(
        ChatMessage(text: 'Maaf, ada kesalahan: $e', isUser: false),
      );
    }

    _isLoading = false;
    notifyListeners();
  }
}
