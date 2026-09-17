class LoginRequestDto {
  final String username;
  final String password;

  LoginRequestDto({required this.username, required this.password});

  Map<String, dynamic> toJson() => {
        'username': username,
        'password': password,
      };
}

class LoginResponseDto {
  final String token;
  final String? refreshToken;
  final String username;
  final String fullName;
  final String email;
  final String role;
  final String? studentCode;
  final String? facultyName;
  final String? curriculumName;
  final String? adminClassName;

  LoginResponseDto({
    required this.token,
    this.refreshToken,
    required this.username,
    required this.fullName,
    required this.email,
    required this.role,
    this.studentCode,
    this.facultyName,
    this.curriculumName,
    this.adminClassName,
  });

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    return LoginResponseDto(
      token: data['token'] ?? data['accessToken'] ?? '',
      refreshToken: data['refreshToken'],
      username: data['username'] ?? '',
      fullName: data['fullName'] ?? data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'STUDENT',
      studentCode: data['studentCode'],
      facultyName: data['facultyName'],
      curriculumName: data['curriculumName'],
      adminClassName: data['adminClassName'],
    );
  }
}
