import 'package:muslim_app/services/gemini_service.dart';

class ChatRepository {
  final GeminiService _service = GeminiService();

  Future<String> sendMessage(String message) async {
    return await _service.getResponse(message);
  }
}
