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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final viewModel = context.watch<ChatViewModel>();

    return Scaffold(
      // Menggunakan Stack untuk tumpukan background dan konten
      body: Stack(
        children: [

          // 2. Konten Utama
          Column(
            children: [
              // Custom AppBar yang lebih mewah
              _buildCustomAppBar(context, viewModel),

              // Chat List Area
              Expanded(
                child: viewModel.messages.isEmpty
                    ? _buildEmptyState(colorScheme)
                    : ListView.builder(
                        controller: viewModel.scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 20,
                        ),
                        itemCount: viewModel.messages.length,
                        itemBuilder: (context, i) {
                          final msg = viewModel.messages[i];
                          // Melemparkan context ke fungsi bubble agar tidak merah
                          return _buildChatBubble(
                            msg,
                            colorScheme,
                            theme,
                            context,
                          );
                        },
                      ),
              ),

              // Loading Indicator saat AI berfikir
              if (viewModel.isLoading) _buildLoadingIndicator(colorScheme),

              // Input Field di bagian bawah
              _buildInputArea(colorScheme, viewModel),
            ],
          ),
        ],
      ),
    );
  }

  // Widget AppBar Custom
  Widget _buildCustomAppBar(BuildContext context, ChatViewModel viewModel) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.only(top: 40, bottom: 15, left: 16, right: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: colorScheme.primary.withOpacity(0.1),
            child: Icon(Icons.auto_awesome, color: colorScheme.primary),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Alettia AI',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Online | Gemini Flash',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => viewModel.clearChat(),
            icon: Icon(Icons.delete_sweep_outlined, color: Colors.red[300]),
          ),
        ],
      ),
    );
  }

  // Widget Bubble Chat (Perbaikan: Menerima BuildContext)
  Widget _buildChatBubble(msg, colorScheme, theme, BuildContext context) {
    final isUser = msg.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: BoxConstraints(
          maxWidth:
              MediaQuery.of(context).size.width *
              (msg.text.length > 50 ? 0.8 : 0.7),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          gradient: isUser
              ? LinearGradient(
                  colors: [
                    colorScheme.primary,
                    colorScheme.primary.withBlue(220),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isUser ? null : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 20),
          ),
          boxShadow: [
            BoxShadow(
              color: isUser
                  ? colorScheme.primary.withOpacity(0.2)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          msg.text,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black87,
            fontSize: 15,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  // Tampilan saat chat masih kosong
  Widget _buildEmptyState(colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: colorScheme.primary.withOpacity(0.1),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada percakapan',
            style: TextStyle(
              color: Colors.grey[400],
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Tanya Alettia tentang Islam, Al-Quran, atau doa.',
            style: TextStyle(color: Colors.grey[400], fontSize: 12),
          ),
        ],
      ),
    );
  }

  // Indicator saat menunggu respon AI
  Widget _buildLoadingIndicator(colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Alettia sedang mengetik...',
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.primary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  // Area Input Pesan
  Widget _buildInputArea(colorScheme, viewModel) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: colorScheme.primary.withOpacity(0.1)),
              ),
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'Tanyakan sesuatu...',
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _send(viewModel),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _send(viewModel),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
