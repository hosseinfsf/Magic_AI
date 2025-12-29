import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider برای تنظیمات اپلیکیشن (شناور، اندازه، شفافیت، زبان)
class SettingsProvider with ChangeNotifier {
  static const _kFloatingEnabled = 'floating_enabled';
  static const _kFloatingOpacity = 'floating_opacity';
  static const _kFloatingSize = 'floating_size';
  static const _kLanguage = 'app_language';

  bool _floatingEnabled = true;
  double _floatingOpacity = 1.0;
  double _floatingSize = 70.0;
  String _language = 'fa';

  bool get floatingEnabled => _floatingEnabled;
  double get floatingOpacity => _floatingOpacity;
  double get floatingSize => _floatingSize;
  String get language => _language;

  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _floatingEnabled = prefs.getBool(_kFloatingEnabled) ?? true;
      _floatingOpacity = prefs.getDouble(_kFloatingOpacity) ?? 1.0;
      _floatingSize = prefs.getDouble(_kFloatingSize) ?? 70.0;
      _language = prefs.getString(_kLanguage) ?? 'fa';
      notifyListeners();
    } catch (e) {
      if (kDebugMode) debugPrint('Error loading settings: $e');
    }
  }

  Future<void> setFloatingEnabled(bool v) async {
    _floatingEnabled = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kFloatingEnabled, v);
  }

  Future<void> setFloatingOpacity(double v) async {
    _floatingOpacity = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kFloatingOpacity, v);
  }

  Future<void> setFloatingSize(double v) async {
    _floatingSize = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kFloatingSize, v);
  }

  Future<void> setLanguage(String lang) async {
    _language = lang;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLanguage, lang);
  }
}
