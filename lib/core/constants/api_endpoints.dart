class ApiEndpoints {
  // Adjust base URL according to host machine (10.0.2.2 for Android emulator, localhost for iOS simulator/desktop, or actual IP)
  static const String baseUrl = 'http://192.168.0.103:8080/api/v1';

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';

  // Student Profile & Classes
  static const String studentClasses = '/student/classes';
  static const String studentSchedule = '/student/schedule';
  static const String studentGrades = '/student/grades';
  static const String studentTuition = '/student/tuition';
  static const String studentProfile = '/student/profile';
}
