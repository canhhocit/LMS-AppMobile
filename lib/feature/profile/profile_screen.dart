import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_avatar.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../domain/repositories/auth_repository.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getIt<AuthRepository>().getCurrentUser(),
      builder: (context, snapshot) {
        final user = snapshot.data;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Hồ sơ cá nhân'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Profile Avatar & Main Info Header
                Center(
                  child: Column(
                    children: [
                      AppAvatar(
                        name: user?.fullName ?? 'Sinh Viên',
                        radius: 40,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user?.fullName ?? 'Nguyễn Văn A',
                        style: AppTextStyles.h2,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Mã SV: ${user?.studentCode ?? "SV62001"} • Role: ${user?.role ?? "STUDENT"}',
                        style: AppTextStyles.body2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Academic & Organization Details
                Text('Thông tin học tập', style: AppTextStyles.h3),
                const SizedBox(height: 12),
                AppCard(
                  child: Column(
                    children: [
                      _buildInfoRow(
                        icon: Icons.domain,
                        label: 'Khoa / Bộ môn',
                        value: user?.facultyName ?? 'Công nghệ thông tin',
                      ),
                      const Divider(height: 20),
                      _buildInfoRow(
                        icon: Icons.history_edu,
                        label: 'Chương trình đào tạo',
                        value: user?.curriculumName ?? 'Công nghệ thông tin K65',
                      ),
                      const Divider(height: 20),
                      _buildInfoRow(
                        icon: Icons.groups,
                        label: 'Lớp hành chính',
                        value: user?.adminClassName ?? '62PM1',
                      ),
                      const Divider(height: 20),
                      _buildInfoRow(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: user?.email ?? 'student@learninghub.edu.vn',
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
      },
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
