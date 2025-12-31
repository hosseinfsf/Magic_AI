
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

/// Provider برای تنظیمات اپلیکیشن (شناور، AI Model، API Key، و...)
class SettingsProvider with ChangeNotifier {
  // --- Keys ---
  static const _kFloatingEnabled = 'floating_enabled';
  static const _kFloatingOpacity = 'floating_opacity';
  static const _kFloatingSize = 'floating_size';
  static const _kLanguage = 'app_language';
  static const _kAiModel = 'ai_model';
  static const _kUserApiKey = 'user_api_key';
  static const _kDailyUsageCount = 'daily_usage_count';
  static const _kLastUsageDate = 'last_usage_date';
  // New keys for multi-provider selection and keys
  static const _kAiProvider = 'ai_provider_type';
  static const _kOpenRouterKey = 'openrouter_api_key';
  static const _kTogetherAiKey = 'together_api_key';

  // --- State ---
  bool _floatingEnabled = true;
  double _floatingOpacity = 1.0;
  double _floatingSize = 70.0;
  String _language = 'fa';
  String _aiModel = 'free'; // 'free' or 'pro'
  String? _userApiKey;
  int _dailyUsageCount = 0;
  String _lastUsageDate = '';
  
  // Multi-provider state
  String _aiProvider = 'gemini'; // 'gemini' | 'openRouter' | 'togetherAi'
  String? _openRouterKey;
  String? _togetherAiKey;
  
  static const int dailyLimit = 20;

  // --- Getters ---
  bool get floatingEnabled => _floatingEnabled;
  double get floatingOpacity => _floatingOpacity;
  double get floatingSize => _floatingSize;
  String get language => _language;
  String get aiModel => _aiModel;
  String? get userApiKey => _userApiKey;
  int get remainingUsage => dailyLimit - _dailyUsageCount;
  bool get isFreeTierLimitReached => _aiModel == 'free' && _dailyUsageCount >= dailyLimit;

  // Expose provider selection and keys
  String get aiProvider => _aiProvider;
  String? get openRouterKey => _openRouterKey;
  String? get togetherAiKey => _togetherAiKey;

  // --- Initialization and Loading ---
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load existing settings
    _floatingEnabled = prefs.getBool(_kFloatingEnabled) ?? true;
    _floatingOpacity = prefs.getDouble(_kFloatingOpacity) ?? 1.0;
    _floatingSize = prefs.getDouble(_kFloatingSize) ?? 70.0;
    _language = prefs.getString(_kLanguage) ?? 'fa';

    // Load AI settings
    _aiModel = prefs.getString(_kAiModel) ?? 'free';
    _userApiKey = prefs.getString(_kUserApiKey);
    _lastUsageDate = prefs.getString(_kLastUsageDate) ?? '';

    // Multi provider
    _aiProvider = prefs.getString(_kAiProvider) ?? 'gemini';
    _openRouterKey = prefs.getString(_kOpenRouterKey);
    _togetherAiKey = prefs.getString(_kTogetherAiKey);

    // Check and reset daily usage (Core Logic)
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    if (_lastUsageDate != today) {
      // New day, reset counter
      _dailyUsageCount = 0;
      _lastUsageDate = today;
      await prefs.setInt(_kDailyUsageCount, 0);
      await prefs.setString(_kLastUsageDate, today);
    } else {
      // Same day, load previous count
      _dailyUsageCount = prefs.getInt(_kDailyUsageCount) ?? 0;
    }

    notifyListeners();
  }

  // --- Setters ---
  
  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    }
  }

  Future<void> setFloatingEnabled(bool v) async {
    _floatingEnabled = v;
    await _saveSetting(_kFloatingEnabled, v);
    notifyListeners();
  }

  Future<void> setFloatingOpacity(double v) async {
    _floatingOpacity = v;
    await _saveSetting(_kFloatingOpacity, v);
    notifyListeners();
  }

  Future<void> setFloatingSize(double v) async {
    _floatingSize = v;
    await _saveSetting(_kFloatingSize, v);
    notifyListeners();
  }

  Future<void> setLanguage(String lang) async {
    _language = lang;
    await _saveSetting(_kLanguage, lang);
    notifyListeners();
  }

  Future<void> setAiModel(String model) async {
    _aiModel = model;
    await _saveSetting(_kAiModel, model);
    notifyListeners();
  }

  Future<void> setUserApiKey(String key) async {
    _userApiKey = key;
    await _saveSetting(_kUserApiKey, key);
    notifyListeners();
  }

  Future<void> setAiProvider(String provider) async {
    _aiProvider = provider;
    await _saveSetting(_kAiProvider, provider);
    notifyListeners();
  }

  Future<void> setOpenRouterKey(String key) async {
    _openRouterKey = key;
    await _saveSetting(_kOpenRouterKey, key);
    notifyListeners();
  }

  Future<void> setTogetherAiKey(String key) async {
    _togetherAiKey = key;
    await _saveSetting(_kTogetherAiKey, key);
    notifyListeners();
  }

  // --- Usage Tracking ---
  Future<void> incrementUsage() async {
    // Logic to reset usage is already in loadSettings, we only increment here
    _dailyUsageCount++;
    await _saveSetting(_kDailyUsageCount, _dailyUsageCount);
    notifyListeners();
  }
}
