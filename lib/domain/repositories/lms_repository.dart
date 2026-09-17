import '../entities/user_entity.dart';
import '../entities/class_entity.dart';
import '../entities/chapter_lesson_entity.dart';
import '../entities/assignment_entity.dart';
import '../entities/quiz_entity.dart';
import '../entities/attendance_entity.dart';
import '../entities/forum_entity.dart';
import '../entities/registration_entity.dart';
import '../entities/notification_entity.dart';
import '../entities/grade_entity.dart';
import '../entities/schedule_entity.dart';
import '../entities/tuition_entity.dart';
import '../entities/ai_advisor_entity.dart';

abstract class LmsRepository {
  // Auth
  Future<UserEntity> login(String username, String password);
  Future<UserEntity?> getCurrentUser();
  Future<void> logout();

  // Classes & Schedule
  Future<List<CourseClassEntity>> getMyClasses(bool isLecturer);
  Future<List<ScheduleItemEntity>> getMySchedule(bool isLecturer);

  // Class Details (Lessons, Chapters)
  Future<List<ChapterEntity>> getClassChapters(int classId);
  Future<void> markLessonProgress(int lessonId, bool completed);

  // Assignments
  Future<List<AssignmentEntity>> getClassAssignments(int classId);
  Future<void> submitAssignment(int assignmentId, String fileUrl);
  Future<List<SubmissionEntity>> getAssignmentSubmissions(int assignmentId);
  Future<void> gradeSubmission(int submissionId, double score, String feedback);
  Future<void> createAssignment(int classId, String title, String description, String dueDate, double maxScore);

  // Quizzes
  Future<List<QuizEntity>> getClassQuizzes(int classId);
  Future<List<QuizQuestionEntity>> getQuizQuestions(int quizId);
  Future<QuizAttemptEntity> submitQuizAttempt(int quizId, Map<int, String> answers);

  // Forum
  Future<List<ForumPostEntity>> getClassForumPosts(int classId);
  Future<void> createForumPost(int classId, String title, String content);
  Future<void> addForumComment(int postId, String content);

  // Attendance
  Future<List<StudentAttendanceSummary>> getStudentAttendanceSummary();
  Future<List<AttendanceEntity>> getClassAttendance(int classId);
  Future<void> markClassAttendance(int classId, String date, List<Map<String, dynamic>> records);

  // Gradebook / Transcript
  Future<List<GradeEntity>> getStudentGrades();
  Future<List<Map<String, dynamic>>> getClassGradebook(int classId);
  Future<void> updateStudentGrade(int classId, int studentId, double? midterm, double? finalScore);
  Future<void> publishGrades(int classId);

  // Course Registration
  Future<RegistrationPeriodEntity?> getActiveRegistrationPeriod();
  Future<List<AvailableClassEntity>> getAvailableClasses();
  Future<void> registerCourseClass(int classId);
  Future<void> cancelCourseRegistration(int classId);

  // Notifications
  Future<List<NotificationEntity>> getNotifications();
  Future<int> getUnreadNotificationCount();
  Future<void> markNotificationAsRead(int notificationId);

  // AI Advisor
  Future<ChatMessageEntity> sendAiAdvisorMessage(String prompt);

  // Tuition
  Future<List<TuitionItemEntity>> getTuitionInvoices();
  Future<void> payTuition(int invoiceId);
}
