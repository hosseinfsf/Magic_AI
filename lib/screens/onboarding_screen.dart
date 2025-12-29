import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/user_provider.dart';
import '../models/user_profile.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int currentPage = 0;
  
  // پاسخ‌های کاربر
  String userName = '';
  String ageGroup = '';
  String dailyActivity = '';
  String birthMonth = '';
  String city = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.mysticalGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Progress Bar
              _buildProgressBar(),
              
              // سوالات
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (page) {
                    setState(() => currentPage = page);
                  },
                  children: [
                    _buildQuestion1(),
                    _buildQuestion2(),
                    _buildQuestion3(),
                    _buildQuestion4(),
                    _buildQuestion5(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: List.generate(5, (index) {
          return Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: index <= currentPage
            ? AppTheme.secondaryGold
              : Colors.white.withAlpha((0.3 * 255).round()),
                borderRadius: BorderRadius.circular(2),
              ),
            )
                .animate(delay: Duration(milliseconds: index * 100))
                .fadeIn()
                .scaleX(),
          );
        }),
      ),
    );
  }

  // سوال ۱: اسم کوچیک
  Widget _buildQuestion1() {
    return _buildQuestionContainer(
      title: 'سلام! اسم کوچیکت چیه؟ چی صدات کنم؟ 😊',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: TextField(
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            hintText: 'مثلاً علی، مریم، ...',
            hintStyle: TextStyle(
              color: Colors.white.withAlpha((0.5 * 255).round()),
              fontSize: 18,
            ),
            border: InputBorder.none,
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: AppTheme.secondaryGold.withAlpha((0.5 * 255).round()),
                width: 2,
              ),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(
                color: AppTheme.secondaryGold,
                width: 3,
              ),
            ),
          ),
          onChanged: (value) {
            setState(() => userName = value);
          },
        ),
      ),
      onNext: userName.isNotEmpty ? _nextPage : null,
    )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideX(begin: 0.3, end: 0);
  }

  // سوال ۲: گروه سنی
  Widget _buildQuestion2() {
    final ageGroups = [
      '🧒 زیر ۱۸',
      '🎓 ۱۸-۲۵',
      '💼 ۲۶-۳۵',
      '👔 ۳۶-۵۰',
      '🎖️ بالای ۵۰',
    ];

    return _buildQuestionContainer(
      title: 'عالیه $userName جان! 🌟\nچند سالته حدوداً؟',
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 15,
        runSpacing: 15,
        children: ageGroups.map((age) {
          final isSelected = ageGroup == age;
          return _buildChoiceChip(
            label: age,
            isSelected: isSelected,
            onTap: () {
              setState(() => ageGroup = age);
              Future.delayed(const Duration(milliseconds: 300), _nextPage);
            },
          );
        }).toList(),
      ),
      showSkip: true,
    )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideX(begin: 0.3, end: 0);
  }

  // سوال ۳: فعالیت روزانه
  Widget _buildQuestion3() {
    final activities = [
      '📚 درس',
      '💼 کار',
      '🏠 خونه',
      '💻 فریلنس',
      '🎖️ بازنشسته',
      '🎨 موارد دیگر',
    ];

    return _buildQuestionContainer(
      title: 'خیلی خوب! 💪\nروزانه بیشتر چیکار می‌کنی؟',
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 15,
        runSpacing: 15,
        children: activities.map((activity) {
          final isSelected = dailyActivity == activity;
          return _buildChoiceChip(
            label: activity,
            isSelected: isSelected,
            onTap: () {
              setState(() => dailyActivity = activity);
              Future.delayed(const Duration(milliseconds: 300), _nextPage);
            },
          );
        }).toList(),
      ),
      showBack: true,
      showSkip: true,
    )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideX(begin: 0.3, end: 0);
  }

  // سوال ۴: ماه تولد
  Widget _buildQuestion4() {
    final months = [
      '🌸 فروردین',
      '🌺 اردیبهشت',
      '🌻 خرداد',
      '☀️ تیر',
      '🌾 مرداد',
      '🍂 شهریور',
      '🍁 مهر',
      '🌧️ آبان',
      '❄️ آذر',
      '☃️ دی',
      '🌨️ بهمن',
      '🌷 اسفند',
    ];

    return _buildQuestionContainer(
      title: 'عالیه! 🎉\nماه تولدت چیه؟\n(برای فال شخصی‌تر)',
      child: SingleChildScrollView(
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: months.map((month) {
            final isSelected = birthMonth == month;
            return _buildChoiceChip(
              label: month,
              isSelected: isSelected,
              compact: true,
              onTap: () {
                setState(() => birthMonth = month);
                Future.delayed(const Duration(milliseconds: 300), _nextPage);
              },
            );
          }).toList(),
        ),
      ),
      showBack: true,
      showSkip: true,
    )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideX(begin: 0.3, end: 0);
  }

  // سوال ۵: شهر
  Widget _buildQuestion5() {
    final cities = [
      '🏙️ تهران',
      '🌆 مشهد',
      '🏛️ اصفهان',
      '⛰️ شیراز',
      '🌊 تبریز',
      '🏖️ رشت',
      '🏞️ کرمان',
      '🌍 شهر دیگر',
    ];

    return _buildQuestionContainer(
      title: 'آخرین سوال! 🎊\nشهر یا استانت کجاست؟\n(برای آب‌وهوا و پیشنهاد محلی)',
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 15,
        runSpacing: 15,
        children: cities.map((cityOption) {
          final isSelected = city == cityOption;
          return _buildChoiceChip(
            label: cityOption,
            isSelected: isSelected,
            onTap: () {
              setState(() => city = cityOption);
              Future.delayed(const Duration(milliseconds: 500), _finishOnboarding);
            },
          );
        }).toList(),
      ),
      showBack: true,
    )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideX(begin: 0.3, end: 0);
  }

  Widget _buildQuestionContainer({
    required String title,
    required Widget child,
    VoidCallback? onNext,
    bool showBack = false,
    bool showSkip = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              height: 1.5,
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms, delay: 200.ms)
              .slideY(begin: -0.1, end: 0),
          
          const SizedBox(height: 60),
          
          child,
          
          const SizedBox(height: 40),
          
          // دکمه‌ها
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (showBack)
                IconButton(
                  onPressed: _previousPage,
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                )
              else
                const SizedBox(width: 48),
              
              if (showSkip)
                TextButton(
                  onPressed: _nextPage,
                  child: const Text(
                    'رد کن',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              
              if (onNext != null)
                ElevatedButton(
                  onPressed: onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondaryGold,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                  ),
                  child: const Text(
                    'بعدی',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                const SizedBox(width: 48),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    bool compact = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 16 : 24,
          vertical: compact ? 12 : 16,
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? AppTheme.purpleGoldGradient
              : null,
          color: isSelected ? null : Colors.white.withAlpha((0.1 * 255).round()),
          borderRadius: BorderRadius.circular(25),
            border: Border.all(
            color: isSelected
                ? Colors.transparent
                : Colors.white.withAlpha((0.3 * 255).round()),
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.secondaryGold.withAlpha((0.5 * 255).round()),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: compact ? 14 : 16,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    )
        .animate(target: isSelected ? 1 : 0)
        .scale(duration: 200.ms);
  }

  void _nextPage() {
    if (currentPage < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _finishOnboarding() async {
    // ساخت پروفایل کاربر
    final userProfile = UserProfile(
      name: userName,
      ageGroup: ageGroup,
      dailyActivity: dailyActivity,
      birthMonth: birthMonth,
      city: city,
      createdAt: DateTime.now(),
      hasCompletedOnboarding: true,
    );
    
    // ذخیره پروفایل
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.saveUserProfile(userProfile);
    
    // انتقال به صفحه اصلی
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

