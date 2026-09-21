import '../entities/class_entity.dart';
import '../entities/grade_entity.dart';
import '../entities/schedule_entity.dart';
import '../entities/tuition_entity.dart';

abstract class StudentRepository {
  Future<List<CourseClassEntity>> getMyClasses();
  Future<List<ScheduleItemEntity>> getMySchedule();
  Future<List<GradeEntity>> getMyGrades();
  Future<List<TuitionItemEntity>> getMyTuition();
  Future<PayOSPaymentEntity> createPayOSPayment(int invoiceId);
  Future<void> verifyPayOSPayment(int invoiceId);
}
