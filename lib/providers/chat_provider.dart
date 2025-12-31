import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/chat_message.dart';

/// Provider برای مدیریت چت
class ChatProvider with ChangeNotifier {
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;

  List<ChatMessage> get messages => _messages;

  bool get isLoading => _isLoading;

  bool get hasError => _hasError;

  String? get errorMessage => _errorMessage;

  // بارگذاری پیام‌ها از SharedPreferences
  Future<void> loadMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = prefs.getString('chat_messages');

      if (messagesJson != null) {
        final List<dynamic> messagesList = json.decode(messagesJson);
        _messages = messagesList
            .map((msg) => ChatMessage.fromJson(msg as Map<String, dynamic>))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading messages: $e');
    }
  }

  // ذخیره پیام‌ها
  Future<void> _saveMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = json.encode(
        _messages.map((msg) => msg.toJson()).toList(),
      );
      await prefs.setString('chat_messages', messagesJson);
    } catch (e) {
      debugPrint('Error saving messages: $e');
    }
  }

  // افزودن پیام
  void addMessage(ChatMessage message) {
    _messages.add(message);
    _hasError = false;
    _errorMessage = null;
    _saveMessages();
    notifyListeners();
  }

  // افزودن پیام کاربر
  void addUserMessage(String text) {
    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
      type: MessageType.text,
    );
    addMessage(message);
  }

  // افزودن پیام دستیار
  void addAssistantMessage(String text,
      {MessageType? type, Map<String, dynamic>? metadata}) {
    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: false,
      timestamp: DateTime.now(),
      type: type,
      metadata: metadata,
    );
    addMessage(message);
  }

  // تنظیم وضعیت loading
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // تنظیم خطا
  void setError(String? error) {
    _hasError = error != null;
    _errorMessage = error;
    notifyListeners();
  }

  // پاک کردن چت
  Future<void> clearChat() async {
    _messages.clear();
    _hasError = false;
    _errorMessage = null;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('chat_messages');
    } catch (e) {
      debugPrint('Error clearing chat: $e');
    }

    notifyListeners();
  }

  // حذف پیام خاص
  void removeMessage(String messageId) {
    _messages.removeWhere((msg) => msg.id == messageId);
    _saveMessages();
    notifyListeners();
  }

  // به‌روزرسانی پیام
  void updateMessage(String messageId, String newText) {
    final index = _messages.indexWhere((msg) => msg.id == messageId);
    if (index != -1) {
      _messages[index] = _messages[index].copyWith(text: newText);
      _saveMessages();
      notifyListeners();
    }
  }
}
