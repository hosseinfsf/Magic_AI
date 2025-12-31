/// مدل پیام چت
class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final MessageType? type;
  final Map<String, dynamic>? metadata;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.type,
    this.metadata,
  });

  // تبدیل به Map برای ذخیره‌سازی
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'type': type?.name,
      'metadata': metadata,
    };
  }

  // ساخت از Map
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      text: json['text'] ?? '',
      isUser: json['isUser'] ?? false,
      timestamp:
          DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      type: json['type'] != null
          ? MessageType.values.firstWhere(
              (e) => e.name == json['type'],
              orElse: () => MessageType.text,
            )
          : null,
      metadata: json['metadata'],
    );
  }

  // کپی با تغییرات
  ChatMessage copyWith({
    String? id,
    String? text,
    bool? isUser,
    DateTime? timestamp,
    MessageType? type,
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      metadata: metadata ?? this.metadata,
    );
  }
}

enum MessageType {
  text,
  hafezFortune,
  contentGeneration,
  summary,
  toneDetection,
}
