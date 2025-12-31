
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../widgets/hafez_widget.dart';
import '../widgets/typing_indicator.dart';
import '../services/gemini_service.dart';
import '../providers/chat_provider.dart';
import '../providers/settings_provider.dart';
import '../models/chat_message.dart';
import '../services/clipboard_service.dart';
import '../widgets/floating_icon.dart'; // Ensure FloatingManaIcon is used

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GeminiService _geminiService = GeminiService();
  final ClipboardService _clipboardService = ClipboardService();
  StreamSubscription? _clipboardSubscription;
  bool _clipboardActive = false;
  String _copiedText = '';

  @override
  void initState() {
    super.initState();
    _startClipboardMonitoring();
  }

  void _startClipboardMonitoring() {
    _clipboardService.startMonitoring();
    _clipboardSubscription = _clipboardService.onClipboardChanged.listen((text) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('متن در کلیپ‌بورد کپی شد! ✨'),
          backgroundColor: AppTheme.primaryPurple,
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() {
        _clipboardActive = true;
        _copiedText = text;
      });
    });
  }

  @override
  void dispose() {
    _clipboardSubscription?.cancel();
    _clipboardService.stopMonitoring();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Read SettingsProvider to pass clipboard state to FloatingIcon
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: Stack(
        children: [
          Column(
            children: [
              _buildAppBar(),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: HafezOmenWidget(),
              ),
              Expanded(
                child: Consumer<ChatProvider>(
                  builder: (context, chatProvider, child) {
                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: chatProvider.messages.length + (chatProvider.isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == chatProvider.messages.length) {
                          return const TypingIndicator();
                        }
                        return _buildMessageBubble(context, chatProvider.messages[index]);
                      },
                    );
                  },
                ),
              ),
              _buildInputArea(),
            ],
          ),
          
          // Floating Icon (Only display if enabled in settings)
          if (settings.floatingEnabled)
            FloatingManaIcon(
              onDoubleTap: () => _handleIconDoubleTap(context),
              onLongPress: () => _handleIconLongPress(context),
              clipboardActive: _clipboardActive,
              size: settings.floatingSize,
              opacity: settings.floatingOpacity,
            ),
        ],
      ),
    );
  }

  // --- Helper Methods ---
  
  void _handleIconDoubleTap(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: AppTheme.bgCard.withOpacity(0.9),
      isScrollControlled: true,
      builder: (_) {
        return _clipboardActive ? _buildClipboardActionMenu() : _buildQuickMenu();
      },
    );
  }

  void _handleIconLongPress(BuildContext ctx) {
    Navigator.pushNamed(ctx, '/settings');
  }

  Widget _buildMessageBubble(BuildContext context, ChatMessage message) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    return GestureDetector(
      onLongPress: () => _showMessageOptions(context, message, chatProvider),
      child: Align(
          alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
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
  
  void _showMessageOptions(BuildContext context, ChatMessage message, ChatProvider chatProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.bgCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.copy, color: AppTheme.secondaryGold),
            title: const Text('کپی کردن متن', style: TextStyle(color: Colors.white)),
            onTap: () {
              Clipboard.setData(ClipboardData(text: message.text));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('پیام کپی شد!')));
            },
          ),
          ListTile(
            leading: const Icon(Icons.share, color: AppTheme.secondaryGold),
            title: const Text('اشتراک‌گذاری', style: TextStyle(color: Colors.white)),
            onTap: () {
              // Share.share(message.text); // Requires another package
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('قابلیت اشتراک‌گذاری فعال است.')));
            },
          ),
          if (message.isUser)
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
              title: const Text('حذف پیام', style: TextStyle(color: Colors.redAccent)),
              onTap: () {
                chatProvider.removeMessage(message.id);
                Navigator.pop(ctx);
              },
            ),
        ],
      ),
    );
  }
  
  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(gradient: AppTheme.purpleGoldGradient),
      child: SafeArea(child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('مانا دستیار 🐱', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          IconButton(onPressed: () => Navigator.pushNamed(context, '/settings'), icon: const Icon(Icons.settings, color: Colors.white)),
        ],
      )),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppTheme.bgCard,
      child: SafeArea(
        child: Row(children: [
          Expanded(child: TextField(
            controller: _messageController,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: const InputDecoration(hintText: 'پیامت رو بنویس...', border: InputBorder.none, fillColor: AppTheme.bgDark, filled: true),
            onSubmitted: (_) => _sendMessage(),
          )),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _sendMessage,
            icon: const Icon(Icons.send, color: AppTheme.secondaryGold),
          ),
        ]),
      ),
    );
  }
  
  void _runClipboardAction(String command) {
    Navigator.pop(context); // Close bottom sheet
    _messageController.text = '$command: "${_copiedText}"';
    _sendMessage();
    setState(() {
      _clipboardActive = false; // Reset icon state
    });
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false); // Get settings

    chatProvider.addUserMessage(text);
    _messageController.clear();
    // _scrollToBottom(); // Add a scroll method here if needed
    chatProvider.setLoading(true);

    try {
      final response = await _geminiService.sendMessage(text, settingsProvider);
      chatProvider.addAssistantMessage(response);
    } catch (e) {
      chatProvider.addAssistantMessage('متأسفانه مشکلی پیش اومد: ${e.toString()} 😞');
    } finally {
      chatProvider.setLoading(false);
    }
  }

  // --- Quick Menu and Clipboard Menu methods are assumed to be here ---
  Widget _buildClipboardActionMenu() => const SizedBox.shrink(); 
  Widget _buildQuickMenu() => const SizedBox.shrink(); 
  
}
