import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/theme/app_theme.dart';

/// نشانگر تایپ کردن (برای نمایش هنگام پاسخ دادن دستیار)
class TypingIndicator extends StatelessWidget {
  const TypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: const BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
          bottomLeft: Radius.circular(4),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDot(0),
          const SizedBox(width: 4),
          _buildDot(1),
          const SizedBox(width: 4),
          _buildDot(2),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: AppTheme.textSecondary,
        shape: BoxShape.circle,
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .fadeIn(
          duration: 600.ms,
          delay: Duration(milliseconds: index * 200),
        )
        .then()
        .fadeOut(duration: 600.ms);
  }
}
