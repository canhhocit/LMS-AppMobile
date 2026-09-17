class NotificationEntity {
  final int id;
  final String title;
  final String content;
  final String type;
  final int? referenceId;
  final bool isRead;
  final String createdAt;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    this.referenceId,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationEntity.fromJson(Map<String, dynamic> json) {
    return NotificationEntity(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      type: json['type'] ?? 'GENERAL',
      referenceId: json['referenceId'] ?? json['reference_id'],
      isRead: json['isRead'] ?? json['is_read'] ?? false,
      createdAt: json['createdAt'] ?? json['created_at'] ?? '',
    );
  }
}
