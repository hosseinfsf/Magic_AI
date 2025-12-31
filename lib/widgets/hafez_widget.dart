import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class HafezOmenWidget extends StatelessWidget {
  const HafezOmenWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: AppTheme.secondaryGold.withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [
              AppTheme.bgCard,
              Color(0xFF2C1A4C), // کمی روشن‌تر برای عمق
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.auto_stories, // آیکون کتاب شعر
                  color: AppTheme.secondaryGold,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  "فال حافظ امروز",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppTheme.lightGold,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              "ای پادشه خوبان داد از غم تنهایی\nدل بی تو به جان آمد وقت است که بازآیی",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    height: 1.8,
                  ),
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implement fetching new omen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondaryGold,
                  foregroundColor: AppTheme.textDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text("نیت کن و دوباره بگیر"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
