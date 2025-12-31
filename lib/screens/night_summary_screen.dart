import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../providers/user_provider.dart';
import '../providers/settings_provider.dart';
import '../services/night_summary_service.dart';

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
      final settings = Provider.of<SettingsProvider>(context, listen: false);
      final userProfile = userProvider.userProfile;

      // TODO: در پروژه واقعی از TaskProvider مقداردهی شود
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
        settings: settings,
      );

      if (!mounted) return;
      setState(() {
        _nightMessage = message;
      });
    } catch (e) {
      debugPrint('Error loading night summary: $e');
    } finally {
      if (!mounted) return;
      setState(() {
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
                  _buildSummaryCard(),
                  const SizedBox(height: 16),
                  _buildTaskProgressCard(),
                  const SizedBox(height: 16),
                  _buildJournalCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      color: AppTheme.bgCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppTheme.primaryPurple.withValues(alpha: 0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.nights_stay, color: AppTheme.secondaryGold),
                SizedBox(width: 12),
                Text(
                  'خلاصه شب',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _nightMessage ?? 'در حال آماده‌سازی خلاصه...',
              style: const TextStyle(color: AppTheme.textSecondary, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskProgressCard() {
    final double progress = _totalTasks > 0 ? _completedTasks / _totalTasks : 0.0;

    return Card(
      color: AppTheme.bgCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppTheme.primaryPurple.withValues(alpha: 0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.task_alt, color: AppTheme.secondaryGold),
                SizedBox(width: 12),
                Text(
                  'پیشرفت کارها',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: AppTheme.textSecondary.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.secondaryGold),
            ),
            const SizedBox(height: 8),
            Text(
              _totalTasks > 0
                  ? '${(_completedTasks * 100 ~/ _totalTasks)}% (${_completedTasks}/$_totalTasks) کار انجام شد'
                  : 'کاری ثبت نشده است',
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJournalCard() {
    return Card(
      color: AppTheme.bgCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppTheme.primaryPurple.withValues(alpha: 0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.edit_note, color: AppTheme.secondaryGold),
                SizedBox(width: 12),
                Text(
                  'یادداشت شب',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _journalController,
              maxLines: 4,
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: const InputDecoration(
                hintText: 'یادداشت شب خود را بنویسید...',
                hintStyle: TextStyle(color: AppTheme.textSecondary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                filled: true,
                fillColor: AppTheme.bgDark,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('یادداشت ذخیره شد!'),
                    backgroundColor: AppTheme.primaryPurple,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('ذخیره یادداشت'),
            ),
          ],
        ),
      ),
    );
  }
}
