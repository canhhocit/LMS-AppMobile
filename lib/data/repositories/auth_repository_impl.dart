import 'dart:convert';
import 'package:dio/dio.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/error/failures.dart';
import '../../core/network/dio_client.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../mappers/user_mapper.dart';
import '../remote/dtos/auth_dtos.dart';
import '../session/session_manager.dart';

class AuthRepositoryImpl implements AuthRepository {
  final DioClient dioClient;
  final SessionManager sessionManager;

  AuthRepositoryImpl({
    required this.dioClient,
    required this.sessionManager,
  });

  @override
  Future<UserEntity> login(String username, String password) async {
    try {
      final response = await dioClient.dio.post(
        ApiEndpoints.login,
        data: LoginRequestDto(username: username, password: password).toJson(),
      );

      final dto = LoginResponseDto.fromJson(response.data);
      await sessionManager.saveTokens(
        token: dto.token,
        refreshToken: dto.refreshToken,
      );

      final entity = dto.toEntity();
      final userJson = jsonEncode({
        'id': entity.id,
        'username': entity.username,
        'fullName': entity.fullName,
        'email': entity.email,
        'role': entity.role,
        'studentCode': entity.studentCode,
        'facultyName': entity.facultyName,
        'curriculumName': entity.curriculumName,
        'adminClassName': entity.adminClassName,
      });
      await sessionManager.saveUserJson(userJson);

      return entity;
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Đăng nhập thất bại. Vui lòng kiểm tra lại tài khoản.';
      throw AuthFailure(msg);
    } catch (e) {
      throw const AuthFailure('Đã xảy ra lỗi không xác định.');
    }
  }

  @override
  Future<void> logout() async {
    await sessionManager.clearSession();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final jsonStr = sessionManager.getUserJson();
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      final Map<String, dynamic> map = jsonDecode(jsonStr);
      return UserEntity(
        id: map['id'] ?? 1,
        username: map['username'] ?? '',
        fullName: map['fullName'] ?? '',
        email: map['email'] ?? '',
        role: map['role'] ?? 'STUDENT',
        studentCode: map['studentCode'],
        facultyName: map['facultyName'],
        curriculumName: map['curriculumName'],
        adminClassName: map['adminClassName'],
      );
    } catch (_) {
      return null;
    }
  }
}
