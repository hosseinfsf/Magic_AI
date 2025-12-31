import 'package:intl/intl.dart';

/// کلاس کمکی برای توابع عمومی
class AppHelper {
  /// فرمت کردن تاریخ
  static String formatDate(DateTime date,
      {String format = 'yyyy/MM/dd HH:mm'}) {
    return DateFormat(format, 'fa').format(date);
  }

  /// فرمت کردن زمان
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm', 'fa').format(date);
  }

  /// فرمت کردن تاریخ شمسی
  static String formatJalaliDate(DateTime date) {
    // در پروژه واقعی از shamsi_date استفاده کنید
    return DateFormat('yyyy/MM/dd', 'fa').format(date);
  }

  /// بررسی اینکه آیا متن خالی است
  static bool isEmpty(String? text) {
    return text == null || text
        .trim()
        .isEmpty;
  }

  /// محدود کردن طول متن
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// استخراج هشتگ‌ها از متن
  static List<String> extractHashtags(String text) {
    final regex = RegExp(r'#\w+');
    return regex.allMatches(text).map((m) => m.group(0)!).toList();
  }

  /// استخراج mention‌ها از متن
  static List<String> extractMentions(String text) {
    final regex = RegExp(r'@\w+');
    return regex.allMatches(text).map((m) => m.group(0)!).toList();
  }

  /// تبدیل عدد به متن فارسی
  static String toPersianNumber(String text) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const persian = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];

    String result = text;
    for (int i = 0; i < english.length; i++) {
      result = result.replaceAll(english[i], persian[i]);
    }
    return result;
  }

  /// تبدیل متن فارسی به عدد انگلیسی
  static String toEnglishNumber(String text) {
    const persian = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

    String result = text;
    for (int i = 0; i < persian.length; i++) {
      result = result.replaceAll(persian[i], english[i]);
    }
    return result;
  }

  /// تولید ID منحصر به فرد
  static String generateId() {
    return DateTime
        .now()
        .millisecondsSinceEpoch
        .toString();
  }

  /// بررسی اعتبار ایمیل
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// بررسی اعتبار شماره تلفن ایرانی
  static bool isValidIranianPhone(String phone) {
    return RegExp(r'^09\d{9}$').hasMatch(
        phone.replaceAll(RegExp(r'[\s-]'), ''));
  }
}

