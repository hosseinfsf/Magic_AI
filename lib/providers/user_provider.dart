import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';

class UserProvider with ChangeNotifier {
  UserProfile? _userProfile;
  bool _isLoading = false;

  UserProfile? get userProfile => _userProfile;

  bool get isLoading => _isLoading;

  bool get hasProfile => _userProfile != null;

  Future<void> loadUserProfile() async {
    _isLoading = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = prefs.getString('user_profile');
      if (profileJson != null) {
        _userProfile = UserProfile.fromJson(json.decode(profileJson));
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    _userProfile = profile;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_profile', json.encode(profile.toJson()));
    await prefs.setBool('onboarding_completed', profile.hasCompletedOnboarding);
    notifyListeners();
  }

  // New method to update only the favorite team
  Future<void> updateFavoriteTeam(String team) async {
    if (_userProfile != null) {
      // Create a new profile instance with the updated team
      final updatedProfile = _userProfile!.copyWith(favoriteTeam: team);
      // Save the updated profile
      await saveUserProfile(updatedProfile);
    }
  }

  Future<void> clearUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_profile');
    await prefs.setBool('onboarding_completed', false);
    _userProfile = null;
    notifyListeners();
  }

  Future<bool> checkOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding_completed') ?? false;
  }
}
