import 'package:deenhub/features/ai_chatbot/domain/models/reference_detector.dart';

enum MessageType {
  user,
  bot,
}

class ChatMessage {
  final String message;
  final MessageType type;
  final DateTime timestamp;
  final List<IslamicReference> references;

  ChatMessage({
    required this.message,
    required this.type,
    DateTime? timestamp,
    List<IslamicReference>? references,
  })  : timestamp = timestamp ?? DateTime.now(),
        references = references ?? [];

  bool get isUser => type == MessageType.user;
  bool get isBot => type == MessageType.bot;
  bool get hasReferences => references.isNotEmpty;

  // Convert ChatMessage to JSON
  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'type': type.toString(),
      'timestamp': timestamp.millisecondsSinceEpoch,
      'references': references.map((ref) => ref.toJson()).toList(),
    };
  }

  // Create ChatMessage from JSON
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      message: json['message'] as String,
      type: json['type'].toString().contains('user') ? MessageType.user : MessageType.bot,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
      references: json['references'] != null
          ? (json['references'] as List)
              .map((refJson) => IslamicReference.fromJson(refJson))
              .toList()
          : [],
    );
  }
}
