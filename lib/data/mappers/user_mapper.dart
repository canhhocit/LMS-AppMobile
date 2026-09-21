import '../../domain/entities/user_entity.dart';
import '../remote/dtos/auth_dtos.dart';

extension LoginResponseDtoMapper on LoginResponseDto {
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      fullName: fullName,
      email: email,
      personalEmail: personalEmail,
      role: role,
      studentCode: studentCode,
      lecturerCode: lecturerCode,
      faculty: facultyName,
      curriculumName: curriculumName,
      adminClassName: adminClassName,
      avatarUrl: avatarUrl,
      token: token,
      refreshToken: refreshToken,
    );
  }
}
