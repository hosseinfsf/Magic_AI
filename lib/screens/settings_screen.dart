import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/user_provider.dart';
import '../providers/chat_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text('تنظیمات'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // پروفایل کاربر
          Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              final profile = userProvider.userProfile;
              if (profile == null) {
                return const SizedBox.shrink();
              }
              
              return Card(
                color: AppTheme.bgCard,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'پروفایل شما',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildProfileItem('نام', profile.name),
                      _buildProfileItem('گروه سنی', profile.ageGroup),
                      _buildProfileItem('فعالیت', profile.dailyActivity),
                      _buildProfileItem('ماه تولد', profile.birthMonth),
                      _buildProfileItem('شهر', profile.city),
                    ],
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          // تنظیمات چت
          Card(
            color: AppTheme.bgCard,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: AppTheme.textPrimary),
                  title: const Text(
                    'پاک کردن چت',
                    style: TextStyle(color: AppTheme.textPrimary),
                  ),
                  subtitle: const Text(
                    'تمام پیام‌های چت پاک می‌شوند',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                  onTap: () => _showClearChatDialog(context),
                ),
                const Divider(color: AppTheme.textSecondary, height: 1),
                ListTile(
                  leading: const Icon(Icons.refresh, color: AppTheme.textPrimary),
                  title: const Text(
                    'شروع مجدد چت',
                    style: TextStyle(color: AppTheme.textPrimary),
                  ),
                  subtitle: const Text(
                    'شروع یک گفتگوی جدید',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                  onTap: () {
                    Provider.of<ChatProvider>(context, listen: false)
                        .clearChat()
                        .then((_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('چت پاک شد'),
                          backgroundColor: AppTheme.primaryPurple,
                        ),
                      );
                    });
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // درباره
          Card(
            color: AppTheme.bgCard,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline, color: AppTheme.textPrimary),
                  title: const Text(
                    'درباره مانا',
                    style: TextStyle(color: AppTheme.textPrimary),
                  ),
                  onTap: () => _showAboutDialog(context),
                ),
                const Divider(color: AppTheme.textSecondary, height: 1),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    'خروج و حذف اطلاعات',
                    style: TextStyle(color: Colors.red),
                  ),
                  subtitle: const Text(
                    'تمام اطلاعات شما پاک می‌شود',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                  onTap: () => _showLogoutDialog(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showClearChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        title: const Text(
          'پاک کردن چت',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: const Text(
          'آیا مطمئن هستید که می‌خواهید تمام پیام‌های چت را پاک کنید؟',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('لغو'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<ChatProvider>(context, listen: false).clearChat();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('چت پاک شد'),
                  backgroundColor: AppTheme.primaryPurple,
                ),
              );
            },
            child: const Text(
              'پاک کردن',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        title: const Text(
          'درباره مانا',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: const Text(
          'مانا - دستیار هوشمند همه‌کاره\n\n'
          'نسخه: 1.0.0\n\n'
          'مانا یک دستیار هوش مصنوعی است که می‌تواند در کارهای مختلف به شما کمک کند:\n'
          '• چت هوشمند\n'
          '• فال حافظ\n'
          '• تولید محتوا برای شبکه‌های اجتماعی\n'
          '• خلاصه‌سازی متن\n'
          '• و خیلی چیزهای دیگر...\n\n'
          'ساخته شده با ❤️ و Flutter',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('بستن'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        title: const Text(
          'خروج و حذف اطلاعات',
          style: TextStyle(color: Colors.red),
        ),
        content: const Text(
          'آیا مطمئن هستید؟ تمام اطلاعات شما شامل پروفایل و چت‌ها پاک می‌شود.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('لغو'),
          ),
          TextButton(
            onPressed: () async {
              final userProvider = Provider.of<UserProvider>(context, listen: false);
              final chatProvider = Provider.of<ChatProvider>(context, listen: false);
              
              await userProvider.clearUserProfile();
              await chatProvider.clearChat();
              
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/onboarding');
              }
            },
            child: const Text(
              'حذف و خروج',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

