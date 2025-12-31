import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/chat_message.dart';
import '../models/user_profile.dart';

/// سرویس ذخیره‌سازی ابری با Firestore
class CloudStorageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection references
  CollectionReference get _usersCollection => _firestore.collection('users');

  CollectionReference get _chatsCollection => _firestore.collection('chats');

  CollectionReference get _tasksCollection => _firestore.collection('tasks');

  CollectionReference get _preferencesCollection =>
      _firestore.collection('user_preferences');

  String? get _userId => _auth.currentUser?.uid;

  /// ذخیره پروفایل کاربر در ابر
  Future<void> saveUserProfile(UserProfile profile) async {
    if (_userId == null) throw Exception('User not authenticated');

    try {
      await _usersCollection.doc(_userId).set({
        ...profile.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving user profile: $e');
      rethrow;
    }
  }

  /// بارگذاری پروفایل کاربر از ابر
  Future<UserProfile?> loadUserProfile() async {
    if (_userId == null) return null;

    try {
      final doc = await _usersCollection.doc(_userId).get();
      if (doc.exists && doc.data() != null) {
        return UserProfile.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      debugPrint('Error loading user profile: $e');
      return null;
    }
  }

  /// ذخیره پیام‌های چت در ابر
  Future<void> saveChatMessage(ChatMessage message) async {
    if (_userId == null) throw Exception('User not authenticated');

    try {
      await _chatsCollection
          .doc(_userId)
          .collection('messages')
          .doc(message.id)
          .set(message.toJson());
    } catch (e) {
      debugPrint('Error saving chat message: $e');
      rethrow;
    }
  }

  /// بارگذاری پیام‌های چت از ابر
  Future<List<ChatMessage>> loadChatMessages({int limit = 100}) async {
    if (_userId == null) return [];

    try {
      final snapshot = await _chatsCollection
          .doc(_userId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => ChatMessage.fromJson(doc.data()))
          .toList()
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    } catch (e) {
      debugPrint('Error loading chat messages: $e');
      return [];
    }
  }

  /// پاک کردن چت از ابر
  Future<void> clearChat() async {
    if (_userId == null) throw Exception('User not authenticated');

    try {
      final batch = _firestore.batch();
      final messagesRef = _chatsCollection.doc(_userId).collection('messages');

      final snapshot = await messagesRef.get();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error clearing chat: $e');
      rethrow;
    }
  }

  /// ذخیره ترجیحات کاربر (برای یادگیری)
  Future<void> saveUserPreferences(Map<String, dynamic> preferences) async {
    if (_userId == null) throw Exception('User not authenticated');

    try {
      await _preferencesCollection.doc(_userId).set({
        ...preferences,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving user preferences: $e');
      rethrow;
    }
  }

  /// بارگذاری ترجیحات کاربر
  Future<Map<String, dynamic>> loadUserPreferences() async {
    if (_userId == null) return {};

    try {
      final doc = await _preferencesCollection.doc(_userId).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        data.remove('updatedAt');
        return data;
      }
      return {};
    } catch (e) {
      debugPrint('Error loading user preferences: $e');
      return {};
    }
  }

  /// ذخیره رفتار کاربر (برای یادگیری AI)
  Future<void> saveUserBehavior({
    required String action,
    required Map<String, dynamic> context,
  }) async {
    if (_userId == null) return;

    try {
      await _firestore
          .collection('user_behaviors')
          .doc(_userId)
          .collection('actions')
          .add({
        'action': action,
        'context': context,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error saving user behavior: $e');
      // Don't throw - this is non-critical
    }
  }

  /// بارگذاری تاریخچه رفتار کاربر
  Future<List<Map<String, dynamic>>> loadUserBehaviorHistory({
    int limit = 50,
  }) async {
    if (_userId == null) return [];

    try {
      final snapshot = await _firestore
          .collection('user_behaviors')
          .doc(_userId)
          .collection('actions')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();
    } catch (e) {
      debugPrint('Error loading user behavior: $e');
      return [];
    }
  }

  /// همگام‌سازی داده‌های محلی با ابر
  Future<void> syncWithCloud({
    required UserProfile? localProfile,
    required List<ChatMessage> localMessages,
  }) async {
    if (_userId == null) return;

    try {
      // همگام‌سازی پروفایل
      if (localProfile != null) {
        await saveUserProfile(localProfile);
      }

      // همگام‌سازی پیام‌ها
      for (var message in localMessages) {
        await saveChatMessage(message);
      }
    } catch (e) {
      debugPrint('Error syncing with cloud: $e');
    }
  }
}
