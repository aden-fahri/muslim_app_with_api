import 'package:flutter/material.dart';
import 'package:muslim_app/viewmodel/chat_view_model.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatelessWidget {
  ChatPage({super.key});

  final TextEditingController _controller = TextEditingController();

  void _send(ChatViewModel vm) {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      vm.sendMessage(text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ChatViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Asisten Muslim - Gemini')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: viewModel.messages.length,
              itemBuilder: (context, i) {
                final msg = viewModel.messages[i];
                return Align(
                  alignment: msg.isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: msg.isUser ? Colors.indigo[100] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(msg.text),
                  ),
                );
              },
            ),
          ),
          if (viewModel.isLoading) const LinearProgressIndicator(),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(viewModel),
                    decoration: InputDecoration(
                      hintText: 'Tanya tentang Islam...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  icon: const Icon(Icons.send),
                  onPressed: () => _send(viewModel),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
