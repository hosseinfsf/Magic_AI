import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_profile.dart';

/// Provider برای مدیریت پروفایل کاربر
class UserProvider with ChangeNotifier {
  UserProfile? _userProfile;
  bool _isLoading = false;

  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  bool get hasProfile => _userProfile != null;

  // بارگذاری پروفایل از SharedPreferences
  Future<void> loadUserProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = prefs.getString('user_profile');
      
      if (profileJson != null) {
        final profileMap = json.decode(profileJson) as Map<String, dynamic>;
        _userProfile = UserProfile.fromJson(profileMap);
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ذخیره پروفایل کاربر
  Future<void> saveUserProfile(UserProfile profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = json.encode(profile.toJson());
      await prefs.setString('user_profile', profileJson);
      await prefs.setBool('onboarding_completed', true);
      
      _userProfile = profile;
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving user profile: $e');
    }
  }

  // به‌روزرسانی پروفایل
  Future<void> updateUserProfile(UserProfile profile) async {
    await saveUserProfile(profile);
  }

  // حذف پروفایل
  Future<void> clearUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_profile');
      await prefs.setBool('onboarding_completed', false);
      
      _userProfile = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing user profile: $e');
    }
  }

  // بررسی وضعیت onboarding
  Future<bool> checkOnboardingStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('onboarding_completed') ?? false;
    } catch (e) {
      return false;
    }
  }
}

