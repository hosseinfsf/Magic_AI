import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// تم اصلی مانا - بنفش جادویی + طلایی گرم
class AppTheme {
  // رنگ‌های اصلی
  static const Color primaryPurple = Color(0xFF7C3AED); // بنفش عمیق
  static const Color secondaryGold = Color(0xFFEAB308); // طلایی گرم
  static const Color darkPurple = Color(0xFF6D28D9);
  static const Color lightGold = Color(0xFFFBBF24);

  // رنگ‌های پس‌زمینه
  static const Color bgDark = Color(0xFF0F0920);
  static const Color bgCard = Color(0xFF1A0F2E);
  static const Color bgLight = Color(0xFFF8F7FF);

  // رنگ‌های متن
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB8B3C9);
  static const Color textDark = Color(0xFF1A0F2E);

  // Gradients
  static const LinearGradient purpleGoldGradient = LinearGradient(
    colors: [primaryPurple, secondaryGold],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient mysticalGradient = LinearGradient(
    colors: [Color(0xFF4C1D95), Color(0xFF7C3AED), Color(0xFFA855F7)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // تم تیره (پیش‌فرض)
  static ThemeData darkTheme(BuildContext context) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryPurple,
      scaffoldBackgroundColor: bgDark,

      colorScheme: const ColorScheme.dark(
        primary: primaryPurple,
        secondary: secondaryGold,
        surface: bgCard,
        error: Color(0xFFEF4444),
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: textPrimary,
      ),

      textTheme: GoogleFonts.vazirmatnTextTheme(
        Theme
            .of(context)
            .textTheme
            .apply(
          bodyColor: textPrimary,
          displayColor: textPrimary,
        ),
      ).copyWith(
        headlineLarge: GoogleFonts.vazirmatn(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          height: 1.5,
        ),
        headlineMedium: GoogleFonts.vazirmatn(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          height: 1.4,
        ),
        bodyLarge: GoogleFonts.vazirmatn(
          fontSize: 16,
          color: textPrimary,
          height: 1.8,
        ),
        bodyMedium: GoogleFonts.vazirmatn(
          fontSize: 14,
          color: textSecondary,
          height: 1.7,
        ),
      ),

      cardTheme: CardThemeData(
        color: bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryPurple,
        foregroundColor: Colors.white,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        hintStyle: GoogleFonts.vazirmatn(
          color: textSecondary,
        ),
      ),
    );
  }

  // تم روشن
  static ThemeData lightTheme(BuildContext context) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryPurple,
      scaffoldBackgroundColor: bgLight,

      colorScheme: const ColorScheme.light(
        primary: primaryPurple,
        secondary: secondaryGold,
        surface: Colors.white,
        error: Color(0xFFEF4444),
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: textDark,
      ),

      textTheme: GoogleFonts.vazirmatnTextTheme(
        Theme
            .of(context)
            .textTheme
            .apply(
          bodyColor: textDark,
          displayColor: textDark,
        ),
      ),
    );
  }
}

