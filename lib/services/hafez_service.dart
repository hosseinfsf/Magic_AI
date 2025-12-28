import 'dart:math';

/// سرویس فال حافظ
class HafezService {
  // غزل‌های حافظ (نمونه - در پروژه واقعی از فایل JSON استفاده کنید)
  static final List<Map<String, String>> _ghazals = [
    {
      'text': '''
ای دل غلام شاه جهان باش و شاه باش
پیمان شکستن در جهان کس روا ندارد
''',
      'meaning': 'دل را به عشق و محبت ببند و از دنیا دل بکن',
    },
    {
      'text': '''
در ازل پرتو حسنت ز تجلی دم زد
عشق پیدا شد و آتش به همه عالم زد
''',
      'meaning': 'عشق ازلی و ابدی است و در همه جا جاری',
    },
    {
      'text': '''
صبح است دامن کوه و دشت به نور آذین
باده نوشان را ز میخانه چه حاجت به صبوح
''',
      'meaning': 'زندگی را با شادی و نشاط بگذران',
    },
    {
      'text': '''
چو عضوی به درد آورد روزگار
دگر عضوها را نماند قرار
''',
      'meaning': 'همدلی و همدردی با دیگران داشته باش',
    },
    {
      'text': '''
هر که نامخت از گذشت روزگار
هیچ ناموزد ز هیچ آموزگار
''',
      'meaning': 'از تجربیات گذشته درس بگیر',
    },
  ];

  /// گرفتن فال تصادفی
  static Map<String, String> getRandomFortune() {
    final random = Random();
    final index = random.nextInt(_ghazals.length);
    return _ghazals[index];
  }

  /// گرفتن فال بر اساس ماه تولد
  static Map<String, String> getFortuneByMonth(String birthMonth) {
    // تبدیل ماه به عدد برای انتخاب فال
    final monthMap = {
      '🌸 فروردین': 0,
      '🌺 اردیبهشت': 1,
      '🌻 خرداد': 2,
      '☀️ تیر': 3,
      '🌾 مرداد': 4,
      '🍂 شهریور': 5,
      '🍁 مهر': 6,
      '🌧️ آبان': 7,
      '❄️ آذر': 8,
      '☃️ دی': 9,
      '🌨️ بهمن': 10,
      '🌷 اسفند': 11,
    };
    
    final monthIndex = monthMap[birthMonth] ?? 0;
    final fortuneIndex = monthIndex % _ghazals.length;
    return _ghazals[fortuneIndex];
  }

  /// گرفتن فال بر اساس سوال کاربر
  static Map<String, String> getFortuneByQuestion(String question) {
    // تحلیل ساده سوال و انتخاب فال مناسب
    final lowerQuestion = question.toLowerCase();
    
    if (lowerQuestion.contains('عشق') || lowerQuestion.contains('محبت')) {
      return _ghazals[1]; // غزل عشق
    } else if (lowerQuestion.contains('شادی') || lowerQuestion.contains('خوشی')) {
      return _ghazals[2]; // غزل شادی
    } else if (lowerQuestion.contains('دوست') || lowerQuestion.contains('رفیق')) {
      return _ghazals[3]; // غزل دوستی
    } else if (lowerQuestion.contains('یاد') || lowerQuestion.contains('تجربه')) {
      return _ghazals[4]; // غزل تجربه
    } else {
      return getRandomFortune();
    }
  }

  /// گرفتن لیست همه غزل‌ها
  static List<Map<String, String>> getAllGhazals() {
    return List.from(_ghazals);
  }
}

