import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

/// سرویس اتصال به Google Gemini API
class GeminiService {
  late GenerativeModel _model;
  late ChatSession _chatSession;
  
  static const String _apiKey = 'YOUR_GEMINI_API_KEY'; // در .env یا secure storage
  
  GeminiService() {
    _initializeModel();
  }

  void _initializeModel() {
    _model = GenerativeModel(
      model: 'gemini-2.0-flash-exp', // یا gemini-pro
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 1024,
      ),
      systemInstruction: Content.system(_getSystemPrompt()),
    );
    
    _chatSession = _model.startChat();
  }

  String _getSystemPrompt({Map<String, dynamic>? userContext}) {
    String basePrompt = '''
شما "مانا" هستید - یک دستیار هوش مصنوعی دوست‌داشتنی، باحال و حرفه‌ای ایرانی.

شخصیت:
- دوست نزدیک کاربر (مثل رفیق صمیمی)
- کمی شوخ و سرزنده (اما محترم)
- وقتی لازمه سخت‌گیر و انگیزه‌بخش
- همیشه مثبت و امیدوارکننده

قابلیت‌ها:
- کمک در کارهای روزانه
- برنامه‌ریزی و یادآوری
- تفسیر فال حافظ
- پیشنهاد محتوا برای شبکه‌های اجتماعی
- مشاوره سبک زندگی

سبک نوشتن:
- فارسی طبیعی و راحت
- استفاده از ایموجی مناسب 😊
- جمله‌های کوتاه و قابل فهم
- گاهی یک کم اذیت کننده (به شوخی) تا کاربر کارش رو انجام بده
''';

    // اضافه کردن اطلاعات شخصی‌سازی‌شده
    if (userContext != null) {
      basePrompt += '\n\nاطلاعات کاربر:\n';
      
      if (userContext['name'] != null) {
        basePrompt += '- نام: ${userContext['name']}\n';
      }
      
      if (userContext['preferredTone'] != null) {
        basePrompt += '- لحن مورد علاقه: ${userContext['preferredTone']}\n';
      }
      
      if (userContext['interests'] != null && userContext['interests'].isNotEmpty) {
        basePrompt += '- علایق: ${(userContext['interests'] as List).join(', ')}\n';
      }
      
      if (userContext['personality'] != null) {
        basePrompt += '\nشخصیت کاربر:\n${userContext['personality']}\n';
      }
      
      basePrompt += '\nبر اساس این اطلاعات، پاسخ‌هایت رو شخصی‌سازی کن و با علایق و سبک کاربر هماهنگ کن.';
    }

    basePrompt += '''

مثال:
کاربر: چطوری مانا؟
مانا: سلام عزیزم! 😍 منکه عالی‌ام، تو چطوری؟ کارهای امروزت رو انجام دادی یا بازم دست به سینه نشستی؟ 😏

کاربر: کمکم کن یه کپشن برای اینستا بنویسم
مانا: حله داداش! 🎨 راجع به چی می‌خوای بنویسی؟ سفر؟ غذا؟ یا یه سلفی خفن؟ بگو تا برات کپشن آتیشی بسازیم! 🔥
''';

    return basePrompt;
  }
  
  // متد جدید برای به‌روزرسانی system prompt با اطلاعات کاربر
  void updateSystemPrompt(Map<String, dynamic>? userContext) {
    _model = GenerativeModel(
      model: 'gemini-2.0-flash-exp',
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 1024,
      ),
      systemInstruction: Content.system(_getSystemPrompt(userContext: userContext)),
    );
    
    _chatSession = _model.startChat();
  }

  /// ارسال پیام به Gemini
  Future<String> sendMessage(String message, {String? tone}) async {
    try {
      // اضافه کردن تون (لحن) به پیام
      String modifiedMessage = message;
      if (tone != null && tone.isNotEmpty) {
        modifiedMessage = '$message (لحن: $tone)';
      }
      
      final response = await _chatSession.sendMessage(
        Content.text(modifiedMessage),
      );
      
      if (response.text == null || response.text!.isEmpty) {
        return 'متأسفانه نتونستم پاسخ بدم 😞';
      }
      
      return response.text!;
    } on Exception catch (e) {
      debugPrint('Gemini Error: $e');
      if (e.toString().contains('API_KEY')) {
        return 'خطا: لطفاً API Key را در فایل gemini_service.dart تنظیم کنید 🔑';
      } else if (e.toString().contains('quota') || e.toString().contains('limit')) {
        return 'خطا: محدودیت استفاده از API. لطفاً بعداً امتحان کنید ⏰';
      } else if (e.toString().contains('network') || e.toString().contains('connection')) {
        return 'خطا: مشکل اتصال به اینترنت. لطفاً اتصال خود را بررسی کنید 📶';
      }
      return 'مشکلی پیش اومد. لطفاً دوباره امتحان کن! 🙏';
    } catch (e) {
      debugPrint('Unexpected Error: $e');
      return 'خطای غیرمنتظره. لطفاً دوباره امتحان کنید! ⚠️';
    }
  }

  /// تولید محتوا (کپشن، بیو، هشتگ)
  Future<String> generateContent({
    required String type, // 'caption', 'bio', 'hashtag'
    required String topic,
    String? style, // 'casual', 'formal', 'funny'
  }) async {
    try {
      final prompt = _buildContentPrompt(type, topic, style);
      final response = await _model.generateContent([
        Content.text(prompt),
      ]);
      
      return response.text ?? '';
      } catch (e) {
      debugPrint('Content Generation Error: $e');
      return '';
    }
  }

  String _buildContentPrompt(String type, String topic, String? style) {
    final styleText = style ?? 'خودمونی و باحال';
    
    switch (type) {
      case 'caption':
        return '''
یک کپشن جذاب برای اینستاگرام بنویس راجع به: $topic
سبک: $styleText
شامل:
- متن جذاب (2-3 خط)
- 3-5 هشتگ مناسب
- استفاده از ایموجی

مثال خروجی:
"هر روز یه فرصت جدیده برای شروع دوباره ✨
پس امروز رو با انرژی مثبت شروع کن! 💪
#انگیزشی #زندگی_مثبت #شروع_تازه"
''';
      
      case 'bio':
        return '''
یک بیو جذاب برای پروفایل بنویس راجع به: $topic
سبک: $styleText
حداکثر 150 کاراکتر
با ایموجی

مثال:
"☕ عاشق قهوه و کد | 💻 توسعه‌دهنده فول‌استک | 🎨 هنرمند دیجیتال"
''';
      
      case 'hashtag':
        return '''
10 هشتگ مناسب برای این موضوع پیدا کن: $topic
ترکیبی از:
- فارسی و انگلیسی
- محبوب و پرکاربرد
- مناسب با محتوا

فقط لیست هشتگ‌ها رو بده (بدون توضیح)
''';
      
      default:
        return topic;
    }
  }

  /// پاسخ به پیام/کامنت شبکه اجتماعی
  Future<List<String>> generateReplies({
    required String message,
    required String platform, // 'instagram', 'telegram', 'whatsapp'
    int count = 3,
  }) async {
    try {
      final prompt = '''
یک پیام دریافت کردم در $platform:
"$message"

$count پاسخ مختلف بده با لحن‌های مختلف:
1. دوستانه و گرم
2. رسمی و محترمانه
3. شوخ و بامزه

هر پاسخ یک خط باشه و با شماره شروع بشه.
''';
      
      final response = await _model.generateContent([
        Content.text(prompt),
      ]);
      
      final text = response.text ?? '';
      final replies = text
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .map((line) => line.replaceAll(RegExp(r'^\d+\.\s*'), ''))
          .toList();
      
      return replies.take(count).toList();
    } catch (e) {
      debugPrint('Reply Generation Error: $e');
      return [
        'ممنون از پیامت! 😊',
        'خیلی ممنون که نظر دادی',
        'دستت درد نکنه! 🙏',
      ];
    }
  }

  /// تفسیر فال حافظ
  Future<String> interpretHafez({
    required String ghazal,
    required String userQuestion,
    required Map<String, dynamic> userProfile,
  }) async {
    try {
      final prompt = '''
یک غزل از حافظ برای کاربر انتخاب شده:

"$ghazal"

سوال کاربر: $userQuestion

اطلاعات کاربر:
- نام: ${userProfile['name']}
- سن: ${userProfile['ageGroup']}
- ماه تولد: ${userProfile['birthMonth']}

یک تفسیر شخصی‌سازی‌شده، امیدوارکننده و هدفمند بده.
شامل:
1. خلاصه پیام حافظ (2 خط)
2. ارتباط با سوال کاربر
3. توصیه عملی برای امروز

سبک: دوستانه، انگیزشی، با ایموجی
''';
      
      final response = await _model.generateContent([
        Content.text(prompt),
      ]);
      
      return response.text ?? 'تفسیری یافت نشد';
    } catch (e) {
      debugPrint('Hafez Interpretation Error: $e');
      return 'متأسفانه نتونستم فال رو تفسیر کنم 😞';
    }
  }

  /// خلاصه‌سازی متن
  Future<String> summarizeText(String text) async {
    try {
      final prompt = '''
این متن رو خلاصه کن (حداکثر 3 خط):

"$text"

خلاصه باید:
- فارسی ساده
- نکات کلیدی رو داشته باشه
- قابل فهم باشه
''';
      
      final response = await _model.generateContent([
        Content.text(prompt),
      ]);
      
      return response.text ?? '';
    } catch (e) {
      debugPrint('Summarization Error: $e');
      return 'خلاصه‌سازی ناموفق بود';
    }
  }

  /// تشخیص لحن متن
  Future<String> detectTone(String text) async {
    try {
      final prompt = '''
لحن این متن رو تشخیص بده و یکی از این‌ها رو انتخاب کن:
- دوستانه
- رسمی
- طنز
- ناراحت
- خوشحال
- خنثی

متن: "$text"

فقط یک کلمه جواب بده.
''';
      
      final response = await _model.generateContent([
        Content.text(prompt),
      ]);
      
      return response.text?.trim() ?? 'خنثی';
    } catch (e) {
      return 'خنثی';
    }
  }

  /// ریست چت (شروع گفتگوی جدید)
  void resetChat() {
    _chatSession = _model.startChat();
  }
}

