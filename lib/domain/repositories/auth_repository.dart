import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login(String username, String password);
  Future<void> logout();
  Future<UserEntity?> getCurrentUser();
  Future<UserEntity> updateProfile({String? personalEmail, String? fullName, String? avatarUrl});
  Future<void> changePassword(String oldPassword, String newPassword);
}
