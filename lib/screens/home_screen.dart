import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../widgets/floating_icon.dart';
import '../widgets/typing_indicator.dart';
import '../services/gemini_service.dart';
import '../services/hafez_service.dart';
import '../providers/chat_provider.dart';
import '../providers/user_provider.dart';
import '../models/chat_message.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GeminiService _geminiService = GeminiService();
  bool _clipboardActive = false;

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    if (chatProvider.messages.isEmpty) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userName = userProvider.userProfile?.name ?? 'عزیزم';
      
      chatProvider.addAssistantMessage(
        'سلام $userName! من مانا هستم 🐱✨\nچطور می‌تونم کمکت کنم؟',
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: Stack(
        children: [
          // صفحه چت
          Column(
            children: [
              // AppBar
              _buildAppBar(),
              
              // لیست پیام‌ها
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
                        if (index == chatProvider.messages.length && chatProvider.isLoading) {
                          return const TypingIndicator();
                        }
                        final message = chatProvider.messages[index];
                        return _buildMessageBubble(message)
                            .animate(delay: Duration(milliseconds: index * 50))
                            .fadeIn()
                            .slideX(begin: message.isUser ? 0.2 : -0.2, end: 0);
                      },
                    );
                  },
                ),
              ),
              
              // Input Area
              _buildInputArea(),
            ],
          ),
          
          // آیکون شناور
          FloatingManaIcon(
            onDoubleTap: _handleDoubleTap,
            onLongPress: _handleLongPress,
            clipboardActive: _clipboardActive,
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: AppTheme.purpleGoldGradient,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPurple.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Icon(
                Icons.pets,
                color: AppTheme.primaryPurple,
                size: 30,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'مانا',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'دستیار هوشمند شما',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: _clearChat,
              icon: const Icon(Icons.refresh, color: Colors.white),
              tooltip: 'شروع مجدد',
            ),
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/settings');
              },
              icon: const Icon(Icons.settings, color: Colors.white),
              tooltip: 'تنظیمات',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.purpleGoldGradient,
            ),
            child: const Icon(
              Icons.pets,
              size: 60,
              color: Colors.white,
            ),
          )
              .animate(onPlay: (controller) => controller.repeat())
              .scale(duration: 2000.ms, begin: const Offset(1, 1), end: const Offset(1.1, 1.1)),
          const SizedBox(height: 24),
          Text(
            'سلام! من مانا هستم 🐱',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'چطور می‌تونم کمکت کنم؟',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: message.isUser
              ? AppTheme.purpleGoldGradient
              : null,
          color: message.isUser
              ? null
              : AppTheme.bgCard,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(message.isUser ? 20 : 4),
            bottomRight: Radius.circular(message.isUser ? 4 : 20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: message.isUser ? Colors.white : AppTheme.textPrimary,
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                color: message.isUser
                    ? Colors.white70
                    : AppTheme.textSecondary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  hintText: 'پیامت رو بنویس...',
                  hintStyle: TextStyle(color: AppTheme.textSecondary),
                  filled: true,
                  fillColor: AppTheme.bgDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                gradient: AppTheme.purpleGoldGradient,
                shape: BoxShape.circle,
              ),
              child: Consumer<ChatProvider>(
                builder: (context, chatProvider, child) {
                  return IconButton(
                    onPressed: chatProvider.isLoading ? null : _sendMessage,
                    icon: chatProvider.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.send, color: Colors.white),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    if (chatProvider.isLoading) return;

    // افزودن پیام کاربر
    chatProvider.addUserMessage(text);
    _messageController.clear();
    _scrollToBottom();

    // تنظیم loading
    chatProvider.setLoading(true);

    try {
      // بررسی نوع پیام
      String response;
      MessageType? messageType;
      Map<String, dynamic>? metadata;

      if (text.toLowerCase().contains('فال') || text.toLowerCase().contains('حافظ')) {
        // فال حافظ
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final userProfile = userProvider.userProfile;
        
        final fortune = HafezService.getFortuneByQuestion(text);
        final ghazal = fortune['text'] ?? '';
        
        response = await _geminiService.interpretHafez(
          ghazal: ghazal,
          userQuestion: text,
          userProfile: {
            'name': userProfile?.name ?? '',
            'ageGroup': userProfile?.ageGroup ?? '',
            'birthMonth': userProfile?.birthMonth ?? '',
          },
        );
        messageType = MessageType.hafezFortune;
        metadata = {'ghazal': ghazal};
      } else if (text.toLowerCase().contains('کپشن') || 
                 text.toLowerCase().contains('بیو') || 
                 text.toLowerCase().contains('هشتگ')) {
        // تولید محتوا
        final type = text.toLowerCase().contains('کپشن') 
            ? 'caption' 
            : text.toLowerCase().contains('بیو') 
                ? 'bio' 
                : 'hashtag';
        
        response = await _geminiService.generateContent(
          type: type,
          topic: text,
        );
        messageType = MessageType.contentGeneration;
      } else if (text.toLowerCase().contains('خلاصه')) {
        // خلاصه‌سازی
        response = await _geminiService.summarizeText(text);
        messageType = MessageType.summary;
      } else {
        // پیام عادی
        response = await _geminiService.sendMessage(text);
        messageType = MessageType.text;
      }

      // افزودن پاسخ دستیار
      chatProvider.addAssistantMessage(
        response,
        type: messageType,
        metadata: metadata,
      );
      chatProvider.setLoading(false);
    } catch (e) {
      chatProvider.addAssistantMessage(
        'متأسفانه مشکلی پیش اومد. لطفاً دوباره امتحان کن! 😞',
      );
      chatProvider.setLoading(false);
      chatProvider.setError(e.toString());
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _clearChat() async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    await chatProvider.clearChat();
    _geminiService.resetChat();
    _addWelcomeMessage();
  }

  void _handleDoubleTap() {
    // باز کردن منوی سریع
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildQuickMenu(),
    );
  }

  void _handleLongPress() {
    // تغییر آیکون یا تنظیمات
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('آیکون مانا 🐱✨'),
        backgroundColor: AppTheme.primaryPurple,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildQuickMenu() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'منوی سریع',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildQuickMenuItem(
            icon: Icons.auto_awesome,
            title: 'فال حافظ',
            onTap: () {
              Navigator.pop(context);
              _getHafezFortune();
            },
          ),
          _buildQuickMenuItem(
            icon: Icons.edit,
            title: 'کپشن اینستاگرام',
            onTap: () {
              Navigator.pop(context);
              _sendQuickMessage('یه کپشن برای اینستاگرام بنویس');
            },
          ),
          _buildQuickMenuItem(
            icon: Icons.summarize,
            title: 'خلاصه متن',
            onTap: () {
              Navigator.pop(context);
              _sendQuickMessage('این متن رو خلاصه کن:');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: AppTheme.purpleGoldGradient,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(color: AppTheme.textPrimary),
      ),
      onTap: onTap,
    );
  }

  void _sendQuickMessage(String message) {
    _messageController.text = message;
    _sendMessage();
  }

  Future<void> _getHafezFortune() async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    if (chatProvider.isLoading) return;

    // افزودن پیام کاربر
    chatProvider.addUserMessage('فال حافظ بگیر');
    _scrollToBottom();

    chatProvider.setLoading(true);

    try {
      final userProfile = userProvider.userProfile;
      final fortune = userProfile?.birthMonth != null
          ? HafezService.getFortuneByMonth(userProfile!.birthMonth)
          : HafezService.getRandomFortune();
      
      final ghazal = fortune['text'] ?? '';
      final response = await _geminiService.interpretHafez(
        ghazal: ghazal,
        userQuestion: 'فال حافظ',
        userProfile: {
          'name': userProfile?.name ?? '',
          'ageGroup': userProfile?.ageGroup ?? '',
          'birthMonth': userProfile?.birthMonth ?? '',
        },
      );

      chatProvider.addAssistantMessage(
        response,
        type: MessageType.hafezFortune,
        metadata: {'ghazal': ghazal},
      );
      chatProvider.setLoading(false);
    } catch (e) {
      chatProvider.addAssistantMessage(
        'متأسفانه نتونستم فال رو بگیرم. لطفاً دوباره امتحان کن! 😞',
      );
      chatProvider.setLoading(false);
      chatProvider.setError(e.toString());
    }

    _scrollToBottom();
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

