class AttendanceEntity {
  final int id;
  final int classId;
  final int studentId;
  final String? studentName;
  final String? studentCode;
  final String attendanceDate;
  final String status; // PRESENT, LATE, ABSENT

  const AttendanceEntity({
    required this.id,
    required this.classId,
    required this.studentId,
    this.studentName,
    this.studentCode,
    required this.attendanceDate,
    required this.status,
  });

  factory AttendanceEntity.fromJson(Map<String, dynamic> json) {
    return AttendanceEntity(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      classId: json['classId'] ?? json['class_id'] ?? 0,
      studentId: json['studentId'] ?? json['student_id'] ?? 0,
      studentName: json['studentName'] ?? json['student_name'],
      studentCode: json['studentCode'] ?? json['student_code'],
      attendanceDate: json['attendanceDate'] ?? json['attendance_date'] ?? '',
      status: json['status'] ?? 'PRESENT',
    );
  }
}

class StudentAttendanceSummary {
  final String className;
  final String classCode;
  final int presentCount;
  final int lateCount;
  final int absentCount;
  final double absentRatio;

  const StudentAttendanceSummary({
    required this.className,
    required this.classCode,
    required this.presentCount,
    required this.lateCount,
    required this.absentCount,
    required this.absentRatio,
  });

  factory StudentAttendanceSummary.fromJson(Map<String, dynamic> json) {
    return StudentAttendanceSummary(
      className: json['className'] ?? json['class_name'] ?? '',
      classCode: json['classCode'] ?? json['class_code'] ?? '',
      presentCount: json['presentCount'] ?? json['present_count'] ?? 0,
      lateCount: json['lateCount'] ?? json['late_count'] ?? 0,
      absentCount: json['absentCount'] ?? json['absent_count'] ?? 0,
      absentRatio: (json['absentRatio'] ?? json['absent_ratio'] ?? 0.0).toDouble(),
    );
  }
}
