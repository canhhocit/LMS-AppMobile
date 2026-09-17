import 'package:dio/dio.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/network/dio_client.dart';
import '../../domain/entities/class_entity.dart';
import '../../domain/entities/grade_entity.dart';
import '../../domain/entities/schedule_entity.dart';
import '../../domain/entities/tuition_entity.dart';
import '../../domain/repositories/student_repository.dart';
import '../mappers/student_mapper.dart';
import '../remote/dtos/student_dtos.dart';

class StudentRepositoryImpl implements StudentRepository {
  final DioClient dioClient;

  StudentRepositoryImpl({required this.dioClient});

  @override
  Future<List<CourseClassEntity>> getMyClasses() async {
    try {
      final response = await dioClient.dio.get(ApiEndpoints.studentClasses);
      final List list = response.data['data'] ?? response.data ?? [];
      return list.map((json) => CourseClassDto.fromJson(json).toEntity()).toList();
    } on DioException catch (_) {
      // Fallback sample data if endpoint not yet connected
      return [
        const CourseClassEntity(
          id: 1,
          classCode: '62PM1_L01',
          className: 'Lớp 62PM1_L01',
          courseTitle: 'Lập trình ứng dụng di động (Flutter)',
          lecturerName: 'TS. Nguyễn Văn A',
          room: 'P.302-A2',
          scheduleText: 'Thứ 2 (07:00 - 09:30)',
          enrolledCount: 45,
          semester: 'Học kỳ 1',
          academicYear: '2024-2025',
        ),
        const CourseClassEntity(
          id: 2,
          classCode: '62PM1_L02',
          className: 'Lớp 62PM1_L02',
          courseTitle: 'Công nghệ phần mềm nâng cao',
          lecturerName: 'PGS.TS Trần Thị B',
          room: 'P.405-A1',
          scheduleText: 'Thứ 4 (09:40 - 11:30)',
          enrolledCount: 42,
          semester: 'Học kỳ 1',
          academicYear: '2024-2025',
        ),
        const CourseClassEntity(
          id: 3,
          classCode: '62PM1_L03',
          className: 'Lớp 62PM1_L03',
          courseTitle: 'Kiến trúc máy tính & Hệ điều hành',
          lecturerName: 'ThS. Lê Hoàng C',
          room: 'P.201-B3',
          scheduleText: 'Thứ 6 (13:30 - 16:00)',
          enrolledCount: 50,
          semester: 'Học kỳ 1',
          academicYear: '2024-2025',
        ),
      ];
    }
  }

  @override
  Future<List<ScheduleItemEntity>> getMySchedule() async {
    try {
      final response = await dioClient.dio.get(ApiEndpoints.studentSchedule);
      final List list = response.data['data'] ?? response.data ?? [];
      return list.map((json) => ScheduleDto.fromJson(json).toEntity()).toList();
    } on DioException catch (_) {
      return [
        const ScheduleItemEntity(
          id: 101,
          courseName: 'Lập trình Flutter MVVM',
          classCode: '62PM1_L01',
          room: 'P.302-A2',
          teacherName: 'TS. Nguyễn Văn A',
          dayOfWeek: 2,
          timeSlot: '07:00 - 09:30',
          date: '2024-09-23',
        ),
        const ScheduleItemEntity(
          id: 102,
          courseName: 'Công nghệ phần mềm',
          classCode: '62PM1_L02',
          room: 'P.405-A1',
          teacherName: 'PGS.TS Trần Thị B',
          dayOfWeek: 4,
          timeSlot: '09:40 - 11:30',
          date: '2024-09-25',
        ),
        const ScheduleItemEntity(
          id: 103,
          courseName: 'Kiến trúc hệ thống',
          classCode: '62PM1_L03',
          room: 'P.201-B3',
          teacherName: 'ThS. Lê Hoàng C',
          dayOfWeek: 6,
          timeSlot: '13:30 - 16:00',
          date: '2024-09-27',
        ),
      ];
    }
  }

  @override
  Future<List<GradeEntity>> getMyGrades() async {
    try {
      final response = await dioClient.dio.get(ApiEndpoints.studentGrades);
      final List list = response.data['data'] ?? response.data ?? [];
      return list.map((json) => GradeDto.fromJson(json).toEntity()).toList();
    } on DioException catch (_) {
      return [
        const GradeEntity(
          id: 1,
          courseCode: 'IT4010',
          courseName: 'Lập trình ứng dụng di động',
          credits: 3,
          attendanceGrade: 9.5,
          midtermGrade: 8.5,
          finalGrade: 9.0,
          overallGrade: 8.9,
          letterGrade: 'A+',
          isPublished: true,
        ),
        const GradeEntity(
          id: 2,
          courseCode: 'IT4020',
          courseName: 'Công nghệ phần mềm nâng cao',
          credits: 3,
          attendanceGrade: 8.0,
          midtermGrade: 7.5,
          finalGrade: 8.5,
          overallGrade: 8.1,
          letterGrade: 'A',
          isPublished: true,
        ),
        const GradeEntity(
          id: 3,
          courseCode: 'IT3080',
          courseName: 'Mạng máy tính',
          credits: 4,
          attendanceGrade: 10.0,
          midtermGrade: 8.0,
          finalGrade: 7.5,
          overallGrade: 8.0,
          letterGrade: 'B+',
          isPublished: true,
        ),
      ];
    }
  }

  @override
  Future<List<TuitionItemEntity>> getMyTuition() async {
    try {
      final response = await dioClient.dio.get(ApiEndpoints.studentTuition);
      final List list = response.data['data'] ?? response.data ?? [];
      return list.map((json) => TuitionDto.fromJson(json).toEntity()).toList();
    } on DioException catch (_) {
      return [
        const TuitionItemEntity(
          id: 1,
          semester: 'Học kỳ 1 - 2024-2025',
          totalAmount: 12500000,
          paidAmount: 12500000,
          status: 'PAID',
          dueDate: '2024-10-15',
        ),
        const TuitionItemEntity(
          id: 2,
          semester: 'Học kỳ 2 - 2024-2025',
          totalAmount: 11800000,
          paidAmount: 0,
          status: 'UNPAID',
          dueDate: '2025-03-20',
        ),
      ];
    }
  }
}
