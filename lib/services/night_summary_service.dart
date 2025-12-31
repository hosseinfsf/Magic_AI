import 'package:flutter/foundation.dart';

import '../models/user_preferences.dart';
import '../models/user_profile.dart';
import '../services/ai_learning_service.dart';
import '../services/gemini_service.dart';

/// سرویس شب‌نامه مانا (Night Summary)
class NightSummaryService {
  final GeminiService _geminiService = GeminiService();
  final AILearningService _aiLearning = AILearningService();

  /// تولید شب‌نامه مانا
  Future<String> generateNightSummary({
    required UserProfile? userProfile,
    UserPreferences? preferences,
    required int completedTasks,
    required int totalTasks,
    String? musicSuggestion,
    String? movieSuggestion,
  }) async {
    try {
      final userName = userProfile?.name ?? 'عزیزم';

      final prompt = '''
شما "مانا" هستید - دستیار صمیمی کاربر.

شب بخیر $userName! 🌙

خلاصه امروز:
- کارهای انجام شده: $completedTasks از $totalTasks ✅
${musicSuggestion != null ? '- پیشنهاد آهنگ: $musicSuggestion 🎵' : ''}
${movieSuggestion != null ? '- پیشنهاد فیلم/سریال: $movieSuggestion 🎬' : ''}

${preferences != null ? '''
ترجیحات کاربر:
- لحن: ${preferences.preferredTone}
- علایق: ${preferences.interests.join(', ')}
''' : ''}

یک پیام شبانه آرامش‌بخش و دوستانه بنویس که:
1. با نام کاربر شروع بشه
2. خلاصه روز رو بگه (چند کار انجام داد)
3. اگر خوب کار کرده، تشویق کنه
4. پیشنهاد آهنگ بده (اگر داده شده)
5. پیشنهاد فیلم/سریال بده (اگر داده شده)
6. دعوت به ژورنال شبانه کنه (یک پاراگراف بنویسه کاربر)
7. آرزوی شب خوب کنه

سبک: آرام، دوستانه، انگیزشی، با ایموجی مناسب
حداکثر ۱۲ خط
''';

      final response = await _geminiService.sendMessage(prompt);

      // یادگیری از این تعامل
      await _aiLearning.learnFromInteraction(
        userMessage: 'night_summary_request',
        aiResponse: response,
        action: 'night_summary',
      );

      return response;
    } catch (e) {
      debugPrint('Error generating night summary: $e');
      return _getDefaultNightMessage(
          userProfile?.name ?? 'عزیزم', completedTasks, totalTasks);
    }
  }

  String _getDefaultNightMessage(String userName, int completed, int total) {
    return '''
شب بخیر $userName! 🌙

امروز $completed از $total کارت رو انجام دادی! 👏

امیدوارم روز خوبی داشته باشی! 

اگر دوست داری، بگو امروزت چطور بود... 💭

شب خوبی داشته باشی! ✨
''';
  }

  /// پیشنهاد آهنگ آرامش‌بخش
  Future<String?> suggestMusic(UserPreferences? preferences) async {
    // در پروژه واقعی از API موسیقی استفاده کنید
    // یا لیست آهنگ‌های محلی داشته باشید
    return 'سلطان قلب‌ها - محسن یگانه 🎵';
  }

  /// پیشنهاد فیلم/سریال
  Future<String?> suggestMovie(UserPreferences? preferences) async {
    // در پروژه واقعی از API فیلم استفاده کنید
    return 'سریال خانه پوشالی 🎬';
  }
}
