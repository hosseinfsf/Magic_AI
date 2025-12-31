
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/settings_provider.dart';
import '../providers/user_provider.dart';
import '../providers/chat_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text('تنظیمات', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildAiSettingsCard(context, settings),
              const SizedBox(height: 16),
              _buildFloatingIconCard(settings),
              const SizedBox(height: 16),
              _buildPersonalizationCard(context),
              const SizedBox(height: 16),
              _buildChatSettingsCard(context),
              const SizedBox(height: 16),
              _buildAboutCard(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAiSettingsCard(BuildContext context, SettingsProvider settings) {
    final apiKeyController = TextEditingController(text: settings.userApiKey ?? '');

    return Card(
      color: AppTheme.bgCard,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('تنظیمات هوش مصنوعی (AI)', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            
            // AI Model Selection
            ListTile(
              leading: const Icon(Icons.auto_awesome, color: AppTheme.secondaryGold),
              title: const Text('مدل AI', style: TextStyle(color: Colors.white)),
              trailing: DropdownButton<String>(
                value: settings.aiModel,
                dropdownColor: AppTheme.bgCard,
                underline: const SizedBox.shrink(),
                items: const [
                  DropdownMenuItem(value: 'free', child: Text('رایگان (دو مدل)', style: TextStyle(color: Colors.white))),
                  DropdownMenuItem(value: 'pro', child: Text('حرفه‌ای (API شما)', style: TextStyle(color: Colors.white))),
                ],
                onChanged: (value) {
                  if (value != null) settings.setAiModel(value);
                },
              ),
            ),

            const SizedBox(height: 8),

            // AI Provider Selection
            ListTile(
              leading: const Icon(Icons.hub, color: AppTheme.secondaryGold),
              title: const Text('ارائه‌دهنده AI', style: TextStyle(color: Colors.white)),
              subtitle: const Text('یکی را انتخاب کنید', style: TextStyle(color: AppTheme.textSecondary)),
              trailing: DropdownButton<String>(
                value: settings.aiProvider,
                dropdownColor: AppTheme.bgCard,
                underline: const SizedBox.shrink(),
                items: const [
                  DropdownMenuItem(value: 'gemini', child: Text('Google Gemini', style: TextStyle(color: Colors.white))),
                  DropdownMenuItem(value: 'openRouter', child: Text('OpenRouter', style: TextStyle(color: Colors.white))),
                  DropdownMenuItem(value: 'togetherAi', child: Text('Together AI', style: TextStyle(color: Colors.white))),
                ],
                onChanged: (value) {
                  if (value != null) settings.setAiProvider(value);
                },
              ),
            ),

            if (settings.aiProvider == 'openRouter')
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: TextField(
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'OpenRouter API Key',
                    labelStyle: const TextStyle(color: AppTheme.textSecondary),
                    filled: true,
                    fillColor: AppTheme.bgDark.withValues(alpha: 0.5),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  onSubmitted: (v) {
                    settings.setOpenRouterKey(v.trim());
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('کلید OpenRouter ذخیره شد!')));
                  },
                ),
              ),

            if (settings.aiProvider == 'togetherAi')
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: TextField(
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'TogetherAI API Key',
                    labelStyle: const TextStyle(color: AppTheme.textSecondary),
                    filled: true,
                    fillColor: AppTheme.bgDark.withValues(alpha: 0.5),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  onSubmitted: (v) {
                    settings.setTogetherAiKey(v.trim());
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('کلید TogetherAI ذخیره شد!')));
                  },
                ),
              ),

            // Usage Limit / API Key Input
            if (settings.aiModel == 'free')
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('درخواست‌های رایگان باقی‌مانده امروز:', style: TextStyle(color: settings.remainingUsage > 5 ? AppTheme.textSecondary : Colors.redAccent)),
                    Text('${settings.remainingUsage}', style: const TextStyle(color: AppTheme.secondaryGold, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

            if (settings.aiModel == 'pro')
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: TextField(
                  controller: apiKeyController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'کلید API شخصی شما',
                    labelStyle: const TextStyle(color: AppTheme.textSecondary),
                    filled: true,
                    fillColor: AppTheme.bgDark.withValues(alpha: 0.5),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.save, color: AppTheme.secondaryGold),
                      onPressed: () {
                        settings.setUserApiKey(apiKeyController.text.trim());
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('کلید API ذخیره شد!')));
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
              activeThumbColor: AppTheme.primaryPurple,
            ),
             ListTile(
              title: const Text('شفافیت آیکون', style: TextStyle(color: Colors.white)),
              subtitle: Slider(
                value: settings.floatingOpacity,
                onChanged: (v) => settings.setFloatingOpacity(v),
                min: 0.2,
                max: 1.0,
                activeColor: AppTheme.primaryPurple,
                inactiveColor: AppTheme.primaryPurple.withValues(alpha: 0.3),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPersonalizationCard(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentTeam = userProvider.userProfile?.favoriteTeam;
    final List<String> teams = ['پرسپولیس', 'استقلال', 'سپاهان', 'تراکتور', 'سایر'];

    return Card(
      color: AppTheme.bgCard,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('شخصی‌سازی (صبحانه مانا)', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.sports_soccer, color: AppTheme.secondaryGold),
              title: const Text('تیم ورزشی مورد علاقه', style: TextStyle(color: Colors.white)),
              trailing: DropdownButton<String>(
                value: teams.contains(currentTeam) ? currentTeam : null,
                hint: const Text('انتخاب', style: TextStyle(color: AppTheme.textSecondary)),
                dropdownColor: AppTheme.bgCard,
                underline: const SizedBox.shrink(),
                items: teams.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
                onChanged: (newValue) {
                  if (newValue != null) userProvider.updateFavoriteTeam(newValue);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatSettingsCard(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    return Card(
      color: AppTheme.bgCard,
      child: ListTile(
        leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
        title: const Text('پاک کردن تاریخچه چت', style: TextStyle(color: Colors.redAccent)),
        subtitle: const Text('تمام پیام‌های ذخیره‌شده پاک می‌شوند', style: TextStyle(color: AppTheme.textSecondary)),
        onTap: () async {
          await chatProvider.clearChat();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تاریخچه چت پاک شد.')));
        },
      ),
    );
  }

  Widget _buildAboutCard(BuildContext context) {
    return Card(
      color: AppTheme.bgCard,
      child: ListTile(
        leading: const Icon(Icons.info_outline, color: AppTheme.textSecondary),
        title: const Text('درباره مانا', style: TextStyle(color: AppTheme.textSecondary)),
        onTap: () => showAboutDialog(
          context: context,
          applicationName: 'مانا - دستیار هوشمند',
          applicationVersion: '1.0.0',
          applicationIcon: const Icon(Icons.pets, color: AppTheme.primaryPurple),
          children: [
            const Text('\nساخته شده با ❤️ و Flutter. با مانا، هوشمندانه زندگی کن.', style: TextStyle(color: AppTheme.textPrimary)),
          ],
        ),
      ),
    );
  }
}
