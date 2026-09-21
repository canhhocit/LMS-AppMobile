class ApiEndpoints {
  // Render Production Backend URL for Students
  static const String baseUrl = 'https://learninghub-6jdb.onrender.com/api/v1';

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';
  static const String me = '/me/profile';
  static const String changePassword = '/me/change-password';

  // Student & Lecturer Endpoints (Backend uses /me/* endpoints)
  static const String studentClasses = '/me/classes';
  static const String studentSchedule = '/me/schedule';
  static const String studentGrades = '/me/grades';
  static const String studentTuition = '/me/tuition';
  static const String studentProfile = '/me/profile';
  static const String studentAttendance = '/me/attendance';

  // Lecturer Endpoints
  static const String lecturerClasses = '/me/classes';
  static const String lecturerSchedule = '/me/schedule';
  static const String lecturerProfile = '/me/profile';

  // Course & Class Detail Endpoints
  static String classDetail(int classId) => '/me/classes/$classId';
  static String classChapters(int classId) => '/me/classes/$classId/chapters';
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
  static String markAttendance(int classId) => '/classes/$classId/attendance';

  // Gradebook (Lecturer)
  static String classGradebook(int classId) => '/classes/$classId/grades';
  static String updateStudentGrade(int classId, int studentId) => '/classes/$classId/grades';
  static String publishGrades(int classId) => '/classes/$classId/grades/publish';

  // Course Registration (Student)
  static const String activeRegistrationPeriod = '/registration-periods/active';
  static const String availableCourseClasses = '/me/classes/available';
  static const String myRegistrations = '/me/registrations';
  static String registerCourse(int classId) => '/registration/$classId';
  static String cancelRegistration(int classId) => '/registration/$classId';

  // Notifications
  static const String notifications = '/me/notifications';
  static const String unreadNotificationCount = '/me/notifications/unread-count';
  static String markNotificationRead(int id) => '/notifications/$id/read';

  // AI Learning Advisor
  static const String aiAdvisorChat = '/ai/advisor/ask';

  // Tuition Payment & PayOS
  static String payTuition(int invoiceId) => '/me/tuition/$invoiceId/pay';
  static String payOSCreatePayment(int invoiceId) => '/me/tuition/$invoiceId/payos-create-payment';
  static String payOSVerifyPayment(int invoiceId) => '/me/tuition/$invoiceId/payos-verify';
}
