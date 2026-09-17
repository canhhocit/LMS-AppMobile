class ForumPostEntity {
  final int id;
  final int classId;
  final int authorId;
  final String authorName;
  final String? authorAvatar;
  final String title;
  final String content;
  final String createdAt;
  final List<ForumCommentEntity> comments;

  const ForumPostEntity({
    required this.id,
    required this.classId,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    required this.title,
    required this.content,
    required this.createdAt,
    this.comments = const [],
  });

  factory ForumPostEntity.fromJson(Map<String, dynamic> json) {
    return ForumPostEntity(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      classId: json['classId'] ?? json['class_id'] ?? 0,
      authorId: json['authorId'] ?? json['author_id'] ?? 0,
      authorName: json['authorName'] ?? json['author_name'] ?? 'Ẩn danh',
      authorAvatar: json['authorAvatar'] ?? json['author_avatar'],
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      createdAt: json['createdAt'] ?? json['created_at'] ?? '',
      comments: (json['comments'] as List<dynamic>?)
              ?.map((c) => ForumCommentEntity.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class ForumCommentEntity {
  final int id;
  final int postId;
  final int authorId;
  final String authorName;
  final String? authorAvatar;
  final String content;
  final String createdAt;

  const ForumCommentEntity({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    required this.content,
    required this.createdAt,
  });

  factory ForumCommentEntity.fromJson(Map<String, dynamic> json) {
    return ForumCommentEntity(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      postId: json['postId'] ?? json['post_id'] ?? 0,
      authorId: json['authorId'] ?? json['author_id'] ?? 0,
      authorName: json['authorName'] ?? json['author_name'] ?? 'Ẩn danh',
      authorAvatar: json['authorAvatar'] ?? json['author_avatar'],
      content: json['content'] ?? '',
      createdAt: json['createdAt'] ?? json['created_at'] ?? '',
    );
  }
}
