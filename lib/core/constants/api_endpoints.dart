class ApiEndpoints {
  // Adjust base URL according to host machine (10.0.2.2 for Android emulator, 192.168.x.x for physical device, localhost for iOS simulator)
  static const String baseUrl = 'http://192.168.0.103:8080/api/v1';

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';
  static const String me = '/me';
  static const String changePassword = '/me/change-password';

  // Student Endpoints
  static const String studentClasses = '/student/classes';
  static const String studentSchedule = '/student/schedule';
  static const String studentGrades = '/student/grades';
  static const String studentTuition = '/student/tuition';
  static const String studentProfile = '/student/profile';
  static const String studentAttendance = '/student/attendance';

  // Lecturer Endpoints
  static const String lecturerClasses = '/lecturer/classes';
  static const String lecturerSchedule = '/lecturer/schedule';
  static const String lecturerProfile = '/lecturer/profile';

  // Course & Class Detail Endpoints
  static String classDetail(int classId) => '/classes/$classId';
  static String classChapters(int classId) => '/classes/$classId/chapters';
  static String markLessonProgress(int lessonId) => '/lessons/$lessonId/progress';
  
  // Assignments
  static String classAssignments(int classId) => '/classes/$classId/assignments';
  static String submitAssignment(int assignmentId) => '/assignments/$assignmentId/submit';
  static String assignmentSubmissions(int assignmentId) => '/assignments/$assignmentId/submissions';
  static String gradeSubmission(int submissionId) => '/submissions/$submissionId/grade';

  // Quizzes
  static String classQuizzes(int classId) => '/classes/$classId/quizzes';
  static String quizQuestions(int quizId) => '/quizzes/$quizId/questions';
  static String submitQuizAttempt(int quizId) => '/quizzes/$quizId/submit';

  // Forum
  static String classForumPosts(int classId) => '/classes/$classId/forum/posts';
  static String addForumComment(int postId) => '/forum/posts/$postId/comments';

  // Attendance (Lecturer)
  static String classAttendance(int classId) => '/classes/$classId/attendance';
  static String markAttendance(int classId) => '/classes/$classId/attendance/mark';

  // Gradebook (Lecturer)
  static String classGradebook(int classId) => '/classes/$classId/grades';
  static String updateStudentGrade(int classId, int studentId) => '/classes/$classId/grades/$studentId';
  static String publishGrades(int classId) => '/classes/$classId/grades/publish';

  // Course Registration (Student)
  static const String activeRegistrationPeriod = '/registration/active-period';
  static const String availableCourseClasses = '/registration/available-classes';
  static const String myRegistrations = '/registration/my-registrations';
  static String registerCourse(int classId) => '/registration/register/$classId';
  static String cancelRegistration(int classId) => '/registration/cancel/$classId';

  // Notifications
  static const String notifications = '/me/notifications';
  static const String unreadNotificationCount = '/me/notifications/unread-count';
  static String markNotificationRead(int id) => '/me/notifications/$id/read';

  // AI Learning Advisor
  static const String aiAdvisorChat = '/ai/advisor/chat';

  // Tuition Payment
  static String payTuition(int invoiceId) => '/student/tuition/$invoiceId/pay';
}
