import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_avatar.dart';
import '../../core/widgets/app_badge.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../core/widgets/app_error_state.dart';
import '../../core/widgets/app_skeleton.dart';
import '../../domain/entities/user_entity.dart';
import '../../core/widgets/academic_warning_banner.dart';
import '../ai_advisor/ai_advisor_screen.dart';
import '../attendance/attendance_screen.dart';
import '../classes/class_detail_screen.dart';
import '../notifications/notifications_screen.dart';
import '../registration/registration_screen.dart';
import '../transcript/transcript_screen.dart';
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
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          AppSkeleton.circular(size: 52),
                          SizedBox(width: 14),
                          Expanded(child: AppSkeleton.rectangular(height: 44)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const AppSkeleton.rectangular(height: 120),
                      const SizedBox(height: 24),
                      AppSkeleton.listLoader(count: 3, height: 72),
                    ],
                  ),
                );
              }
              if (state is HomeError) {
                return AppErrorState(
                  message: state.message,
                  onRetry: () => context.read<HomeCubit>().loadDashboard(),
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
                      // Header User Profile Bar
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
                                  isLecturer ? 'Giảng viên' : 'Sinh viên',
                                  style: AppTextStyles.caption.copyWith(
                                    fontSize: 12,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  user?.fullName ?? 'Người dùng',
                                  style: AppTextStyles.h2.copyWith(fontSize: 18),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  isLecturer
                                      ? 'Khoa: ${user?.faculty ?? "Chưa cập nhật"} • MSG: ${user?.lecturerCode ?? "---"}'
                                      : 'Lớp: ${user?.adminClassName ?? "---"} • MSV: ${user?.studentCode ?? "---"}',
                                  style: AppTextStyles.body2.copyWith(fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.border),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary),
                              onPressed: () {
                                if (onNavigateTab != null) {
                                  onNavigateTab!(3);
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Academic Warning Banner for Students
                      if (!isLecturer && user != null)
                        AcademicWarningBanner(
                          studentName: user.fullName,
                          studentCode: user.studentCode,
                          debtCredits: 0,
                          gpa: null,
                          onRegisterRemediation: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const RegistrationScreen()),
                            );
                          },
                          onAskAiAdvisor: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AiAdvisorScreen()),
                            );
                          },
                        ),

                      // Today's Schedule Card (Highest Priority)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isLecturer ? 'Lịch dạy hôm nay' : 'Lịch học hôm nay',
                            style: AppTextStyles.h3,
                          ),
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
                              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.08),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.event_available_rounded, color: AppColors.primary, size: 24),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          isLecturer ? 'Hôm nay không có lịch dạy' : 'Hôm nay không có lịch học',
                                          style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600, fontSize: 14),
                                        ),
                                        Text(
                                          'Chúc bạn một ngày học tập và làm việc hiệu quả!',
                                          style: AppTextStyles.body2.copyWith(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
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
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  const Icon(Icons.meeting_room_outlined, size: 14, color: AppColors.textSecondary),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      'Phòng: ${item.room.isNotEmpty ? item.room : "---"} • Mã lớp: ${item.classCode}',
                                                      style: AppTextStyles.body2,
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
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

                      // Quick Services Grid
                      Text('Dịch vụ sinh viên', style: AppTextStyles.h3),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildQuickServiceItem(
                            context: context,
                            icon: Icons.how_to_reg_outlined,
                            label: 'Đăng ký học',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const RegistrationScreen()),
                              );
                            },
                          ),
                          _buildQuickServiceItem(
                            context: context,
                            icon: Icons.qr_code_scanner_rounded,
                            label: 'Điểm danh',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const AttendanceScreen()),
                              );
                            },
                          ),
                          _buildQuickServiceItem(
                            context: context,
                            icon: Icons.assessment_outlined,
                            label: 'Bảng điểm',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const TranscriptScreen()),
                              );
                            },
                          ),
                          _buildQuickServiceItem(
                            context: context,
                            icon: Icons.account_balance_wallet_outlined,
                            label: 'Học phí',
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

                      // My Classes Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isLecturer ? 'Lớp giảng dạy học kỳ này' : 'Lớp học phần học kỳ này',
                            style: AppTextStyles.h3,
                          ),
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
                      classes.isEmpty
                          ? const AppEmptyState(
                              title: 'Chưa tham gia lớp học nào',
                              subtitle: 'Các lớp môn học của bạn sẽ xuất hiện tại đây.',
                              icon: Icons.class_outlined,
                            )
                          : Column(
                              children: classes.take(4).map((c) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: AppCard(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ClassDetailScreen(
                                            courseClass: c,
                                            currentUser: user ?? const UserEntity(id: 1, fullName: 'Người dùng', email: 'user@edu.vn', role: 'STUDENT'),
                                          ),
                                        ),
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryBackground,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: const Icon(
                                            Icons.book_outlined,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                c.courseTitle,
                                                style: AppTextStyles.body1.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                isLecturer
                                                    ? 'Mã lớp: ${c.classCode} • Sĩ số: ${c.enrolledCount} SV'
                                                    : 'GV: ${c.lecturerName ?? "Đang cập nhật"} • ${c.classCode}',
                                                style: AppTextStyles.body2,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
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

  Widget _buildQuickServiceItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: AppColors.primary, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
