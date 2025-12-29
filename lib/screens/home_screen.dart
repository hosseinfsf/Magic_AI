
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../widgets/hafez_widget.dart';
import '../widgets/typing_indicator.dart';
import '../services/gemini_service.dart';
import '../providers/chat_provider.dart';
import '../providers/settings_provider.dart'; // To use settings
import '../models/chat_message.dart';
import '../services/clipboard_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GeminiService _geminiService = GeminiService();
  // ... (Clipboard state remains the same)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: Column(
        children: [
          _buildAppBar(),
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                if (chatProvider.messages.isEmpty) {
                  return _buildEmptyState();
                }
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: chatProvider.messages.length + (chatProvider.isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == chatProvider.messages.length) {
                      return const TypingIndicator();
                    }
                    final message = chatProvider.messages[index];
                    // Use the new message bubble widget
                    return _buildMessageBubble(context, message);
                  },
                );
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  // Updated message bubble to include a popup menu
  Widget _buildMessageBubble(BuildContext context, ChatMessage message) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    return GestureDetector(
      onLongPress: () {
        final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
        showMenu(
          context: context,
          position: RelativeRect.fromRect(
            _getTapPosition(context), 
            Offset.zero & overlay.size
          ),
          items: [
            const PopupMenuItem(
              value: 'copy',
              child: Row(children: [Icon(Icons.copy, size: 20), SizedBox(width: 8), Text('کپی کردن')]),
            ),
            if (message.isUser) // Can only delete user messages
              const PopupMenuItem(
                value: 'delete',
                child: Row(children: [Icon(Icons.delete_outline, size: 20, color: Colors.red), SizedBox(width: 8), Text('حذف')]),
              ),
          ],
          color: AppTheme.bgCard,
        ).then((value) {
          if (value == 'copy') {
            Clipboard.setData(ClipboardData(text: message.text));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('پیام کپی شد!')),
            );
          } else if (value == 'delete') {
            chatProvider.removeMessage(message.id);
          }
        });
      },
      child: Align(
          // ... (the rest of the message bubble UI remains the same)
          alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: message.isUser ? AppTheme.purpleGoldGradient : null,
              color: message.isUser ? null : AppTheme.bgCard,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(message.text, style: TextStyle(color: message.isUser ? Colors.white : AppTheme.textPrimary)),
          ),
      ),
    );
  }
  
  // Helper to get tap position for the menu
  Rect _getTapPosition(BuildContext context) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    return Rect.fromLTWH(offset.dx, offset.dy, renderBox.size.width, renderBox.size.height);
  }

  // Other methods (_buildAppBar, _buildInputArea, _sendMessage, etc.)
  // ... (Implementations for other methods are assumed to be here)
  Widget _buildAppBar() => const SizedBox.shrink(); // Placeholder
  Widget _buildEmptyState() => const Center(child: Text('پیامی نیست')); // Placeholder
  Widget _buildInputArea() => const SizedBox.shrink(); // Placeholder

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);

    chatProvider.addUserMessage(text);
    _messageController.clear();
    chatProvider.setLoading(true);

    try {
      final response = await _geminiService.sendMessage(text, settingsProvider);
      chatProvider.addAssistantMessage(response);
    } finally {
      chatProvider.setLoading(false);
    }
  }
}
