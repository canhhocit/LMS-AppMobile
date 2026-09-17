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
    return ScheduleItemEntity(
      id: json['id'] is int ? json['id'] : int.parse((json['id'] ?? 0).toString()),
      courseName: json['courseName'] ?? json['course_name'] ?? json['title'] ?? '',
      classCode: json['classCode'] ?? json['class_code'] ?? '',
      room: json['room'] ?? '',
      teacherName: json['teacherName'] ?? json['teacher_name'] ?? json['lecturerName'] ?? '',
      dayOfWeek: json['dayOfWeek'] ?? json['day_of_week'] ?? 2,
      timeSlot: json['timeSlot'] ?? json['time_slot'] ?? '',
      date: json['date'] ?? '',
    );
  }
}
