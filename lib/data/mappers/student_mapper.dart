import '../../domain/entities/class_entity.dart';
import '../../domain/entities/grade_entity.dart';
import '../../domain/entities/schedule_entity.dart';
import '../../domain/entities/tuition_entity.dart';
import '../remote/dtos/student_dtos.dart';

extension CourseClassDtoMapper on CourseClassDto {
  CourseClassEntity toEntity() {
    return CourseClassEntity(
      id: id,
      classCode: classCode,
      className: courseName,
      courseTitle: courseName,
      lecturerName: teacherName,
      room: room,
      scheduleText: scheduleText,
      enrolledCount: studentCount,
      semester: semester,
      academicYear: '2026-2027',
    );
  }
}

extension GradeDtoMapper on GradeDto {
  GradeEntity toEntity() {
    return GradeEntity(
      id: id,
      courseCode: courseCode,
      courseName: courseName,
      credits: credits,
      attendanceGrade: attendanceGrade,
      midtermGrade: midtermGrade,
      finalGrade: finalGrade,
      overallGrade: overallGrade,
      letterGrade: letterGrade,
      isPublished: isPublished,
    );
  }
}

extension ScheduleDtoMapper on ScheduleDto {
  ScheduleItemEntity toEntity() {
    return ScheduleItemEntity(
      id: id,
      courseName: courseName,
      classCode: classCode,
      room: room,
      teacherName: teacherName,
      dayOfWeek: dayOfWeek,
      timeSlot: timeSlot,
      date: date,
    );
  }
}

extension TuitionDtoMapper on TuitionDto {
  TuitionItemEntity toEntity() {
    return TuitionItemEntity(
      id: id,
      semester: semester,
      totalAmount: totalAmount,
      paidAmount: paidAmount,
      status: status,
      dueDate: dueDate,
    );
  }
}
