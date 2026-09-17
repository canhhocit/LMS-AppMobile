class RegistrationPeriodEntity {
  final int id;
  final String name;
  final String semester;
  final String academicYear;
  final String openAt;
  final String closeAt;
  final int maxCredits;
  final bool isActive;

  const RegistrationPeriodEntity({
    required this.id,
    required this.name,
    required this.semester,
    required this.academicYear,
    required this.openAt,
    required this.closeAt,
    required this.maxCredits,
    required this.isActive,
  });

  factory RegistrationPeriodEntity.fromJson(Map<String, dynamic> json) {
    return RegistrationPeriodEntity(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      semester: json['semester'] ?? '',
      academicYear: json['academicYear'] ?? json['academic_year'] ?? '',
      openAt: json['openAt'] ?? json['open_at'] ?? '',
      closeAt: json['closeAt'] ?? json['close_at'] ?? '',
      maxCredits: json['maxCredits'] ?? json['max_credits'] ?? 24,
      isActive: json['isActive'] ?? json['is_active'] ?? false,
    );
  }
}

class AvailableClassEntity {
  final int id;
  final String classCode;
  final String className;
  final String courseCode;
  final String courseTitle;
  final int credit;
  final String? lecturerName;
  final int maxStudents;
  final int currentEnrolled;
  final bool isRegistered;

  const AvailableClassEntity({
    required this.id,
    required this.classCode,
    required this.className,
    required this.courseCode,
    required this.courseTitle,
    required this.credit,
    this.lecturerName,
    required this.maxStudents,
    required this.currentEnrolled,
    this.isRegistered = false,
  });

  factory AvailableClassEntity.fromJson(Map<String, dynamic> json) {
    return AvailableClassEntity(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      classCode: json['classCode'] ?? json['class_code'] ?? '',
      className: json['className'] ?? json['class_name'] ?? '',
      courseCode: json['courseCode'] ?? json['course_code'] ?? '',
      courseTitle: json['courseTitle'] ?? json['course_title'] ?? '',
      credit: json['credit'] ?? 3,
      lecturerName: json['lecturerName'] ?? json['lecturer_name'],
      maxStudents: json['maxStudents'] ?? json['max_students'] ?? 50,
      currentEnrolled: json['currentEnrolled'] ?? json['current_enrolled'] ?? 0,
      isRegistered: json['isRegistered'] ?? json['is_registered'] ?? false,
    );
  }
}
