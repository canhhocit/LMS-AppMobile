class UserEntity {
  final LongId id;
  final String username;
  final String fullName;
  final String email;
  final String role;
  final String? studentCode;
  final String? facultyName;
  final String? curriculumName;
  final String? adminClassName;
  final String? avatarUrl;

  const UserEntity({
    required this.id,
    required this.username,
    required this.fullName,
    required this.email,
    required this.role,
    this.studentCode,
    this.facultyName,
    this.curriculumName,
    this.adminClassName,
    this.avatarUrl,
  });
}

typedef LongId = int;
