import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../services/morning_mana_service.dart';
import '../providers/user_provider.dart';
import '../models/user_preferences.dart';

class MorningManaScreen extends StatefulWidget {
  const MorningManaScreen({super.key});

  @override
  State<MorningManaScreen> createState() => _MorningManaScreenState();
}

class _MorningManaScreenState extends State<MorningManaScreen> {
  final MorningManaService _service = MorningManaService();
  String? _morningMessage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMorningMana();
  }

  Future<void> _loadMorningMana() async {
    setState(() => _isLoading = true);
    
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userProfile = userProvider.userProfile;
      
      // در پروژه واقعی این اطلاعات را از API بگیرید
      final weather = await _service.getWeather(userProfile?.city ?? 'تهران');
      final sportsNews = await _service.getSportsNews('پرسپولیس');
      
      final message = await _service.generateMorningMana(
        userProfile: userProfile,
        preferences: null, // می‌توانید از Provider بگیرید
        tasks: ['کار ۱', 'کار ۲', 'کار ۳'],
        weather: weather,
        sportsNews: sportsNews,
      );
      
      setState(() {
        _morningMessage = message;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _morningMessage = 'خطا در بارگذاری صبحانه مانا';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text('صبحانه مانا 🌅'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.secondaryGold),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // کارت صبحانه
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: AppTheme.purpleGoldGradient,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryPurple.withAlpha((0.3 * 255).round()),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Text(
                      _morningMessage ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        height: 1.8,
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
                  
                  const SizedBox(height: 24),
                  
                  // دکمه‌های عملی
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _loadMorningMana,
                          icon: const Icon(Icons.refresh),
                          label: const Text('به‌روزرسانی'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.bgCard,
                            foregroundColor: AppTheme.textPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.close),
                          label: const Text('بستن'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}

