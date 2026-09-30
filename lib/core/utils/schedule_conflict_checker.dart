class CourseScheduleSlot {
  final String courseCode;
  final String courseName;
  final int dayOfWeek; // 2 = Mon, ..., 8 = Sun
  final int startPeriod;
  final int endPeriod;

  const CourseScheduleSlot({
    required this.courseCode,
    required this.courseName,
    required this.dayOfWeek,
    required this.startPeriod,
    required this.endPeriod,
  });
}

class ConflictCheckResult {
  final bool hasConflict;
  final String? conflictDetails;

  const ConflictCheckResult({
    required this.hasConflict,
    this.conflictDetails,
  });
}

class ScheduleConflictChecker {
  static ConflictCheckResult checkConflict({
    required List<CourseScheduleSlot> enrolledCourses,
    required CourseScheduleSlot targetCourse,
  }) {
    for (final course in enrolledCourses) {
      if (course.dayOfWeek == targetCourse.dayOfWeek) {
        if (targetCourse.startPeriod <= course.endPeriod && course.startPeriod <= targetCourse.endPeriod) {
          return ConflictCheckResult(
            hasConflict: true,
            conflictDetails: 'Trùng lịch Thứ ${targetCourse.dayOfWeek} (Tiết ${targetCourse.startPeriod}-${targetCourse.endPeriod}) với môn "${course.courseName}" (Tiết ${course.startPeriod}-${course.endPeriod})',
          );
        }
      }
    }
    return const ConflictCheckResult(hasConflict: false);
  }
}
