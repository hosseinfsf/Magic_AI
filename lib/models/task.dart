/// مدل کار/تسک
import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String title;
  final String? description;
  final DateTime createdAt;
  final DateTime? dueDate;
  final TaskPriority priority;
  final bool isCompleted;
  final String? category;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.createdAt,
    this.dueDate,
    this.priority = TaskPriority.medium,
    this.isCompleted = false,
    this.category,
  });

  // تبدیل به Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'priority': priority.name,
      'isCompleted': isCompleted,
      'category': category,
    };
  }

  // ساخت از Map
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] ?? DateTime
          .now()
          .millisecondsSinceEpoch
          .toString(),
      title: json['title'] ?? '',
      description: json['description'],
      createdAt: DateTime.parse(
          json['createdAt'] ?? DateTime.now().toIso8601String()),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      priority: TaskPriority.values.firstWhere(
            (e) => e.name == json['priority'],
        orElse: () => TaskPriority.medium,
      ),
      isCompleted: json['isCompleted'] ?? false,
      category: json['category'],
    );
  }

  // ساخت از Firestore DocumentSnapshot
  factory Task.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    return Task(
      id: doc.id,
      title: data?['title'] ?? '',
      description: data?['description'],
      createdAt: (data?['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dueDate: (data?['dueDate'] as Timestamp?)?.toDate(),
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == (data?['priority'] ?? 'medium'),
        orElse: () => TaskPriority.medium,
      ),
      isCompleted: data?['isCompleted'] ?? false,
      category: data?['category'],
    );
  }

  // کپی با تغییرات
  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? dueDate,
    TaskPriority? priority,
    bool? isCompleted,
    String? category,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      category: category ?? this.category,
    );
  }
}

enum TaskPriority {
  low,
  medium,
  high,
}

