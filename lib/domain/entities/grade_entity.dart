class GradeEntity {
  final int id;
  final String courseCode;
  final String courseName;
  final int credits;
  final double? attendanceGrade;
  final double? midtermGrade;
  final double? finalGrade;
  final double? overallGrade;
  final String? letterGrade;
  final bool isPublished;

  const GradeEntity({
    required this.id,
    required this.courseCode,
    required this.courseName,
    required this.credits,
    this.attendanceGrade,
    this.midtermGrade,
    this.finalGrade,
    this.overallGrade,
    this.letterGrade,
    this.isPublished = false,
  });

  factory GradeEntity.fromJson(Map<String, dynamic> json) {
    return GradeEntity(
      id: json['id'] is int ? json['id'] : int.parse((json['id'] ?? 0).toString()),
      courseCode: json['courseCode'] ?? json['course_code'] ?? '',
      courseName: json['courseName'] ?? json['course_name'] ?? json['courseTitle'] ?? '',
      credits: json['credits'] ?? json['credit'] ?? 3,
      attendanceGrade: json['attendanceGrade'] != null ? (json['attendanceGrade'] as num).toDouble() : null,
      midtermGrade: json['midtermGrade'] != null ? (json['midtermGrade'] as num).toDouble() : (json['midtermScore'] != null ? (json['midtermScore'] as num).toDouble() : null),
      finalGrade: json['finalGrade'] != null ? (json['finalGrade'] as num).toDouble() : (json['finalScore'] != null ? (json['finalScore'] as num).toDouble() : null),
      overallGrade: json['overallGrade'] != null ? (json['overallGrade'] as num).toDouble() : (json['totalScore'] != null ? (json['totalScore'] as num).toDouble() : null),
      letterGrade: json['letterGrade'] ?? json['letter_grade'],
      isPublished: json['isPublished'] ?? json['is_published'] ?? true,
    );
  }
}
