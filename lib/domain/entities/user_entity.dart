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
    return UserEntity(
      id: json['id'] is int ? json['id'] : int.parse((json['id'] ?? 0).toString()),
      fullName: json['fullName'] ?? json['full_name'] ?? '',
      email: json['email'] ?? '',
      personalEmail: json['personalEmail'] ?? json['personal_email'],
      role: json['role'] != null ? json['role'].toString() : 'STUDENT',
      studentCode: json['studentCode'] ?? json['student_code'],
      lecturerCode: json['lecturerCode'] ?? json['lecturer_code'],
      faculty: json['faculty'] ?? json['faculty_name'],
      major: json['major'],
      adminClassName: json['adminClassName'] ?? json['admin_class_name'] ?? (json['adminClass'] is Map ? json['adminClass']['className'] : null),
      curriculumName: json['curriculumName'] ?? json['curriculum_name'] ?? (json['curriculum'] is Map ? json['curriculum']['name'] : json['major']),
      avatarUrl: json['avatarUrl'] ?? json['avatar_url'],
      token: json['token'],
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
