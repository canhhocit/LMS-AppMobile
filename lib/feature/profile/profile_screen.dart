import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_avatar.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_text_field.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../auth/login_screen.dart';
import '../../app.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserEntity? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    final user = await getIt<AuthRepository>().getCurrentUser();
    if (mounted) {
      setState(() {
        _user = user;
        _isLoading = false;
      });
    }
  }

  void _showUpdateEmailDialog() {
    final controller = TextEditingController(text: _user?.personalEmail ?? '');
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text('Cập nhật Email cá nhân', style: AppTextStyles.h3),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Email cá nhân dùng để nhận thông báo và hỗ trợ đặt lại mật khẩu khi quên.',
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Email cá nhân',
                    hint: 'nhap_email@gmail.com',
                    controller: controller,
                    prefixIcon: Icons.alternate_email,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.pop(dialogContext),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: isSaving
                      ? null
                      : () async {
                          final newEmail = controller.text.trim();
                          if (newEmail.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Vui lòng nhập email cá nhân hợp lệ')),
                            );
                            return;
                          }
                          setDialogState(() => isSaving = true);
                          try {
                            final updatedUser = await getIt<AuthRepository>().updateProfile(
                              personalEmail: newEmail,
                            );
                            if (mounted) {
                              setState(() => _user = updatedUser);
                              Navigator.pop(dialogContext);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Cập nhật email cá nhân thành công!'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              setDialogState(() => isSaving = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Cập nhật thất bại: ${e.toString()}'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          }
                        },
                  child: isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Lưu', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showChangePasswordDialog() {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text('Đổi mật khẩu', style: AppTextStyles.h3),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppTextField(
                      label: 'Mật khẩu hiện tại',
                      hint: '••••••',
                      controller: oldPasswordController,
                      isPassword: true,
                      prefixIcon: Icons.lock_outline,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      label: 'Mật khẩu mới',
                      hint: '••••••',
                      controller: newPasswordController,
                      isPassword: true,
                      prefixIcon: Icons.lock_reset,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      label: 'Xác nhận mật khẩu mới',
                      hint: '••••••',
                      controller: confirmPasswordController,
                      isPassword: true,
                      prefixIcon: Icons.check_circle_outline,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.pop(dialogContext),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          final oldPwd = oldPasswordController.text;
                          final newPwd = newPasswordController.text;
                          final confirmPwd = confirmPasswordController.text;

                          if (oldPwd.isEmpty || newPwd.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin mật khẩu')),
                            );
                            return;
                          }
                          if (newPwd != confirmPwd) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Mật khẩu mới và xác nhận mật khẩu không khớp'),
                                backgroundColor: AppColors.warning,
                              ),
                            );
                            return;
                          }

                          setDialogState(() => isSubmitting = true);
                          try {
                            await getIt<AuthRepository>().changePassword(oldPwd, newPwd);
                            if (mounted) {
                              Navigator.pop(dialogContext);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Đổi mật khẩu thành công!'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              setDialogState(() => isSubmitting = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Đổi mật khẩu thất bại. Vui lòng kiểm tra lại mật khẩu cũ!'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Đổi mật khẩu', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final user = _user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ cá nhân'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Avatar & Main Info Header
            Center(
              child: Column(
                children: [
                  AppAvatar(
                    name: user?.fullName ?? 'Người dùng',
                    radius: 40,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.fullName ?? 'Họ và tên',
                    style: AppTextStyles.h2,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.isLecturer == true
                        ? 'Mã GV: ${user?.lecturerCode ?? "Chưa cấp"} • Vai trò: Giảng viên'
                        : 'Mã SV: ${user?.studentCode ?? "Chưa cấp"} • Vai trò: Sinh viên',
                    style: AppTextStyles.body2,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Academic & Organization Details
            Text('Thông tin học tập & Tổ chức', style: AppTextStyles.h3),
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                children: [
                  _buildInfoRow(
                    icon: Icons.domain,
                    label: 'Khoa / Bộ môn',
                    value: user?.facultyName ?? (user?.faculty != null && user!.faculty!.isNotEmpty ? user.faculty! : 'Chưa cập nhật'),
                  ),
                  const Divider(height: 20),
                  _buildInfoRow(
                    icon: Icons.history_edu,
                    label: 'Chương trình đào tạo',
                    value: user?.displayCurriculum ?? 'Chưa cập nhật',
                  ),
                  const Divider(height: 20),
                  _buildInfoRow(
                    icon: Icons.groups,
                    label: 'Lớp hành chính',
                    value: user?.adminClassName ?? 'Chưa phân lớp',
                  ),
                  const Divider(height: 20),
                  _buildInfoRow(
                    icon: Icons.email_outlined,
                    label: 'Email tài khoản (trường)',
                    value: user?.email ?? 'Chưa cập nhật',
                  ),
                  const Divider(height: 20),
                  Row(
                    children: [
                      const Icon(Icons.alternate_email, color: AppColors.primary, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Email cá nhân', style: AppTextStyles.caption),
                            const SizedBox(height: 2),
                            Text(
                              user?.personalEmail != null && user!.personalEmail!.isNotEmpty
                                  ? user.personalEmail!
                                  : 'Chưa liên kết email cá nhân',
                              style: AppTextStyles.body1.copyWith(
                                fontWeight: FontWeight.w600,
                                color: user?.personalEmail != null && user!.personalEmail!.isNotEmpty
                                    ? AppColors.textPrimary
                                    : AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                        tooltip: 'Cập nhật email cá nhân',
                        onPressed: _showUpdateEmailDialog,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Security Settings
            Text('Bảo mật & Tài khoản', style: AppTextStyles.h3),
            const SizedBox(height: 12),
            AppCard(
              onTap: _showChangePasswordDialog,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lock_reset_rounded, color: AppColors.primary),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Đổi mật khẩu', style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text('Cập nhật mật khẩu tài khoản của bạn', style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.textMuted),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Theme Settings Card
            Text('Giao diện & Cài đặt', style: AppTextStyles.h3),
            const SizedBox(height: 12),
            AppCard(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      themeNotifier.value == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Chế độ Tối (Dark Mode)', style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text('Bật/Tắt giao diện tối bảo vệ mắt', style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                  Switch(
                    value: themeNotifier.value == ThemeMode.dark,
                    activeColor: AppColors.primary,
                    onChanged: (isDark) {
                      setState(() {
                        themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Logout Button
            AppButton(
              text: 'Đăng xuất',
              icon: Icons.logout,
              variant: AppButtonVariant.outline,
              onPressed: () async {
                await getIt<AuthRepository>().logout();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.caption),
              const SizedBox(height: 2),
              Text(value, style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}
