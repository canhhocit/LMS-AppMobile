class CourseClassEntity {
  final int id;
  final String classCode;
  final String className;
  final String courseTitle;
  final String? lecturerName;
  final int? lecturerId;
  final String semester;
  final String academicYear;
  final int maxStudents;
  final int enrolledCount;
  final String? room;
  final String? scheduleText;

  const CourseClassEntity({
    required this.id,
    required this.classCode,
    required this.className,
    required this.courseTitle,
    this.lecturerName,
    this.lecturerId,
    required this.semester,
    required this.academicYear,
    this.maxStudents = 50,
    this.enrolledCount = 0,
    this.room,
    this.scheduleText,
  });

  factory CourseClassEntity.fromJson(Map<String, dynamic> json) {
    return CourseClassEntity(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      classCode: json['classCode'] ?? json['class_code'] ?? '',
      className: json['className'] ?? json['class_name'] ?? '',
      courseTitle: json['courseTitle'] ?? json['course_title'] ?? json['courseName'] ?? '',
      lecturerName: json['lecturerName'] ?? json['lecturer_name'] ?? json['teacherName'],
      lecturerId: json['lecturerId'] ?? json['lecturer_id'],
      semester: json['semester'] ?? 'HK1',
      academicYear: json['academicYear'] ?? json['academic_year'] ?? '2026-2027',
      maxStudents: json['maxStudents'] ?? json['max_students'] ?? 50,
      enrolledCount: json['enrolledCount'] ?? json['studentCount'] ?? 0,
      room: json['room'],
      scheduleText: json['scheduleText'] ?? json['schedule_text'],
    );
  }
}
