import 'dart:convert';
import 'package:dio/dio.dart';

import '../../core/constants/api_endpoints.dart';
import '../../core/network/dio_client.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/class_entity.dart';
import '../../domain/entities/chapter_lesson_entity.dart';
import '../../domain/entities/assignment_entity.dart';
import '../../domain/entities/quiz_entity.dart';
import '../../domain/entities/attendance_entity.dart';
import '../../domain/entities/forum_entity.dart';
import '../../domain/entities/registration_entity.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/entities/grade_entity.dart';
import '../../domain/entities/schedule_entity.dart';
import '../../domain/entities/tuition_entity.dart';
import '../../domain/entities/ai_advisor_entity.dart';
import '../../domain/repositories/lms_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/student_repository.dart';
import '../session/session_manager.dart';

class LmsRepositoryImpl implements LmsRepository, AuthRepository, StudentRepository {
  final DioClient dioClient;
  final SessionManager sessionManager;

  LmsRepositoryImpl({required this.dioClient, required this.sessionManager});

  Dio get _dio => dioClient.dio;

  dynamic _unwrap(Response response) {
    final data = response.data;
    if (data is Map<String, dynamic> && data.containsKey('result')) {
      return data['result'];
    }
    return data;
  }

  // AuthRepository
  @override
  Future<UserEntity> login(String username, String password) async {
    final res = await _dio.post(ApiEndpoints.login, data: {
      'username': username,
      'password': password,
    });
    final result = _unwrap(res);
    final user = UserEntity.fromJson(result as Map<String, dynamic>);
    
    if (user.token != null) {
      await sessionManager.saveTokens(
        token: user.token!,
        refreshToken: user.refreshToken,
      );
    }
    await sessionManager.saveUserJson(jsonEncode(user.toJson()));
    return user;
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final jsonStr = sessionManager.getUserJson();
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        return UserEntity.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
      } catch (_) {}
    }
    final token = await sessionManager.getToken();
    if (token != null && token.isNotEmpty) {
      try {
        final res = await _dio.get(ApiEndpoints.me);
        final result = _unwrap(res);
        final user = UserEntity.fromJson(result as Map<String, dynamic>);
        await sessionManager.saveUserJson(jsonEncode(user.toJson()));
        return user;
      } catch (_) {}
    }
    return null;
  }

  @override
  Future<void> logout() async {
    await sessionManager.clearSession();
  }

  @override
  Future<UserEntity> updateProfile({String? personalEmail, String? fullName, String? avatarUrl}) async {
    final currentUser = await getCurrentUser();
    final res = await _dio.put(ApiEndpoints.studentProfile, data: {
      'fullName': fullName ?? currentUser?.fullName ?? '',
      if (personalEmail != null) 'personalEmail': personalEmail,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
    });
    final result = _unwrap(res);
    final user = UserEntity.fromJson(result as Map<String, dynamic>);
    await sessionManager.saveUserJson(jsonEncode(user.toJson()));
    return user;
  }

  @override
  Future<void> changePassword(String oldPassword, String newPassword) async {
    await _dio.post('/auth/change-password', data: {
      'oldPassword': oldPassword,
      'newPassword': newPassword,
    });
  }

  // StudentRepository & LmsRepository
  @override
  Future<List<CourseClassEntity>> getMyClasses([bool isLecturer = false]) async {
    final endpoint = isLecturer ? ApiEndpoints.lecturerClasses : ApiEndpoints.studentClasses;
    final res = await _dio.get(endpoint);
    final list = _unwrap(res) as List<dynamic>? ?? [];
    return list.map((e) => CourseClassEntity.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<ScheduleItemEntity>> getMySchedule([bool isLecturer = false]) async {
    final endpoint = isLecturer ? ApiEndpoints.lecturerSchedule : ApiEndpoints.studentSchedule;
    final res = await _dio.get(endpoint);
    final list = _unwrap(res) as List<dynamic>? ?? [];
    return list.map((e) => ScheduleItemEntity.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<GradeEntity>> getMyGrades() async {
    return getStudentGrades();
  }

  @override
  Future<List<TuitionItemEntity>> getMyTuition() async {
    return getTuitionInvoices();
  }

  // Chapter & Lessons
  @override
  Future<List<ChapterEntity>> getClassChapters(int classId) async {
    final res = await _dio.get(ApiEndpoints.classChapters(classId));
    final list = _unwrap(res) as List<dynamic>? ?? [];
    return list.map((e) => ChapterEntity.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> markLessonProgress(int lessonId, bool completed) async {
    await _dio.post(ApiEndpoints.markLessonProgress(lessonId), data: {
      'completed': completed,
    });
  }

  // Assignments
  @override
  Future<List<AssignmentEntity>> getClassAssignments(int classId) async {
    final res = await _dio.get(ApiEndpoints.classAssignments(classId));
    final list = _unwrap(res) as List<dynamic>? ?? [];
    return list.map((e) => AssignmentEntity.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> submitAssignment(int assignmentId, String fileUrl) async {
    await _dio.post(ApiEndpoints.submitAssignment(assignmentId), data: {
      'fileUrl': fileUrl,
    });
  }

  @override
  Future<List<SubmissionEntity>> getAssignmentSubmissions(int assignmentId) async {
    final res = await _dio.get(ApiEndpoints.assignmentSubmissions(assignmentId));
    final list = _unwrap(res) as List<dynamic>? ?? [];
    return list.map((e) => SubmissionEntity.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> gradeSubmission(int submissionId, double score, String feedback) async {
    await _dio.post(ApiEndpoints.gradeSubmission(submissionId), data: {
      'score': score,
      'feedback': feedback,
    });
  }

  @override
  Future<void> createAssignment(int classId, String title, String description, String dueDate, double maxScore) async {
    await _dio.post(ApiEndpoints.classAssignments(classId), data: {
      'title': title,
      'description': description,
      'dueDate': dueDate,
      'maxScore': maxScore,
    });
  }

  // Quizzes
  @override
  Future<List<QuizEntity>> getClassQuizzes(int classId) async {
    final res = await _dio.get(ApiEndpoints.classQuizzes(classId));
    final list = _unwrap(res) as List<dynamic>? ?? [];
    return list.map((e) => QuizEntity.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<QuizQuestionEntity>> getQuizQuestions(int quizId) async {
    final res = await _dio.get(ApiEndpoints.quizQuestions(quizId));
    final list = _unwrap(res) as List<dynamic>? ?? [];
    return list.map((e) => QuizQuestionEntity.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<QuizAttemptEntity> submitQuizAttempt(int quizId, Map<int, String> answers) async {
    final res = await _dio.post(ApiEndpoints.submitQuizAttempt(quizId), data: {
      'answers': answers.map((k, v) => MapEntry(k.toString(), v)),
    });
    final result = _unwrap(res);
    return QuizAttemptEntity.fromJson(result as Map<String, dynamic>);
  }

  // Forum
  @override
  Future<List<ForumPostEntity>> getClassForumPosts(int classId) async {
    final res = await _dio.get(ApiEndpoints.classForumPosts(classId));
    final list = _unwrap(res) as List<dynamic>? ?? [];
    return list.map((e) => ForumPostEntity.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> createForumPost(int classId, String title, String content) async {
    await _dio.post(ApiEndpoints.classForumPosts(classId), data: {
      'title': title,
      'content': content,
    });
  }

  @override
  Future<void> addForumComment(int postId, String content) async {
    await _dio.post(ApiEndpoints.addForumComment(postId), data: {
      'content': content,
    });
  }

  // Attendance
  @override
  Future<List<StudentAttendanceSummary>> getStudentAttendanceSummary() async {
    final res = await _dio.get(ApiEndpoints.studentAttendance);
    final list = _unwrap(res) as List<dynamic>? ?? [];
    return list.map((e) => StudentAttendanceSummary.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<AttendanceEntity>> getClassAttendance(int classId) async {
    final res = await _dio.get(ApiEndpoints.classAttendance(classId));
    final list = _unwrap(res) as List<dynamic>? ?? [];
    return list.map((e) => AttendanceEntity.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> markClassAttendance(int classId, String date, List<Map<String, dynamic>> records) async {
    await _dio.post(ApiEndpoints.markAttendance(classId), data: {
      'date': date,
      'records': records,
    });
  }

  // Gradebook / Transcript
  @override
  Future<List<GradeEntity>> getStudentGrades() async {
    final res = await _dio.get(ApiEndpoints.studentGrades);
    final list = _unwrap(res) as List<dynamic>? ?? [];
    return list.map((e) => GradeEntity.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getClassGradebook(int classId) async {
    final res = await _dio.get(ApiEndpoints.classGradebook(classId));
    final list = _unwrap(res) as List<dynamic>? ?? [];
    return list.cast<Map<String, dynamic>>();
  }

  @override
  Future<void> updateStudentGrade(int classId, int studentId, double? midterm, double? finalScore) async {
    await _dio.put(ApiEndpoints.updateStudentGrade(classId, studentId), data: {
      'midtermScore': midterm,
      'finalScore': finalScore,
    });
  }

  @override
  Future<void> publishGrades(int classId) async {
    await _dio.post(ApiEndpoints.publishGrades(classId));
  }

  // Course Registration
  @override
  Future<RegistrationPeriodEntity?> getActiveRegistrationPeriod() async {
    try {
      final res = await _dio.get(ApiEndpoints.activeRegistrationPeriod);
      final result = _unwrap(res);
      if (result == null) return null;
      return RegistrationPeriodEntity.fromJson(result as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<AvailableClassEntity>> getAvailableClasses() async {
    final res = await _dio.get(ApiEndpoints.availableCourseClasses);
    final list = _unwrap(res) as List<dynamic>? ?? [];
    return list.map((e) => AvailableClassEntity.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> registerCourseClass(int classId) async {
    await _dio.post(ApiEndpoints.registerCourse(classId));
  }

  @override
  Future<void> cancelCourseRegistration(int classId) async {
    await _dio.delete(ApiEndpoints.cancelRegistration(classId));
  }

  // Notifications
  @override
  Future<List<NotificationEntity>> getNotifications() async {
    try {
      final res = await _dio.get(ApiEndpoints.notifications);
      final result = _unwrap(res);
      final List list = result is Map ? (result['content'] ?? []) : (result is List ? result : []);
      return list.map((e) => NotificationEntity.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<int> getUnreadNotificationCount() async {
    try {
      final res = await _dio.get(ApiEndpoints.unreadNotificationCount);
      final result = _unwrap(res);
      if (result is Map && result.containsKey('count')) {
        return result['count'] as int;
      }
      return result is int ? result : 0;
    } catch (_) {
      return 0;
    }
  }

  @override
  Future<void> markNotificationAsRead(int notificationId) async {
    try {
      await _dio.put(ApiEndpoints.markNotificationRead(notificationId));
    } catch (_) {}
  }

  // AI Advisor
  @override
  Future<ChatMessageEntity> sendAiAdvisorMessage(String prompt) async {
    try {
      final res = await _dio.post(ApiEndpoints.aiAdvisorChat, data: {
        'prompt': prompt,
        'question': prompt,
      });
      final result = _unwrap(res);
      String responseText = 'Không có phản hồi từ AI';
      if (result is Map) {
        responseText = result['advice'] ?? result['response'] ?? result['reply'] ?? result['aiResponse'] ?? result.toString();
      } else if (result != null) {
        responseText = result.toString();
      }
      return ChatMessageEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: responseText,
        isUser: false,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      return ChatMessageEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: 'Cố vấn AI hiện đang bận hoặc quá tải. Vui lòng gửi lại câu hỏi sau ít phút!',
        isUser: false,
        timestamp: DateTime.now(),
      );
    }
  }

  // Tuition
  @override
  Future<List<TuitionItemEntity>> getTuitionInvoices() async {
    final res = await _dio.get(ApiEndpoints.studentTuition);
    final list = _unwrap(res) as List<dynamic>? ?? [];
    return list.map((e) => TuitionItemEntity.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> payTuition(int invoiceId) async {
    await _dio.post(ApiEndpoints.payTuition(invoiceId));
  }
}
