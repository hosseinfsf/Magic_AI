# راهنمای نصب و راه‌اندازی مانا

## پیش‌نیازها

### 1. نصب Flutter
```bash
# دانلود Flutter SDK از https://flutter.dev
# اضافه کردن به PATH
export PATH="$PATH:/path/to/flutter/bin"
```

### 2. بررسی نصب
```bash
flutter doctor
```

### 3. دریافت Gemini API Key
1. به [Google AI Studio](https://makersuite.google.com/app/apikey) بروید
2. API Key جدید ایجاد کنید
3. کلید را کپی کنید

## نصب پروژه

### 1. کلون کردن
```bash
git clone <repository-url>
cd Magic_AI
```

### 2. نصب وابستگی‌ها
```bash
flutter pub get
```

### 3. تنظیم API Key

#### روش 1: مستقیماً در کد
فایل `lib/services/gemini_service.dart` را باز کنید:
```dart
static const String _apiKey = 'YOUR_GEMINI_API_KEY'; // اینجا کلید خود را قرار دهید
```

#### روش 2: استفاده از .env (پیشنهادی)
1. پکیج `flutter_dotenv` را اضافه کنید:
```yaml
dependencies:
  flutter_dotenv: ^5.1.0
```

2. فایل `.env` در root پروژه ایجاد کنید:
```
GEMINI_API_KEY=your_actual_api_key_here
```

3. در `main.dart`:
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const ManaApp());
}
```

4. در `gemini_service.dart`:
```dart
static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
```

### 4. اجرای اپلیکیشن

#### Android
```bash
flutter run
```

#### iOS
```bash
flutter run -d ios
```

#### Web
```bash
flutter run -d chrome
```

## ساختار فایل‌ها

```
Magic_AI/
├── lib/
│   ├── core/              # کدهای اصلی
│   ├── models/            # مدل‌های داده
│   ├── providers/         # State Management
│   ├── screens/          # صفحات UI
│   ├── services/         # سرویس‌های API
│   ├── widgets/          # ویجت‌های سفارشی
│   └── utils/            # توابع کمکی
├── assets/               # فایل‌های استاتیک
│   ├── images/
│   ├── fonts/
│   └── hafez/
├── pubspec.yaml         # وابستگی‌ها
└── README.md           # مستندات
```

## تنظیمات اضافی

### اضافه کردن فونت‌های فارسی
1. فایل‌های فونت را در `assets/fonts/` قرار دهید
2. در `pubspec.yaml` ثبت کنید:
```yaml
fonts:
  - family: Vazir
    fonts:
      - asset: assets/fonts/Vazir-Regular.ttf
      - asset: assets/fonts/Vazir-Bold.ttf
        weight: 700
```

### اضافه کردن تصاویر
1. تصاویر را در `assets/images/` قرار دهید
2. در `pubspec.yaml` ثبت کنید:
```yaml
assets:
  - assets/images/
```

### تنظیمات Build

#### Android
فایل `android/app/build.gradle`:
```gradle
android {
    compileSdkVersion 34
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
    }
}
```

#### iOS
فایل `ios/Podfile`:
```ruby
platform :ios, '12.0'
```

## عیب‌یابی

### مشکل: API Key کار نمی‌کند
- بررسی کنید که کلید درست کپی شده باشد
- مطمئن شوید که API Key فعال است
- بررسی کنید که quota شما تمام نشده باشد

### مشکل: پکیج‌ها نصب نمی‌شوند
```bash
flutter clean
flutter pub get
```

### مشکل: Build Error
```bash
flutter clean
cd ios && pod deintegrate && pod install && cd ..
flutter run
```

### مشکل: خطای فارسی
- مطمئن شوید که فونت‌های فارسی اضافه شده‌اند
- از `google_fonts` استفاده کنید

## نکات مهم

⚠️ **امنیت**: هرگز API Key را در Git commit نکنید!
- از `.env` استفاده کنید
- `.env` را در `.gitignore` قرار دهید

📱 **پلتفرم**: این پروژه برای Android و iOS تست شده است.

🎨 **تم**: می‌توانید رنگ‌ها را در `lib/core/theme/app_theme.dart` تغییر دهید.

## پشتیبانی

اگر مشکلی دارید:
1. Issue در GitHub ایجاد کنید
2. لاگ‌ها را بررسی کنید
3. `flutter doctor` را اجرا کنید

---

موفق باشید! 🚀

