/// مدل ترجیحات و علایق کاربر (برای یادگیری AI)
class UserPreferences {
  // ترجیحات لحن
  final String preferredTone; // 'formal', 'casual', 'friendly', 'funny', 'professional'
  
  // علایق
  final List<String> interests; // ['sports', 'music', 'tech', ...]
  final List<String> favoriteTopics;
  
  // عادت‌ها
  final Map<String, String> habits; // {'wakeTime': '07:00', 'sleepTime': '23:00'}
  final List<String> activeHours; // ['morning', 'afternoon', 'evening']
  
  // ترجیحات محتوا
  final bool likesEmojis;
  final bool likesLongMessages;
  final String preferredLanguage; // 'fa', 'en', 'mixed'
  
  // ترجیحات فال
  final bool wantsDailyFortune;
  final String fortuneStyle; // 'detailed', 'short', 'poetic'
  
  // ترجیحات صبحانه/شب‌نامه
  final bool wantsMorningMana;
  final bool wantsNightSummary;
  final List<String> morningFeatures; // ['weather', 'fortune', 'tasks', ...]
  final List<String> nightFeatures; // ['summary', 'music', 'journal', ...]
  
  // ترجیحات شبکه‌های اجتماعی
  final Map<String, String> socialMediaPreferences;
  
  // آمار استفاده
  final Map<String, int> usageStats; // {'chat': 50, 'fortune': 20, ...}
  
  // آخرین به‌روزرسانی
  final DateTime lastUpdated;

  UserPreferences({
    this.preferredTone = 'friendly',
    this.interests = const [],
    this.favoriteTopics = const [],
    this.habits = const {},
    this.activeHours = const [],
    this.likesEmojis = true,
    this.likesLongMessages = false,
    this.preferredLanguage = 'fa',
    this.wantsDailyFortune = true,
    this.fortuneStyle = 'detailed',
    this.wantsMorningMana = true,
    this.wantsNightSummary = true,
    this.morningFeatures = const ['weather', 'fortune', 'tasks'],
    this.nightFeatures = const ['summary', 'music'],
    this.socialMediaPreferences = const {},
    this.usageStats = const {},
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  // تبدیل به Map
  Map<String, dynamic> toJson() {
    return {
      'preferredTone': preferredTone,
      'interests': interests,
      'favoriteTopics': favoriteTopics,
      'habits': habits,
      'activeHours': activeHours,
      'likesEmojis': likesEmojis,
      'likesLongMessages': likesLongMessages,
      'preferredLanguage': preferredLanguage,
      'wantsDailyFortune': wantsDailyFortune,
      'fortuneStyle': fortuneStyle,
      'wantsMorningMana': wantsMorningMana,
      'wantsNightSummary': wantsNightSummary,
      'morningFeatures': morningFeatures,
      'nightFeatures': nightFeatures,
      'socialMediaPreferences': socialMediaPreferences,
      'usageStats': usageStats,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  // ساخت از Map
  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      preferredTone: json['preferredTone'] ?? 'friendly',
      interests: List<String>.from(json['interests'] ?? []),
      favoriteTopics: List<String>.from(json['favoriteTopics'] ?? []),
      habits: Map<String, String>.from(json['habits'] ?? {}),
      activeHours: List<String>.from(json['activeHours'] ?? []),
      likesEmojis: json['likesEmojis'] ?? true,
      likesLongMessages: json['likesLongMessages'] ?? false,
      preferredLanguage: json['preferredLanguage'] ?? 'fa',
      wantsDailyFortune: json['wantsDailyFortune'] ?? true,
      fortuneStyle: json['fortuneStyle'] ?? 'detailed',
      wantsMorningMana: json['wantsMorningMana'] ?? true,
      wantsNightSummary: json['wantsNightSummary'] ?? true,
      morningFeatures: List<String>.from(json['morningFeatures'] ?? ['weather', 'fortune', 'tasks']),
      nightFeatures: List<String>.from(json['nightFeatures'] ?? ['summary', 'music']),
      socialMediaPreferences: Map<String, String>.from(json['socialMediaPreferences'] ?? {}),
      usageStats: Map<String, int>.from(json['usageStats'] ?? {}),
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : DateTime.now(),
    );
  }

  // کپی با تغییرات
  UserPreferences copyWith({
    String? preferredTone,
    List<String>? interests,
    List<String>? favoriteTopics,
    Map<String, String>? habits,
    List<String>? activeHours,
    bool? likesEmojis,
    bool? likesLongMessages,
    String? preferredLanguage,
    bool? wantsDailyFortune,
    String? fortuneStyle,
    bool? wantsMorningMana,
    bool? wantsNightSummary,
    List<String>? morningFeatures,
    List<String>? nightFeatures,
    Map<String, String>? socialMediaPreferences,
    Map<String, int>? usageStats,
  }) {
    return UserPreferences(
      preferredTone: preferredTone ?? this.preferredTone,
      interests: interests ?? this.interests,
      favoriteTopics: favoriteTopics ?? this.favoriteTopics,
      habits: habits ?? this.habits,
      activeHours: activeHours ?? this.activeHours,
      likesEmojis: likesEmojis ?? this.likesEmojis,
      likesLongMessages: likesLongMessages ?? this.likesLongMessages,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      wantsDailyFortune: wantsDailyFortune ?? this.wantsDailyFortune,
      fortuneStyle: fortuneStyle ?? this.fortuneStyle,
      wantsMorningMana: wantsMorningMana ?? this.wantsMorningMana,
      wantsNightSummary: wantsNightSummary ?? this.wantsNightSummary,
      morningFeatures: morningFeatures ?? this.morningFeatures,
      nightFeatures: nightFeatures ?? this.nightFeatures,
      socialMediaPreferences: socialMediaPreferences ?? this.socialMediaPreferences,
      usageStats: usageStats ?? this.usageStats,
      lastUpdated: DateTime.now(),
    );
  }
}

