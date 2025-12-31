import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/task.dart';

/// Provider برای مدیریت کارها
class TaskProvider with ChangeNotifier {
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
          .collection('users')
          .doc(_userId)
          .collection('tasks')
          .orderBy('createdAt', descending: true)
          .get();

      _tasks = snapshot.docs
          .map((doc) => Task.fromFirestore(doc))
          .where((task) => task.title.isNotEmpty) // Filter out empty tasks
          .toList();
    } catch (e) {
      debugPrint('Error loading tasks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // دریافت کارهای امروز
  List<Task> getTodayTasks() {
    final now = DateTime.now();
    return _tasks.where((task) {
      final taskDate = task.createdAt;
      return taskDate.day == now.day &&
          taskDate.month == now.month &&
          taskDate.year == now.year;
    }).toList();
  }

  // تغییر وضعیت تکمیل کار
  Future<void> toggleTaskCompletion(String taskId) async {
    final task = _tasks.firstWhere((t) => t.id == taskId);
    final index = _tasks.indexOf(task);

    // Update locally first for immediate UI feedback
    _tasks[index] = task.copyWith(isCompleted: !task.isCompleted);
    notifyListeners();

    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('tasks')
          .doc(taskId)
          .update({'isCompleted': _tasks[index].isCompleted});
    } catch (e) {
      // Rollback in case of error
      _tasks[index] = task.copyWith(isCompleted: task.isCompleted);
      notifyListeners();
      debugPrint('Error updating task: $e');
    }
  }

  // افزودن یک کار جدید
  Future<void> addTask(String title) async {
    if (title.trim().isEmpty) return;

    final newTask = Task(
      id: '',
      title: title.trim(),
      isCompleted: false,
      createdAt: DateTime.now(),
    );

    // Add locally first for immediate UI feedback
    _tasks.insert(0, newTask);
    notifyListeners();

    try {
      final docRef = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('tasks')
          .add({
        'title': newTask.title,
        'isCompleted': newTask.isCompleted,
        'createdAt': newTask.createdAt,
      });

      // Update with actual document ID
      final index = _tasks.indexOf(newTask);
      if (index != -1) {
        _tasks[index] = newTask.copyWith(id: docRef.id);
        notifyListeners();
      }
    } catch (e) {
      // Remove the task if saving failed
      _tasks.remove(newTask);
      notifyListeners();
      debugPrint('Error adding task: $e');
    }
  }

  // حذف یک کار
  Future<void> deleteTask(String taskId) async {
    final task = _tasks.firstWhere((t) => t.id == taskId);
    final index = _tasks.indexOf(task);

    // Remove locally first for immediate UI feedback
    _tasks.removeAt(index);
    notifyListeners();

    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('tasks')
          .doc(taskId)
          .delete();
    } catch (e) {
      // Add back in case of error
      _tasks.insert(index, task);
      notifyListeners();
      debugPrint('Error deleting task: $e');
    }
  }
}