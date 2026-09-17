import '../../domain/entities/user_entity.dart';
import '../remote/dtos/auth_dtos.dart';

extension LoginResponseDtoMapper on LoginResponseDto {
  UserEntity toEntity() {
    return UserEntity(
      id: 1, // Default or parsed from JWT payload
      fullName: fullName,
      email: email,
      role: role,
      studentCode: studentCode,
      faculty: facultyName,
      curriculumName: curriculumName,
      adminClassName: adminClassName,
      token: token,
      refreshToken: refreshToken,
    );
  }
}
