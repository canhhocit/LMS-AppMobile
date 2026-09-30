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
    final title = json['courseTitle'] ?? json['className'] ?? json['course_title'] ?? json['courseName'] ?? 'Lớp học phần';
    final code = json['classCode'] ?? json['clazzCode'] ?? json['class_code'] ?? '';
    final count = json['currentStudents'] ?? json['enrolledCount'] ?? json['studentCount'] ?? json['current_students'] ?? 0;

    return CourseClassEntity(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      classCode: code.toString(),
      className: (json['className'] ?? json['class_name'] ?? title).toString(),
      courseTitle: title.toString(),
      lecturerName: json['lecturerName'] ?? json['lecturer_name'] ?? json['teacherName'],
      lecturerId: json['lecturerId'] ?? json['lecturer_id'],
      semester: (json['semester'] ?? 'HK1').toString(),
      academicYear: (json['academicYear'] ?? json['academic_year'] ?? '2026-2027').toString(),
      maxStudents: json['maxStudents'] ?? json['max_students'] ?? 50,
      enrolledCount: count is int ? count : int.tryParse(count.toString()) ?? 0,
      room: json['room'],
      scheduleText: json['scheduleText'] ?? json['schedule_text'],
    );
  }
}
