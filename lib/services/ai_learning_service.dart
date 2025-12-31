import 'package:flutter/foundation.dart';

import '../models/user_preferences.dart';
import '../services/cloud_storage_service.dart';
import '../services/gemini_service.dart';

/// سرویس یادگیری AI از رفتار و ترجیحات کاربر
class AILearningService {
  final CloudStorageService _cloudStorage = CloudStorageService();
  final GeminiService _geminiService = GeminiService();

  UserPreferences? _cachedPreferences;

  /// بارگذاری ترجیحات کاربر
  Future<UserPreferences> loadPreferences() async {
    if (_cachedPreferences != null) return _cachedPreferences!;

    try {
      final data = await _cloudStorage.loadUserPreferences();
      _cachedPreferences =
          data.isEmpty ? UserPreferences() : UserPreferences.fromJson(data);
      return _cachedPreferences!;
    } catch (e) {
      debugPrint('Error loading preferences: $e');
      return UserPreferences();
    }
  }

  /// ذخیره ترجیحات کاربر
  Future<void> savePreferences(UserPreferences preferences) async {
    try {
      _cachedPreferences = preferences;
      await _cloudStorage.saveUserPreferences(preferences.toJson());
    } catch (e) {
      debugPrint('Error saving preferences: $e');
    }
  }

  /// یادگیری از یک تعامل کاربر
  Future<void> learnFromInteraction({
    required String userMessage,
    required String aiResponse,
    required String action, // 'chat', 'fortune', 'content', etc.
  }) async {
    try {
      // ذخیره رفتار
      await _cloudStorage.saveUserBehavior(
        action: action,
        context: {
          'userMessage': userMessage,
          'aiResponse': aiResponse,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      // به‌روزرسانی آمار استفاده
      final preferences = await loadPreferences();
      final updatedStats = Map<String, int>.from(preferences.usageStats);
      updatedStats[action] = (updatedStats[action] ?? 0) + 1;

      await savePreferences(preferences.copyWith(usageStats: updatedStats));

      // تحلیل لحن و علایق از پیام کاربر
      await _analyzeUserMessage(userMessage);
    } catch (e) {
      debugPrint('Error learning from interaction: $e');
    }
  }

  /// تحلیل پیام کاربر برای استخراج علایق
  Future<void> _analyzeUserMessage(String message) async {
    try {
      final prompt = '''
این پیام کاربر رو تحلیل کن و اطلاعات زیر رو استخراج کن:
- علایق و موضوعات مورد علاقه
- لحن مورد علاقه (رسمی، خودمونی، طنز)
- نوع محتوای مورد علاقه

پیام: "$message"

فقط JSON برگردون با این ساختار:
{
  "interests": ["موضوع1", "موضوع2"],
  "tone": "friendly",
  "topics": ["موضوع1"]
}
''';

      final response = await _geminiService.sendMessage(prompt);

      // Parse response and update preferences
      // (در پروژه واقعی از json_serializable استفاده کنید)
      final preferences = await loadPreferences();

      // به‌روزرسانی ترجیحات بر اساس تحلیل
      // این یک پیاده‌سازی ساده است - می‌توانید پیچیده‌تر کنید
    } catch (e) {
      debugPrint('Error analyzing user message: $e');
    }
  }

  /// دریافت پیشنهاد شخصی‌سازی‌شده
  Future<String> getPersonalizedSuggestion({
    required String context,
    required String type, // 'content', 'activity', 'reminder'
  }) async {
    try {
      final preferences = await loadPreferences();
      final behaviorHistory =
          await _cloudStorage.loadUserBehaviorHistory(limit: 20);

      final prompt = '''
شما "مانا" هستید - دستیار هوشمند کاربر.

اطلاعات کاربر:
- لحن مورد علاقه: ${preferences.preferredTone}
- علایق: ${preferences.interests.join(', ')}
- موضوعات مورد علاقه: ${preferences.favoriteTopics.join(', ')}
- آمار استفاده: ${preferences.usageStats}

تاریخچه رفتار اخیر:
${behaviorHistory.take(5).map((b) => '- ${b['action']}: ${b['context']}').join('\n')}

متن: "$context"
نوع پیشنهاد: $type

یک پیشنهاد شخصی‌سازی‌شده بده که:
- با علایق کاربر هماهنگ باشه
- با لحن مورد علاقه‌اش نوشته بشه
- بر اساس رفتار قبلی‌اش باشه
- مفید و عملی باشه
''';

      return await _geminiService.sendMessage(prompt);
    } catch (e) {
      debugPrint('Error getting personalized suggestion: $e');
      return '';
    }
  }

  /// به‌روزرسانی ترجیحات بر اساس انتخاب کاربر
  Future<void> updatePreferenceFromChoice({
    required String category,
    required String value,
  }) async {
    try {
      final preferences = await loadPreferences();
      UserPreferences updated;

      switch (category) {
        case 'tone':
          updated = preferences.copyWith(preferredTone: value);
          break;
        case 'interest':
          final interests = List<String>.from(preferences.interests);
          if (!interests.contains(value)) {
            interests.add(value);
            updated = preferences.copyWith(interests: interests);
          } else {
            return;
          }
          break;
        case 'language':
          updated = preferences.copyWith(preferredLanguage: value);
          break;
        default:
          return;
      }

      await savePreferences(updated);
    } catch (e) {
      debugPrint('Error updating preference: $e');
    }
  }

  /// دریافت خلاصه شخصیت کاربر (برای AI)
  Future<String> getUserPersonalitySummary() async {
    try {
      final preferences = await loadPreferences();
      final behaviorHistory =
          await _cloudStorage.loadUserBehaviorHistory(limit: 50);

      return '''
شخصیت کاربر:
- لحن مورد علاقه: ${preferences.preferredTone}
- علایق: ${preferences.interests.join(', ')}
- عادت‌ها: ${preferences.habits}
- ساعات فعال: ${preferences.activeHours.join(', ')}
- استفاده از ایموجی: ${preferences.likesEmojis ? 'بله' : 'خیر'}
- آمار استفاده: ${preferences.usageStats}
- تعداد تعاملات: ${behaviorHistory.length}
''';
    } catch (e) {
      debugPrint('Error getting personality summary: $e');
      return '';
    }
  }
}
