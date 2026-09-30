import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_avatar.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_skeleton.dart';
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

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xác nhận đăng xuất', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('Đăng xuất', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await getIt<AuthRepository>().logout();
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  void _showChangePasswordDialog() {
    final oldPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Đổi mật khẩu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldPassCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mật khẩu hiện tại',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newPassCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mật khẩu mới',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: isSubmitting
                  ? null
                  : () async {
                      if (oldPassCtrl.text.isEmpty || newPassCtrl.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Vui lòng nhập đầy đủ mật khẩu!'), backgroundColor: AppColors.warning),
                        );
                        return;
                      }
                      setDialogState(() => isSubmitting = true);
                      try {
                        await getIt<AuthRepository>().changePassword(oldPassCtrl.text, newPassCtrl.text);
                        if (mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Đổi mật khẩu thành công!'), backgroundColor: AppColors.success),
                          );
                        }
                      } catch (e) {
                        setDialogState(() => isSubmitting = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Lỗi: ${e.toString()}'), backgroundColor: AppColors.error),
                        );
                      }
                    },
              child: Text(isSubmitting ? 'Đang xử lý...' : 'Cập nhật'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const AppSkeleton.circular(size: 80),
            const SizedBox(height: 16),
            const AppSkeleton.rectangular(height: 40),
            const SizedBox(height: 24),
            AppSkeleton.listLoader(count: 3, height: 90),
          ],
        ),
      );
    }

    final user = _user;
    final isLecturer = user?.isLecturer ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ cá nhân'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // User Profile Header Card
            AppCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  AppAvatar(
                    name: user?.fullName ?? 'Người dùng',
                    radius: 36,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.fullName ?? 'Người dùng',
                    style: AppTextStyles.h2.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? 'chua_cap_nhat@edu.vn',
                    style: AppTextStyles.body2,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isLecturer ? 'Mã giảng viên: ${user?.lecturerCode ?? "---"}' : 'Mã sinh viên: ${user?.studentCode ?? "---"}',
                      style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Academic Information Group
            _buildSectionHeader('Thông tin học tập & Hành chính'),
            const SizedBox(height: 8),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildInfoTile(
                    icon: Icons.school_outlined,
                    label: isLecturer ? 'Khoa giảng dạy' : 'Khoa / Ngành',
                    value: user?.faculty ?? 'Chưa cập nhật',
                  ),
                  const Divider(height: 1, indent: 48),
                  _buildInfoTile(
                    icon: Icons.meeting_room_outlined,
                    label: isLecturer ? 'Bộ môn' : 'Lớp danh nghĩa',
                    value: user?.adminClassName ?? 'Chưa phân lớp',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // App Settings Group
            _buildSectionHeader('Tùy chỉnh ứng dụng'),
            const SizedBox(height: 8),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ValueListenableBuilder<ThemeMode>(
                    valueListenable: themeNotifier,
                    builder: (context, currentMode, _) {
                      final isDark = currentMode == ThemeMode.dark;
                      return ListTile(
                        leading: Icon(isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined, color: AppColors.textPrimary),
                        title: Text('Giao diện tối (Dark Mode)', style: AppTextStyles.body1.copyWith(fontSize: 14)),
                        trailing: Switch(
                          value: isDark,
                          onChanged: (val) {
                            themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Account & Security Group
            _buildSectionHeader('Tài khoản & Bảo mật'),
            const SizedBox(height: 8),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.lock_outline_rounded, color: AppColors.textPrimary),
                    title: Text('Đổi mật khẩu', style: AppTextStyles.body1.copyWith(fontSize: 14)),
                    trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                    onTap: _showChangePasswordDialog,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Logout Button
            AppButton(
              text: 'Đăng xuất tài khoản',
              icon: Icons.logout_rounded,
              variant: AppButtonVariant.outline,
              onPressed: _handleLogout,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: AppTextStyles.caption.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.textMuted,
        ),
      ),
    );
  }

  Widget _buildInfoTile({required IconData icon, required String label, required String value}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 22),
      title: Text(label, style: AppTextStyles.caption),
      subtitle: Text(value, style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600, fontSize: 14)),
    );
  }
}
