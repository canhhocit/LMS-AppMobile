class ChatMessageEntity {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const ChatMessageEntity({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  factory ChatMessageEntity.fromJson(Map<String, dynamic> json) {
    return ChatMessageEntity(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      text: json['text'] ?? json['message'] ?? '',
      isUser: json['isUser'] ?? json['is_user'] ?? false,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }
}
