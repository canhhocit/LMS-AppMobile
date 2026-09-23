import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_avatar.dart';
import '../../core/widgets/app_badge.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_education_logo.dart';
import '../../domain/entities/user_entity.dart';
import '../ai_advisor/ai_advisor_screen.dart';
import '../attendance/attendance_screen.dart';
import '../classes/class_detail_screen.dart';
import '../notifications/notifications_screen.dart';
import '../registration/registration_screen.dart';
import '../tuition/tuition_screen.dart';
import 'home_cubit.dart';
import 'home_state.dart';

class HomeScreen extends StatelessWidget {
  final Function(int)? onNavigateTab;

  const HomeScreen({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeCubit(
        authRepository: getIt(),
        studentRepository: getIt(),
      )..loadDashboard(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              if (state is HomeLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is HomeError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(state.message, style: AppTextStyles.body1),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => context.read<HomeCubit>().loadDashboard(),
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                );
              }

              final loaded = state is HomeLoaded ? state : null;
              final user = loaded?.user;
              final classes = loaded?.classes ?? [];
              final schedule = loaded?.todaySchedule ?? [];
              final isLecturer = user?.isLecturer ?? false;

              return RefreshIndicator(
                onRefresh: () => context.read<HomeCubit>().loadDashboard(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header User Card
                      Row(
                        children: [
                          AppAvatar(
                            name: user?.fullName ?? 'Người dùng',
                            radius: 26,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isLecturer ? 'Xin chào Giảng viên' : 'Xin chào Sinh viên',
                                  style: AppTextStyles.caption.copyWith(fontSize: 12),
                                ),
                                Text(
                                  user?.fullName ?? 'Người dùng',
                                  style: AppTextStyles.h2.copyWith(fontSize: 19),
                                ),
                                Text(
                                  isLecturer
                                      ? 'Khoa: ${user?.faculty ?? "Chưa cập nhật"} • MSG: ${user?.lecturerCode ?? "Chưa có"}'
                                      : 'Lớp: ${user?.adminClassName ?? "Chưa phân lớp"} • MSV: ${user?.studentCode ?? "Chưa có"}',
                                  style: AppTextStyles.body2.copyWith(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          const AppEducationLogo(size: 38),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.border),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.notifications_none, color: AppColors.textPrimary),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Quick Action Grid
                      Text('Dịch vụ & Năng lực nhanh', style: AppTextStyles.h3),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _buildQuickActionButton(
                            context: context,
                            icon: Icons.how_to_reg_outlined,
                            label: 'Đăng ký học',
                            color: const Color(0xFF4F46E5),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const RegistrationScreen()),
                              );
                            },
                          ),
                          _buildQuickActionButton(
                            context: context,
                            icon: Icons.smart_toy_outlined,
                            label: 'Trợ lý AI',
                            color: const Color(0xFF8B5CF6),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const AiAdvisorScreen()),
                              );
                            },
                          ),
                          _buildQuickActionButton(
                            context: context,
                            icon: Icons.fact_check_outlined,
                            label: 'Điểm danh',
                            color: const Color(0xFF10B981),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const AttendanceScreen()),
                              );
                            },
                          ),
                          _buildQuickActionButton(
                            context: context,
                            icon: Icons.account_balance_wallet_outlined,
                            label: 'Học phí',
                            color: const Color(0xFFF59E0B),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const TuitionScreen()),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Today Schedule Banner
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(isLecturer ? 'Lịch dạy hôm nay' : 'Lịch học hôm nay', style: AppTextStyles.h3),
                          TextButton(
                            onPressed: () => onNavigateTab?.call(2),
                            child: Text(
                              'Xem tất cả',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      schedule.isEmpty
                          ? AppCard(
                              child: Center(
                                child: Text(
                                  isLecturer ? 'Hôm nay không có lịch dạy' : 'Hôm nay không có lịch học',
                                  style: AppTextStyles.body2,
                                ),
                              ),
                            )
                          : Column(
                              children: schedule.map((item) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: AppCard(
                                    border: const Border(
                                      left: BorderSide(color: AppColors.primary, width: 4),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.courseName,
                                                style: AppTextStyles.body1.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Mã lớp: ${item.classCode} • Phòng: ${item.room}',
                                                style: AppTextStyles.body2,
                                              ),
                                            ],
                                          ),
                                        ),
                                        AppBadge(
                                          text: item.timeSlot,
                                          variant: AppBadgeVariant.primary,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                      const SizedBox(height: 24),

                      // Enrolled / Taught Classes Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(isLecturer ? 'Các Lớp học phần giảng dạy' : 'Lớp môn học học kỳ này', style: AppTextStyles.h3),
                          TextButton(
                            onPressed: () => onNavigateTab?.call(1),
                            child: Text(
                              'Xem tất cả',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Column(
                        children: classes.map((c) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: AppCard(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ClassDetailScreen(
                                      courseClass: c,
                                      currentUser: user ?? const UserEntity(id: 1, fullName: 'Demo', email: 'demo@edu.vn', role: 'STUDENT'),
                                    ),
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryLight,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.book_rounded,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          c.courseTitle,
                                          style: AppTextStyles.body1.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          isLecturer ? 'Mã lớp: ${c.classCode} • ${c.enrolledCount} SV' : 'GV: ${c.lecturerName ?? "Chưa phân công"} • ${c.classCode}',
                                          style: AppTextStyles.body2,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right_rounded,
                                    color: AppColors.textMuted,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final width = (MediaQuery.of(context).size.width - 52) / 2;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
