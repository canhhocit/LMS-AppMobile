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
}
