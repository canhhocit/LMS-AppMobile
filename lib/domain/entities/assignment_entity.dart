class AssignmentEntity {
  final int id;
  final int classId;
  final String title;
  final String? description;
  final String dueDate;
  final double maxScore;
  final SubmissionEntity? mySubmission;

  const AssignmentEntity({
    required this.id,
    required this.classId,
    required this.title,
    this.description,
    required this.dueDate,
    required this.maxScore,
    this.mySubmission,
  });

  factory AssignmentEntity.fromJson(Map<String, dynamic> json) {
    return AssignmentEntity(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      classId: json['classId'] ?? json['class_id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'],
      dueDate: json['dueDate'] ?? json['due_date'] ?? '',
      maxScore: (json['maxScore'] ?? json['max_score'] ?? 10.0).toDouble(),
      mySubmission: json['mySubmission'] != null
          ? SubmissionEntity.fromJson(json['mySubmission'] as Map<String, dynamic>)
          : null,
    );
  }
}

class SubmissionEntity {
  final int id;
  final int assignmentId;
  final int studentId;
  final String? studentName;
  final String? studentCode;
  final String fileUrl;
  final String submittedAt;
  final double? score;
  final bool isLate;
  final String? feedback;

  const SubmissionEntity({
    required this.id,
    required this.assignmentId,
    required this.studentId,
    this.studentName,
    this.studentCode,
    required this.fileUrl,
    required this.submittedAt,
    this.score,
    this.isLate = false,
    this.feedback,
  });

  factory SubmissionEntity.fromJson(Map<String, dynamic> json) {
    return SubmissionEntity(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      assignmentId: json['assignmentId'] ?? json['assignment_id'] ?? 0,
      studentId: json['studentId'] ?? json['student_id'] ?? 0,
      studentName: json['studentName'] ?? json['student_name'],
      studentCode: json['studentCode'] ?? json['student_code'],
      fileUrl: json['fileUrl'] ?? json['file_url'] ?? '',
      submittedAt: json['submittedAt'] ?? json['submitted_at'] ?? '',
      score: json['score'] != null ? (json['score'] as num).toDouble() : null,
      isLate: json['isLate'] ?? json['is_late'] ?? false,
      feedback: json['feedback'],
    );
  }
}
