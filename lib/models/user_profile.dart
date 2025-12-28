/// مدل پروفایل کاربر
class UserProfile {
  final String name;
  final String ageGroup;
  final String dailyActivity;
  final String birthMonth;
  final String city;
  final DateTime createdAt;
  final bool hasCompletedOnboarding;

  UserProfile({
    required this.name,
    required this.ageGroup,
    required this.dailyActivity,
    required this.birthMonth,
    required this.city,
    required this.createdAt,
    this.hasCompletedOnboarding = true,
  });

  // تبدیل به Map برای ذخیره‌سازی
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'ageGroup': ageGroup,
      'dailyActivity': dailyActivity,
      'birthMonth': birthMonth,
      'city': city,
      'createdAt': createdAt.toIso8601String(),
      'hasCompletedOnboarding': hasCompletedOnboarding,
    };
  }

  // ساخت از Map
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] ?? '',
      ageGroup: json['ageGroup'] ?? '',
      dailyActivity: json['dailyActivity'] ?? '',
      birthMonth: json['birthMonth'] ?? '',
      city: json['city'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      hasCompletedOnboarding: json['hasCompletedOnboarding'] ?? false,
    );
  }

  // کپی با تغییرات
  UserProfile copyWith({
    String? name,
    String? ageGroup,
    String? dailyActivity,
    String? birthMonth,
    String? city,
    DateTime? createdAt,
    bool? hasCompletedOnboarding,
  }) {
    return UserProfile(
      name: name ?? this.name,
      ageGroup: ageGroup ?? this.ageGroup,
      dailyActivity: dailyActivity ?? this.dailyActivity,
      birthMonth: birthMonth ?? this.birthMonth,
      city: city ?? this.city,
      createdAt: createdAt ?? this.createdAt,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
    );
  }
}

