
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class SettingsProvider with ChangeNotifier {
  // --- Existing Keys ---
  static const _kFloatingEnabled = 'floating_enabled';
  static const _kFloatingOpacity = 'floating_opacity';
  static const _kFloatingSize = 'floating_size';
  static const _kLanguage = 'app_language';

  // --- New Keys for AI Settings ---
  static const _kAiModel = 'ai_model';
  static const _kUserApiKey = 'user_api_key';
  static const _kDailyUsageCount = 'daily_usage_count';
  static const _kLastUsageDate = 'last_usage_date';

  // --- Existing State ---
  bool _floatingEnabled = true;
  double _floatingOpacity = 1.0;
  double _floatingSize = 70.0;
  String _language = 'fa';

  // --- New State for AI Settings ---
  String _aiModel = 'free'; // 'free' or 'pro'
  String? _userApiKey;
  int _dailyUsageCount = 0;
  String _lastUsageDate = '';
  
  static const int dailyLimit = 20; // 20 free requests per day

  // --- Getters ---
  bool get floatingEnabled => _floatingEnabled;
  double get floatingOpacity => _floatingOpacity;
  double get floatingSize => _floatingSize;
  String get language => _language;
  String get aiModel => _aiModel;
  String? get userApiKey => _userApiKey;
  int get remainingUsage => dailyLimit - _dailyUsageCount;
  bool get isFreeTierLimitReached => _aiModel == 'free' && _dailyUsageCount >= dailyLimit;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    // Load existing settings
    _floatingEnabled = prefs.getBool(_kFloatingEnabled) ?? true;
    _floatingOpacity = prefs.getDouble(_kFloatingOpacity) ?? 1.0;
    _floatingSize = prefs.getDouble(_kFloatingSize) ?? 70.0;
    _language = prefs.getString(_kLanguage) ?? 'fa';

    // Load new AI settings
    _aiModel = prefs.getString(_kAiModel) ?? 'free';
    _userApiKey = prefs.getString(_kUserApiKey);
    _lastUsageDate = prefs.getString(_kLastUsageDate) ?? '';

    // Check and reset daily usage
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    if (_lastUsageDate != today) {
      _dailyUsageCount = 0;
      _lastUsageDate = today;
      await prefs.setInt(_kDailyUsageCount, 0);
      await prefs.setString(_kLastUsageDate, today);
    } else {
      _dailyUsageCount = prefs.getInt(_kDailyUsageCount) ?? 0;
    }

    notifyListeners();
  }

  // --- Setters for Existing Settings ---
  Future<void> setFloatingEnabled(bool v) async {
    _floatingEnabled = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kFloatingEnabled, v);
    notifyListeners();
  }
  // ... other existing setters

  // --- Setters for New AI Settings ---
  Future<void> setAiModel(String model) async {
    _aiModel = model;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAiModel, model);
    notifyListeners();
  }

  Future<void> setUserApiKey(String key) async {
    _userApiKey = key;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUserApiKey, key);
    notifyListeners();
  }

  // --- Usage Tracking ---
  Future<void> incrementUsage() async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    if (_lastUsageDate != today) {
      _dailyUsageCount = 1;
      _lastUsageDate = today;
    } else {
      _dailyUsageCount++;
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kDailyUsageCount, _dailyUsageCount);
    await prefs.setString(_kLastUsageDate, _lastUsageDate);
    notifyListeners();
  }
}
