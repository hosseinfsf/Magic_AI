
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/settings_provider.dart';
import '../providers/user_provider.dart';

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
      body: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // New AI Settings Card
              _buildAiSettingsCard(context, settings),
              const SizedBox(height: 16),
              
              // Floating Icon Settings
              _buildFloatingIconCard(settings),
              const SizedBox(height: 16),

              // Other settings cards...
            ],
          );
        },
      ),
    );
  }

  // A new, dedicated card for AI settings
  Widget _buildAiSettingsCard(BuildContext context, SettingsProvider settings) {
    final apiKeyController = TextEditingController(text: settings.userApiKey ?? '');

    return Card(
      color: AppTheme.bgCard,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('تنظیمات هوش مصنوعی', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            
            // AI Model Selection
            ListTile(
              leading: const Icon(Icons.auto_awesome, color: AppTheme.secondaryGold),
              title: const Text('مدل AI', style: TextStyle(color: Colors.white)),
              trailing: DropdownButton<String>(
                value: settings.aiModel,
                dropdownColor: AppTheme.bgCard,
                items: const [
                  DropdownMenuItem(value: 'free', child: Text('رایگان (محدود)', style: TextStyle(color: Colors.white))),
                  DropdownMenuItem(value: 'pro', child: Text('حرفه‌ای (API شما)', style: TextStyle(color: Colors.white))),
                ],
                onChanged: (value) {
                  if (value != null) {
                    settings.setAiModel(value);
                  }
                },
              ),
            ),

            // Display usage limit for the free model
            if (settings.aiModel == 'free')
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('استفاده رایگان باقی‌مانده امروز:', style: TextStyle(color: AppTheme.textSecondary)),
                    Text('${settings.remainingUsage}', style: const TextStyle(color: AppTheme.secondaryGold, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

            // API Key input for the pro model
            if (settings.aiModel == 'pro')
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: apiKeyController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'کلید API شخصی شما',
                    labelStyle: const TextStyle(color: AppTheme.textSecondary),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.save, color: AppTheme.secondaryGold),
                      onPressed: () {
                        settings.setUserApiKey(apiKeyController.text);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('کلید API ذخیره شد!')),
                        );
                      },
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingIconCard(SettingsProvider settings) {
    return Card(
      color: AppTheme.bgCard,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('نمایش آیکون شناور', style: TextStyle(color: Colors.white)),
              value: settings.floatingEnabled,
              onChanged: (v) => settings.setFloatingEnabled(v),
              activeColor: AppTheme.primaryPurple,
            ),
             ListTile(
              title: const Text('شفافیت آیکون', style: TextStyle(color: Colors.white)),
              subtitle: Slider(
                value: settings.floatingOpacity,
                onChanged: (v) => settings.setFloatingOpacity(v),
                min: 0.2,
                max: 1.0,
                activeColor: AppTheme.primaryPurple,
                inactiveColor: AppTheme.primaryPurple.withOpacity(0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
