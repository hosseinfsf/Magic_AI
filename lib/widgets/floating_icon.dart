import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// آیکون شناور متحرک مانا با انیمیشن زنده
/// امکانات: drag, double tap, long press, pulse animation
class FloatingManaIcon extends StatefulWidget {
  final VoidCallback onDoubleTap;
  final VoidCallback onLongPress;
  final bool clipboardActive; // وقتی چیزی کپی می‌شه قرمز بشه
  final double size;
  final double opacity;

  const FloatingManaIcon({
    super.key,
    required this.onDoubleTap,
    required this.onLongPress,
    this.clipboardActive = false,
    this.size = 70.0,
    this.opacity = 1.0,
  });

  @override
  State<FloatingManaIcon> createState() => _FloatingManaIconState();
}

class _FloatingManaIconState extends State<FloatingManaIcon>
    with TickerProviderStateMixin {
  Offset position = const Offset(300, 500);
  bool isDragging = false;
  late AnimationController _pulseController;
  late AnimationController _rotateController;

  // انتخاب آیکون (گربه، سگ، ماه، خرگوش، خرس تدی)
  IconType selectedIcon = IconType.cat;

  @override
  void initState() {
    super.initState();

    // انیمیشن pulse (هر ۳ ثانیه)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // انیمیشن چرخش ملایم
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onDoubleTap: widget.onDoubleTap,
        onLongPress: widget.onLongPress,
        onPanUpdate: (details) {
          setState(() {
            isDragging = true;
            position = Offset(
              (position.dx + details.delta.dx).clamp(0.0, size.width - 80),
              (position.dy + details.delta.dy).clamp(0.0, size.height - 80),
            );
          });
        },
        onPanEnd: (_) {
          setState(() => isDragging = false);
        },
        child: Opacity(
          opacity: widget.opacity.clamp(0.0, 1.0),
          child: AnimatedScale(
            scale: isDragging ? 1.1 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: _buildIconContainer(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconContainer() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // دایره بک‌گراند با gradient
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final base = widget.size;
            return Container(
              width: base + (_pulseController.value * (base * 0.15)),
              height: base + (_pulseController.value * (base * 0.15)),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: widget.clipboardActive
                    ? const RadialGradient(
                        colors: [Colors.red, Colors.orange],
                      )
                    : const RadialGradient(
                        colors: [Color(0xFF7C3AED), Color(0xFFEAB308)],
                      ),
                boxShadow: [
                  BoxShadow(
                    color: widget.clipboardActive
                        ? Colors.red.withAlpha((0.5 * 255).round())
                        : const Color(0xFF7C3AED)
                            .withAlpha((0.5 * 255).round()),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
            );
          },
        ),

        // آیکون اصلی
        Container(
          width: widget.size * 0.85,
          height: widget.size * 0.85,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: AnimatedBuilder(
            animation: _rotateController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotateController.value * 2 * math.pi * 0.1,
                child: _buildSelectedIcon(),
              );
            },
          ),
        ),

        // Badge برای نوتیفیکیشن
        if (widget.clipboardActive)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Text(
                '!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
                .animate(onPlay: (controller) => controller.repeat())
                .shake(duration: 500.ms),
          ),
      ],
    );
  }

  Widget _buildSelectedIcon() {
    switch (selectedIcon) {
      case IconType.cat:
        return _buildCatIcon();
      case IconType.dog:
        return _buildDogIcon();
      case IconType.moon:
        return _buildMoonIcon();
      case IconType.rabbit:
        return _buildRabbitIcon();
      case IconType.teddyBear:
        return _buildTeddyBearIcon();
    }
  }

  // گربه ناز 🐱
  Widget _buildCatIcon() {
    return CustomPaint(
      size: const Size(40, 40),
      painter: CatPainter(),
    );
  }

  // سگ بامزه 🐶
  Widget _buildDogIcon() {
    return const Icon(
      Icons.pets,
      size: 35,
      color: Color(0xFF7C3AED),
    );
  }

  // ماه خوشگل 🌙
  Widget _buildMoonIcon() {
    return CustomPaint(
      size: const Size(40, 40),
      painter: MoonPainter(),
    );
  }

  // خرگوش 🐰
  Widget _buildRabbitIcon() {
    return const Icon(
      Icons.cruelty_free,
      size: 35,
      color: Color(0xFF7C3AED),
    );
  }

  // خرس تدی 🧸
  Widget _buildTeddyBearIcon() {
    return CustomPaint(
      size: const Size(40, 40),
      painter: TeddyBearPainter(),
    );
  }
}

enum IconType { cat, dog, moon, rabbit, teddyBear }

// Custom Painter برای گربه
class CatPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF7C3AED)
      ..style = PaintingStyle.fill;

    // سر گربه
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width * 0.35,
      paint,
    );

    // گوش چپ
    final leftEarPath = Path()
      ..moveTo(size.width * 0.25, size.height * 0.3)
      ..lineTo(size.width * 0.15, size.height * 0.05)
      ..lineTo(size.width * 0.35, size.height * 0.2)
      ..close();
    canvas.drawPath(leftEarPath, paint);

    // گوش راست
    final rightEarPath = Path()
      ..moveTo(size.width * 0.75, size.height * 0.3)
      ..lineTo(size.width * 0.85, size.height * 0.05)
      ..lineTo(size.width * 0.65, size.height * 0.2)
      ..close();
    canvas.drawPath(rightEarPath, paint);

    // چشم‌ها
    final eyePaint = Paint()..color = const Color(0xFFEAB308);
    canvas.drawCircle(
      Offset(size.width * 0.35, size.height * 0.45),
      size.width * 0.08,
      eyePaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.65, size.height * 0.45),
      size.width * 0.08,
      eyePaint,
    );

    // دهن (لبخند کوچولو)
    final smilePath = Path()
      ..moveTo(size.width * 0.4, size.height * 0.65)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.7,
        size.width * 0.6,
        size.height * 0.65,
      );
    canvas.drawPath(
      smilePath,
      paint
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom Painter برای ماه
class MoonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFEAB308)
      ..style = PaintingStyle.fill;

    // هلال ماه
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.5),
      size.width * 0.4,
      paint,
    );

    // سایه برای شکل هلال
    paint.color = const Color(0xFF0F0920);
    canvas.drawCircle(
      Offset(size.width * 0.65, size.height * 0.45),
      size.width * 0.35,
      paint,
    );

    // ستاره‌های کوچولو
    paint
      ..color = const Color(0xFFEAB308)
      ..style = PaintingStyle.fill;

    _drawStar(canvas, Offset(size.width * 0.15, size.height * 0.2), 3, paint);
    _drawStar(canvas, Offset(size.width * 0.85, size.height * 0.3), 2.5, paint);
    _drawStar(canvas, Offset(size.width * 0.75, size.height * 0.75), 2, paint);
  }

  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (i * 4 * math.pi / 5) - math.pi / 2;
      final x = center.dx + size * math.cos(angle);
      final y = center.dy + size * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom Painter برای خرس تدی
class TeddyBearPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFB8860B)
      ..style = PaintingStyle.fill;

    // سر
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width * 0.35,
      paint,
    );

    // گوش چپ
    canvas.drawCircle(
      Offset(size.width * 0.25, size.height * 0.25),
      size.width * 0.15,
      paint,
    );

    // گوش راست
    canvas.drawCircle(
      Offset(size.width * 0.75, size.height * 0.25),
      size.width * 0.15,
      paint,
    );

    // چشم‌ها
    final eyePaint = Paint()..color = Colors.black;
    canvas.drawCircle(
      Offset(size.width * 0.4, size.height * 0.45),
      size.width * 0.06,
      eyePaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.6, size.height * 0.45),
      size.width * 0.06,
      eyePaint,
    );

    // بینی
    paint.color = const Color(0xFF654321);
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.6),
      size.width * 0.08,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
