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
}
