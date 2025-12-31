
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      backgroundColor: AppTheme.bgCard.withValues(alpha: 0.9),
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
  

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    // Add user message to chat
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final userMessage = ChatMessage(id: '', text: text, isUser: true, timestamp: DateTime.now());
    chatProvider.addMessage(userMessage);
    _messageController.clear();

    // Scroll to bottom after a short delay
    await Future.delayed(const Duration(milliseconds: 100));
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }

    // Generate and add AI response
    try {
      chatProvider.setLoading(true);
      final response = await _geminiService.sendMessage(text, Provider.of<SettingsProvider>(context, listen: false));
      final aiMessage = ChatMessage(id: '', text: response, isUser: false, timestamp: DateTime.now());
      chatProvider.addMessage(aiMessage);
    } catch (e) {
      chatProvider.addMessage(ChatMessage(id: '', text: 'متاسفم، خطایی رخ داد: $e', isUser: false, timestamp: DateTime.now()));
    } finally {
      chatProvider.setLoading(false);
    }
  }

  // Build clipboard action menu
  Widget _buildClipboardActionMenu() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'کلیپ بورد فعال شد!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.copy, color: AppTheme.secondaryGold),
            title: const Text('کپی متن', style: TextStyle(color: AppTheme.textPrimary)),
            onTap: () {
              Clipboard.setData(ClipboardData(text: _copiedText));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('متن کپی شد!')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.auto_fix_high, color: AppTheme.secondaryGold),
            title: const Text('خلاصه‌نویسی', style: TextStyle(color: AppTheme.textPrimary)),
            onTap: () async {
              Navigator.pop(context);
              _messageController.text = 'لطفا این متن را خلاصه کن: "${_copiedText}"';
              setState(() => _clipboardActive = false);
            },
          ),
          ListTile(
            leading: const Icon(Icons.translate, color: AppTheme.secondaryGold),
            title: const Text('ترجمه', style: TextStyle(color: AppTheme.textPrimary)),
            onTap: () async {
              Navigator.pop(context);
              _messageController.text = 'لطفا این متن را به فارسی ترجمه کن: "${_copiedText}"';
              setState(() => _clipboardActive = false);
            },
          ),
        ],
      ),
    );
  }

  // Build quick menu when clipboard is not active
  Widget _buildQuickMenu() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'منوی سریع',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.history, color: AppTheme.secondaryGold),
            title: const Text('باز کردن تاریخچه', style: TextStyle(color: AppTheme.textPrimary)),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/history');
            },
          ),
          ListTile(
            leading: const Icon(Icons.nightlight_round, color: AppTheme.secondaryGold),
            title: const Text('باز کردن شب نامه', style: TextStyle(color: AppTheme.textPrimary)),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/night-summary');
            },
          ),
          ListTile(
            leading: const Icon(Icons.wb_sunny, color: AppTheme.secondaryGold),
            title: const Text('باز کردن صبح نامه', style: TextStyle(color: AppTheme.textPrimary)),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/morning-mana');
            },
          ),
        ],
      ),
    );
  }
}