import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../providers/task_provider.dart'; // Get real tasks
import '../providers/user_provider.dart';
import '../services/hafez_service.dart'; // For daily omen
import '../services/morning_mana_service.dart';

// A data class to hold all the morning info
class MorningManaData {
  final String weather;
  final String hafezOmen;
  final String motivationalQuote;
  final String dailyEvent;
  final List<String> tasks;
  final String? sportsNews;

  MorningManaData({
    required this.weather,
    required this.hafezOmen,
    required this.motivationalQuote,
    required this.dailyEvent,
    required this.tasks,
    this.sportsNews,
  });
}

class MorningManaScreen extends StatefulWidget {
  const MorningManaScreen({super.key});

  @override
  State<MorningManaScreen> createState() => _MorningManaScreenState();
}

class _MorningManaScreenState extends State<MorningManaScreen> {
  final MorningManaService _service = MorningManaService();
  MorningManaData? _morningData;
  bool _isLoading = true;
  String _userName = 'عزیزم';

  @override
  void initState() {
    super.initState();
    _loadMorningMana();
  }

  Future<void> _loadMorningMana() async {
    setState(() => _isLoading = true);

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      final userProfile = userProvider.userProfile;

      setState(() {
        _userName = userProfile?.name ?? 'عزیزم';
      });

      // Fetch all data in parallel for speed
      final results = await Future.wait([
        _service.getWeather(userProfile?.city ?? 'تهران'),
        _service.getMotivationalQuote(),
        _service.getDailyEvent(),
        Future.value(HafezService.getRandomFortune()), // Daily Hafez - already a Map
        Future.value(taskProvider.getTodayTasks().map((t) => t.title).toList()), // Real tasks via provider method
        _service.getSportsNews(userProvider.userProfile?.favoriteTeam ?? 'فوتبال'), // Use preference
      ]);

      setState(() {
        // Hafez fortune could be a String or Map depending on service; handle both gracefully
        final hafezRaw = results[3];
        final hafezText = hafezRaw is String
            ? hafezRaw
            : (hafezRaw is Map && hafezRaw['text'] != null && hafezRaw['text'] is String)
                ? hafezRaw['text'] as String
                : 'فالی یافت نشد.';

        _morningData = MorningManaData(
          weather: results[0] as String,
          motivationalQuote: results[1] as String,
          dailyEvent: results[2] as String,
          hafezOmen: hafezText,
          tasks: (results[4] as List<String>),
          sportsNews: results[5] as String?,
        );
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _morningData = null;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppTheme.primaryPurple,
            expandedHeight: 120.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('صبح بخیر $_userName! ☀️',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18)),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppTheme.mysticalGradient,
                ),
              ),
            ),
          ),
          _isLoading
              ? const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                        color: AppTheme.secondaryGold),
                  ),
                )
              : _morningData == null
                  ? _buildErrorState()
                  : _buildDashboard(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadMorningMana,
        backgroundColor: AppTheme.secondaryGold,
        child: const Icon(Icons.refresh, color: AppTheme.textDark),
      ),
    );
  }

  Widget _buildDashboard() {
    return SliverPadding(
      padding: const EdgeInsets.all(16.0),
      sliver: SliverList(
        delegate: SliverChildListDelegate(
          [
            _buildInfoCard(
                Icons.wb_sunny_outlined, 'آب و هوا', _morningData!.weather),
            const SizedBox(height: 16),
            _buildInfoCard(
                Icons.task_alt,
                'کارهای امروز',
                _morningData!.tasks.isEmpty
                    ? 'هیچ کاری برای امروز ثبت نشده است.'
                    : _morningData!.tasks.map((t) => '- $t').join('\n')),
            const SizedBox(height: 16),
            _buildInfoCard(Icons.auto_stories_outlined, 'فال حافظ',
                _morningData!.hafezOmen),
            const SizedBox(height: 16),
            _buildInfoCard(Icons.celebration_outlined, 'مناسبت امروز',
                _morningData!.dailyEvent),
            const SizedBox(height: 16),
            _buildInfoCard(Icons.format_quote, 'جمله انگیزشی',
                _morningData!.motivationalQuote),
            if (_morningData!.sportsNews != null) ...[
              const SizedBox(height: 16),
              _buildInfoCard(Icons.sports_soccer_outlined, 'خبر ورزشی',
                  _morningData!.sportsNews!),
            ],
          ]
              .animate(interval: 100.ms)
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.2, end: 0),
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String content) {
    if (content.isEmpty) return const SizedBox.shrink();

    return Card(
      color: AppTheme.bgCard.withValues(alpha: 0.8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
            color: AppTheme.primaryPurple.withValues(alpha: 0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.secondaryGold, size: 24),
                const SizedBox(width: 12),
                Text(title,
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(color: Colors.white)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style:
                  Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.7),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return const SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off, color: AppTheme.textSecondary, size: 60),
            SizedBox(height: 16),
            Text(
              'خطا در دریافت اطلاعات. لطفا دوباره تلاش کنید.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
