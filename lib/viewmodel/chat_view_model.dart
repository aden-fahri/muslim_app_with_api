import 'package:flutter/material.dart';
import 'package:muslim_app/model/chat_message_model.dart';
import 'package:muslim_app/repository/chat_repository.dart';

class ChatViewModel extends ChangeNotifier {
  final ChatRepository _repository;

  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _error;

  // Tambahkan ScrollController agar bisa dikontrol dari ViewModel
  final ScrollController scrollController = ScrollController();

  // Memperbaiki constructor
  ChatViewModel(this._repository);

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> sendMessage(String text) async {
    text = text.trim();
    if (text.isEmpty) return;

    _error = null;
    _messages.add(ChatMessage(text: text, isUser: true));
    _isLoading = true;

    notifyListeners();
    _scrollToBottom(); // Scroll otomatis setelah user kirim pesan

    try {
      final response = await _repository.sendMessage(text);
      _messages.add(ChatMessage(text: response, isUser: false));
    } catch (e) {
      _error = e.toString();
      _messages.add(
        ChatMessage(
          text: 'Maaf, terjadi gangguan koneksi. Coba lagi nanti.',
          isUser: false,
        ),
      );
    }

    _isLoading = false;
    notifyListeners();
    _scrollToBottom(); // Scroll otomatis setelah AI menjawab
  }

  // --- FITUR CLEAR CHAT ---
  void clearChat() {
    _messages.clear();
    _error = null;
    notifyListeners();
  }

  // --- FITUR AUTO SCROLL ---
  void _scrollToBottom() {
    // Memberikan sedikit delay agar UI selesai merender item baru sebelum di-scroll
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
