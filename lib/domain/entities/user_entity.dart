class UserEntity {
  final int id;
  final String fullName;
  final String email;
  final String? personalEmail;
  final String role;
  final String? studentCode;
  final String? lecturerCode;
  final String? faculty;
  final String? major;
  final String? adminClassName;
  final String? curriculumName;
  final String? avatarUrl;
  final String? token;
  final String? refreshToken;

  const UserEntity({
    required this.id,
    required this.fullName,
    required this.email,
    this.personalEmail,
    required this.role,
    this.studentCode,
    this.lecturerCode,
    this.faculty,
    this.major,
    this.adminClassName,
    this.curriculumName,
    this.avatarUrl,
    this.token,
    this.refreshToken,
  });

  bool get isLecturer => role.toUpperCase() == 'LECTURER';
  bool get isStudent => role.toUpperCase() == 'STUDENT';
  bool get isAdmin => role.toUpperCase() == 'ADMIN';

  String? get facultyName => faculty;
  String? get displayCurriculum => curriculumName ?? major;
  String? get username => email;

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    // Parse faculty string from various nested/direct json fields
    String? facultyVal;
    if (json['faculty'] is String) {
      facultyVal = json['faculty'];
    } else if (json['faculty'] is Map) {
      facultyVal = json['faculty']['name'] ?? json['faculty']['facultyName'];
    } else if (json['facultyName'] is String) {
      facultyVal = json['facultyName'];
    } else if (json['faculty_name'] is String) {
      facultyVal = json['faculty_name'];
    }

    // Parse admin class name string
    String? adminClassVal;
    if (json['adminClassName'] is String) {
      adminClassVal = json['adminClassName'];
    } else if (json['admin_class_name'] is String) {
      adminClassVal = json['admin_class_name'];
    } else if (json['adminClass'] is Map) {
      adminClassVal = json['adminClass']['className'] ?? json['adminClass']['name'] ?? json['adminClass']['code'];
    } else if (json['className'] is String) {
      adminClassVal = json['className'];
    }

    // Parse curriculum name string
    String? curriculumVal;
    if (json['curriculumName'] is String) {
      curriculumVal = json['curriculumName'];
    } else if (json['curriculum_name'] is String) {
      curriculumVal = json['curriculum_name'];
    } else if (json['curriculum'] is Map) {
      curriculumVal = json['curriculum']['name'] ?? json['curriculum']['title'];
    } else if (json['major'] is String) {
      curriculumVal = json['major'];
    }

    return UserEntity(
      id: json['id'] is int ? json['id'] : (int.tryParse((json['id'] ?? 0).toString()) ?? 1),
      fullName: json['fullName'] ?? json['full_name'] ?? json['name'] ?? '',
      email: json['email'] ?? json['username'] ?? '',
      personalEmail: json['personalEmail'] ?? json['personal_email'],
      role: json['role'] != null ? json['role'].toString() : 'STUDENT',
      studentCode: json['studentCode'] ?? json['student_code'] ?? json['code'],
      lecturerCode: json['lecturerCode'] ?? json['lecturer_code'],
      faculty: facultyVal,
      major: json['major'] is String ? json['major'] : null,
      adminClassName: adminClassVal,
      curriculumName: curriculumVal,
      avatarUrl: json['avatarUrl'] ?? json['avatar_url'] ?? json['avatar'],
      token: json['token'] ?? json['accessToken'],
      refreshToken: json['refreshToken'] ?? json['refresh_token'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fullName': fullName,
    'email': email,
    'personalEmail': personalEmail,
    'role': role,
    'studentCode': studentCode,
    'lecturerCode': lecturerCode,
    'faculty': faculty,
    'major': major,
    'adminClassName': adminClassName,
    'curriculumName': curriculumName,
    'avatarUrl': avatarUrl,
    'token': token,
    'refreshToken': refreshToken,
  };
}
