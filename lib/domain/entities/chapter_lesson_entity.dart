class ChapterEntity {
  final int id;
  final String title;
  final String? description;
  final int sortOrder;
  final List<LessonEntity> lessons;

  const ChapterEntity({
    required this.id,
    required this.title,
    this.description,
    required this.sortOrder,
    this.lessons = const [],
  });

  factory ChapterEntity.fromJson(Map<String, dynamic> json) {
    return ChapterEntity(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      title: json['title'] ?? '',
      description: json['description'],
      sortOrder: json['sortOrder'] ?? json['sort_order'] ?? 1,
      lessons: (json['lessons'] as List<dynamic>?)
              ?.map((l) => LessonEntity.fromJson(l as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class LessonEntity {
  final int id;
  final String title;
  final String? content;
  final String? videoUrl;
  final int duration;
  final int sortOrder;
  final bool isCompleted;

  const LessonEntity({
    required this.id,
    required this.title,
    this.content,
    this.videoUrl,
    this.duration = 0,
    required this.sortOrder,
    this.isCompleted = false,
  });

  factory LessonEntity.fromJson(Map<String, dynamic> json) {
    return LessonEntity(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      title: json['title'] ?? '',
      content: json['content'],
      videoUrl: json['videoUrl'] ?? json['video_url'],
      duration: json['duration'] ?? 0,
      sortOrder: json['sortOrder'] ?? json['sort_order'] ?? 1,
      isCompleted: json['isCompleted'] ?? json['is_completed'] ?? false,
    );
  }
}
