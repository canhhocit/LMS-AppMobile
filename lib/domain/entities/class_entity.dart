class CourseClassEntity {
  final int id;
  final String classCode;
  final String courseName;
  final String teacherName;
  final String room;
  final String scheduleText;
  final int studentCount;
  final String semester;

  const CourseClassEntity({
    required this.id,
    required this.classCode,
    required this.courseName,
    required this.teacherName,
    required this.room,
    required this.scheduleText,
    required this.studentCount,
    required this.semester,
  });
}
