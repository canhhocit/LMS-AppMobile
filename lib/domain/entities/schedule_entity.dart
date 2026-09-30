class ScheduleItemEntity {
  final int id;
  final String courseName;
  final String classCode;
  final String room;
  final String teacherName;
  final int dayOfWeek; // 2 = Mon, 3 = Tue, ..., 8 = Sun
  final String timeSlot;
  final String date;

  const ScheduleItemEntity({
    required this.id,
    required this.courseName,
    required this.classCode,
    required this.room,
    required this.teacherName,
    required this.dayOfWeek,
    required this.timeSlot,
    required this.date,
  });

  factory ScheduleItemEntity.fromJson(Map<String, dynamic> json) {
    final startP = json['startPeriod'];
    final endP = json['endPeriod'];
    String slot = json['timeSlot'] ?? json['time_slot'] ?? '';
    if (slot.isEmpty && startP != null) {
      slot = (endP != null && endP != startP) ? 'Tiết $startP - $endP' : 'Tiết $startP';
    }
    if (slot.isEmpty) {
      slot = 'Ca học';
    }

    final cName = json['courseTitle'] ?? json['className'] ?? json['courseName'] ?? json['course_name'] ?? json['title'] ?? 'Môn học';
    final cCode = json['clazzCode'] ?? json['classCode'] ?? json['class_code'] ?? json['courseCode'] ?? '';
    final teacher = json['lecturerName'] ?? json['teacherName'] ?? json['teacher_name'] ?? '';

    return ScheduleItemEntity(
      id: json['id'] is int ? json['id'] : int.parse((json['id'] ?? 0).toString()),
      courseName: cName.toString(),
      classCode: cCode.toString(),
      room: (json['room'] ?? '').toString(),
      teacherName: teacher.toString(),
      dayOfWeek: json['dayOfWeek'] ?? json['day_of_week'] ?? 2,
      timeSlot: slot,
      date: (json['date'] ?? '').toString(),
    );
  }
}
