import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/task.dart';
import '../services/cloud_storage_service.dart';

/// Provider برای مدیریت کارها
class TaskProvider with ChangeNotifier {
  final CloudStorageService _cloudStorage = CloudStorageService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Task> _tasks = [];
  bool _isLoading = false;

  List<Task> get tasks => _tasks;

  List<Task> get completedTasks => _tasks.where((t) => t.isCompleted).toList();

  List<Task> get pendingTasks => _tasks.where((t) => !t.isCompleted).toList();

  bool get isLoading => _isLoading;

  String? get _userId => _auth.currentUser?.uid;

  // بارگذاری کارها از ابر
  Future<void> loadTasks() async {
    if (_userId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('tasks')
          .doc(_userId)
          .collection('user_tasks')
          .orderBy('createdAt', descending: true)
          .get();

      _tasks = snapshot.docs.map((doc) => Task.fromJson(doc.data())).toList();
    } catch (e) {
      debugPrint('Error loading tasks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // افزودن کار
  Future<void> addTask(Task task) async {
    if (_userId == null) return;

    try {
      await _firestore
          .collection('tasks')
          .doc(_userId)
          .collection('user_tasks')
          .doc(task.id)
          .set(task.toJson());

      _tasks.add(task);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding task: $e');
      rethrow;
    }
  }

  // به‌روزرسانی کار
  Future<void> updateTask(Task task) async {
    if (_userId == null) return;

    try {
      await _firestore
          .collection('tasks')
          .doc(_userId)
          .collection('user_tasks')
          .doc(task.id)
          .update(task.toJson());

      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = task;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating task: $e');
      rethrow;
    }
  }

  // حذف کار
  Future<void> deleteTask(String taskId) async {
    if (_userId == null) return;

    try {
      await _firestore
          .collection('tasks')
          .doc(_userId)
          .collection('user_tasks')
          .doc(taskId)
          .delete();

      _tasks.removeWhere((t) => t.id == taskId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting task: $e');
      rethrow;
    }
  }

  // تغییر وضعیت انجام
  Future<void> toggleTaskCompletion(String taskId) async {
    final task = _tasks.firstWhere((t) => t.id == taskId);
    await updateTask(task.copyWith(isCompleted: !task.isCompleted));
  }

  // دریافت کارهای امروز
  List<Task> getTodayTasks() {
    final today = DateTime.now();
    return _tasks.where((task) {
      if (task.dueDate == null) return false;
      return task.dueDate!.year == today.year &&
          task.dueDate!.month == today.month &&
          task.dueDate!.day == today.day;
    }).toList();
  }

  // دریافت کارهای انجام نشده
  List<Task> getOverdueTasks() {
    final now = DateTime.now();
    return _tasks.where((task) {
      return !task.isCompleted &&
          task.dueDate != null &&
          task.dueDate!.isBefore(now);
    }).toList();
  }
}
