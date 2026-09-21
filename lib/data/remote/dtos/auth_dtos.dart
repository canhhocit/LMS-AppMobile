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
  final int id;
  final String token;
  final String? refreshToken;
  final String username;
  final String fullName;
  final String email;
  final String? personalEmail;
  final String role;
  final String? studentCode;
  final String? lecturerCode;
  final String? facultyName;
  final String? curriculumName;
  final String? adminClassName;
  final String? avatarUrl;

  LoginResponseDto({
    required this.id,
    required this.token,
    this.refreshToken,
    required this.username,
    required this.fullName,
    required this.email,
    this.personalEmail,
    required this.role,
    this.studentCode,
    this.lecturerCode,
    this.facultyName,
    this.curriculumName,
    this.adminClassName,
    this.avatarUrl,
  });

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    
    // Faculty parsing
    String? facultyVal;
    if (data['facultyName'] is String) {
      facultyVal = data['facultyName'];
    } else if (data['faculty'] is String) {
      facultyVal = data['faculty'];
    } else if (data['faculty'] is Map) {
      facultyVal = data['faculty']['name'] ?? data['faculty']['facultyName'];
    }

    // Admin class parsing
    String? adminClassVal;
    if (data['adminClassName'] is String) {
      adminClassVal = data['adminClassName'];
    } else if (data['adminClass'] is Map) {
      adminClassVal = data['adminClass']['className'] ?? data['adminClass']['name'];
    }

    // Curriculum parsing
    String? curriculumVal;
    if (data['curriculumName'] is String) {
      curriculumVal = data['curriculumName'];
    } else if (data['curriculum'] is Map) {
      curriculumVal = data['curriculum']['name'] ?? data['curriculum']['title'];
    }

    return LoginResponseDto(
      id: data['id'] is int ? data['id'] : (int.tryParse((data['id'] ?? 0).toString()) ?? 1),
      token: data['token'] ?? data['accessToken'] ?? '',
      refreshToken: data['refreshToken'],
      username: data['username'] ?? data['email'] ?? '',
      fullName: data['fullName'] ?? data['name'] ?? '',
      email: data['email'] ?? data['username'] ?? '',
      personalEmail: data['personalEmail'] ?? data['personal_email'],
      role: data['role'] != null ? data['role'].toString() : 'STUDENT',
      studentCode: data['studentCode'] ?? data['student_code'],
      lecturerCode: data['lecturerCode'] ?? data['lecturer_code'],
      facultyName: facultyVal,
      curriculumName: curriculumVal,
      adminClassName: adminClassVal,
      avatarUrl: data['avatarUrl'] ?? data['avatar_url'] ?? data['avatar'],
    );
  }
}
