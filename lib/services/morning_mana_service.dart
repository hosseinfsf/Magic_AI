import 'package:flutter/foundation.dart';
import '../services/gemini_service.dart';
import '../services/hafez_service.dart';
import '../services/ai_learning_service.dart';
import '../models/user_profile.dart';
import '../models/user_preferences.dart';

/// سرویس صبحانه مانا (Morning Mana)
class MorningManaService {
  final GeminiService _geminiService = GeminiService();
  final HafezService _hafezService = HafezService();
  final AILearningService _aiLearning = AILearningService();

  /// تولید صبحانه مانا
  Future<String> generateMorningMana({
    required UserProfile? userProfile,
    UserPreferences? preferences,
    List<String>? tasks,
    String? weather,
    String? sportsNews,
  }) async {
    try {
      final userName = userProfile?.name ?? 'عزیزم';
      final birthMonth = userProfile?.birthMonth ?? '';
      final city = userProfile?.city ?? '';
      
    // گرفتن فال حافظ
    final fortune = birthMonth.isNotEmpty
      ? HafezService.getFortuneByMonth(birthMonth)
      : HafezService.getRandomFortune();
      
      final ghazal = fortune['text'] ?? '';
      
      // ساخت پیام صبحانه
      final prompt = '''
شما "مانا" هستید - دستیار صمیمی کاربر.

صبح بخیر $userName! 🌅✨

امروز ${DateTime.now().toString().split(' ')[0]} است.

اطلاعات امروز:
${weather != null ? '- آب‌وهوا: $weather ☀️' : ''}
${tasks != null && tasks.isNotEmpty ? '- کارهای امروز: ${tasks.length} کار 📋' : ''}
${sportsNews != null ? '- خبر ورزشی: $sportsNews ⚽' : ''}

فال حافظ امروز:
"$ghazal"

${preferences != null ? '''
ترجیحات کاربر:
- لحن: ${preferences.preferredTone}
- علایق: ${preferences.interests.join(', ')}
- استفاده از ایموجی: ${preferences.likesEmojis}
''' : ''}

یک پیام صبحانه انرژی‌بخش و دوستانه بنویس که:
1. با نام کاربر شروع بشه
2. آب‌وهوا رو بگه (اگر داده شده)
3. فال حافظ رو به صورت خلاصه تفسیر کنه
4. کارهای امروز رو یادآوری کنه (اگر داده شده)
5. خبر ورزشی رو بگه (اگر داده شده)
6. یک جمله انگیزشی اضافه کنه
7. در آخر بپرسه "قهوه‌تو خوردی؟" یا چیزی مشابه

سبک: دوستانه، پر انرژی، با ایموجی زیاد، کوتاه و جذاب
حداکثر ۱۵ خط
''';

      final response = await _geminiService.sendMessage(prompt);
      
      // یادگیری از این تعامل
      await _aiLearning.learnFromInteraction(
        userMessage: 'morning_mana_request',
        aiResponse: response,
        action: 'morning_mana',
      );
      
      return response;
    } catch (e) {
      debugPrint('Error generating morning mana: $e');
      return _getDefaultMorningMessage(userProfile?.name ?? 'عزیزم');
    }
  }

  String _getDefaultMorningMessage(String userName) {
    return '''
صبح بخیر $userName! 🌅✨

امروز یک روز جدید و پر از فرصت‌هاست! 💪

امیدوارم روز خوبی داشته باشی و همه کارهات رو انجام بدی! 🚀

قهوه‌تو خوردی؟ ☕
''';
  }

  /// دریافت آب‌وهوا (می‌تواند از API آب‌وهوا استفاده کند)
  Future<String?> getWeather(String city) async {
    // در پروژه واقعی از API آب‌وهوا استفاده کنید
    // مثال: OpenWeatherMap API
    return 'آفتابی ☀️ دمای ۲۵ درجه';
  }

  /// دریافت خبر ورزشی (می‌تواند از API خبر استفاده کند)
  Future<String?> getSportsNews(String? favoriteTeam) async {
    // در پروژه واقعی از API خبر استفاده کنید
    if (favoriteTeam == null) return null;
    return '$favoriteTeam دیشب برد! ⚽';
  }
}

