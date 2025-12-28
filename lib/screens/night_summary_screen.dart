import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../services/night_summary_service.dart';
import '../providers/user_provider.dart';
import '../providers/chat_provider.dart';

class NightSummaryScreen extends StatefulWidget {
  const NightSummaryScreen({super.key});

  @override
  State<NightSummaryScreen> createState() => _NightSummaryScreenState();
}

class _NightSummaryScreenState extends State<NightSummaryScreen> {
  final NightSummaryService _service = NightSummaryService();
  final TextEditingController _journalController = TextEditingController();
  String? _nightMessage;
  bool _isLoading = true;
  int _completedTasks = 0;
  int _totalTasks = 5;

  @override
  void initState() {
    super.initState();
    _loadNightSummary();
  }

  @override
  void dispose() {
    _journalController.dispose();
    super.dispose();
  }

  Future<void> _loadNightSummary() async {
    setState(() => _isLoading = true);
    
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      final userProfile = userProvider.userProfile;
      
      // محاسبه کارهای انجام شده (در پروژه واقعی از Task Provider بگیرید)
      _completedTasks = 3; // مثال
      _totalTasks = 5;
      
      final musicSuggestion = await _service.suggestMusic(null);
      final movieSuggestion = await _service.suggestMovie(null);
      
      final message = await _service.generateNightSummary(
        userProfile: userProfile,
        preferences: null,
        completedTasks: _completedTasks,
        totalTasks: _totalTasks,
        musicSuggestion: musicSuggestion,
        movieSuggestion: movieSuggestion,
      );
      
      setState(() {
        _nightMessage = message;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _nightMessage = 'خطا در بارگذاری شب‌نامه مانا';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text('شب‌نامه مانا 🌙'),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // کارت شب‌نامه
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: AppTheme.mysticalGradient,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryPurple.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Text(
                      _nightMessage ?? '',
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
                  
                  // ژورنال شبانه
                  const Text(
                    'ژورنال شبانه 💭',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _journalController,
                    maxLines: 5,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'امروزت چطور بود؟ چیزی که می‌خوای بنویسی...',
                      hintStyle: const TextStyle(color: AppTheme.textSecondary),
                      filled: true,
                      fillColor: AppTheme.bgCard,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // دکمه‌ها
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // ذخیره ژورنال
                            if (_journalController.text.isNotEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('ژورنال ذخیره شد ✨'),
                                  backgroundColor: AppTheme.primaryPurple,
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.save),
                          label: const Text('ذخیره'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryPurple,
                            foregroundColor: Colors.white,
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
                            backgroundColor: AppTheme.bgCard,
                            foregroundColor: AppTheme.textPrimary,
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

