class CourseClassDto {
  final int id;
  final String classCode;
  final String courseName;
  final String teacherName;
  final String room;
  final String scheduleText;
  final int studentCount;
  final String semester;

  CourseClassDto({
    required this.id,
    required this.classCode,
    required this.courseName,
    required this.teacherName,
    required this.room,
    required this.scheduleText,
    required this.studentCount,
    required this.semester,
  });

  factory CourseClassDto.fromJson(Map<String, dynamic> json) {
    return CourseClassDto(
      id: json['id'] ?? 0,
      classCode: json['classCode'] ?? json['code'] ?? '',
      courseName: json['courseName'] ?? json['name'] ?? '',
      teacherName: json['teacherName'] ?? json['instructor'] ?? 'Giảng viên',
      room: json['room'] ?? json['location'] ?? 'P.101',
      scheduleText: json['scheduleText'] ?? json['schedule'] ?? 'Thứ 2 (7:00 - 9:30)',
      studentCount: json['studentCount'] ?? 40,
      semester: json['semester'] ?? 'Học kỳ 1 - 2024-2025',
    );
  }
}

class GradeDto {
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

  GradeDto({
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

  factory GradeDto.fromJson(Map<String, dynamic> json) {
    return GradeDto(
      id: json['id'] ?? 0,
      courseCode: json['courseCode'] ?? '',
      courseName: json['courseName'] ?? '',
      credits: json['credits'] ?? 3,
      attendanceGrade: (json['attendanceGrade'] as num?)?.toDouble(),
      midtermGrade: (json['midtermGrade'] as num?)?.toDouble(),
      finalGrade: (json['finalGrade'] as num?)?.toDouble(),
      overallGrade: (json['overallGrade'] as num?)?.toDouble(),
      letterGrade: json['letterGrade'],
      isPublished: json['isPublished'] ?? true,
    );
  }
}

class ScheduleDto {
  final int id;
  final String courseName;
  final String classCode;
  final String room;
  final String teacherName;
  final int dayOfWeek;
  final String timeSlot;
  final String date;

  ScheduleDto({
    required this.id,
    required this.courseName,
    required this.classCode,
    required this.room,
    required this.teacherName,
    required this.dayOfWeek,
    required this.timeSlot,
    required this.date,
  });

  factory ScheduleDto.fromJson(Map<String, dynamic> json) {
    return ScheduleDto(
      id: json['id'] ?? 0,
      courseName: json['courseName'] ?? '',
      classCode: json['classCode'] ?? '',
      room: json['room'] ?? 'P.101',
      teacherName: json['teacherName'] ?? 'Giảng viên',
      dayOfWeek: json['dayOfWeek'] ?? 2,
      timeSlot: json['timeSlot'] ?? '07:00 - 09:30',
      date: json['date'] ?? '',
    );
  }
}

class TuitionDto {
  final int id;
  final String semester;
  final double totalAmount;
  final double paidAmount;
  final String status;
  final String dueDate;

  TuitionDto({
    required this.id,
    required this.semester,
    required this.totalAmount,
    required this.paidAmount,
    required this.status,
    required this.dueDate,
  });

  factory TuitionDto.fromJson(Map<String, dynamic> json) {
    return TuitionDto(
      id: json['id'] ?? 0,
      semester: json['semester'] ?? 'Học kỳ 1 2024-2025',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'UNPAID',
      dueDate: json['dueDate'] ?? '',
    );
  }
}
