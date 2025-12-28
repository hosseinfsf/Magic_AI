/// ثابت‌های اپلیکیشن
class AppConstants {
  // API Keys (در پروژه واقعی از .env استفاده کنید)
  static const String geminiApiKey = 'YOUR_GEMINI_API_KEY';
  
  // تنظیمات چت
  static const int maxMessageLength = 2000;
  static const int maxChatHistory = 100;
  
  // انیمیشن‌ها
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration fastAnimationDuration = Duration(milliseconds: 150);
  static const Duration slowAnimationDuration = Duration(milliseconds: 500);
  
  // UI
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 16.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 24.0;
  
  // پیام‌های پیش‌فرض
  static const String welcomeMessage = 'سلام! من مانا هستم 🐱✨\nچطور می‌تونم کمکت کنم؟';
  static const String errorMessage = 'متأسفانه مشکلی پیش اومد. لطفاً دوباره امتحان کن! 😞';
  static const String loadingMessage = 'در حال پردازش...';
  
  // دستورات سریع
  static const List<Map<String, String>> quickCommands = [
    {
      'title': 'فال حافظ',
      'command': 'فال حافظ بگیر',
      'icon': 'auto_awesome',
    },
    {
      'title': 'کپشن اینستاگرام',
      'command': 'یه کپشن برای اینستاگرام بنویس',
      'icon': 'edit',
    },
    {
      'title': 'خلاصه متن',
      'command': 'این متن رو خلاصه کن:',
      'icon': 'summarize',
    },
    {
      'title': 'تشخیص لحن',
      'command': 'لحن این متن رو تشخیص بده:',
      'icon': 'sentiment_satisfied',
    },
  ];
}

