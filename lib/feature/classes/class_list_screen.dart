import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_badge.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../core/widgets/app_error_state.dart';
import '../../core/widgets/app_skeleton.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/lms_repository.dart';
import 'class_cubit.dart';
import 'class_detail_screen.dart';
import 'class_state.dart';

class ClassListScreen extends StatefulWidget {
  const ClassListScreen({super.key});

  @override
  State<ClassListScreen> createState() => _ClassListScreenState();
}

class _ClassListScreenState extends State<ClassListScreen> {
  UserEntity? _currentUser;

  @override
  void initState() {
    super.initState();
    getIt<LmsRepository>().getCurrentUser().then((u) {
      if (mounted) setState(() => _currentUser = u);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ClassCubit(getIt())..loadClasses(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Danh sách lớp học phần'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: BlocBuilder<ClassCubit, ClassState>(
          builder: (context, state) {
            if (state is ClassLoading) {
              return AppSkeleton.listLoader(count: 4, height: 110);
            }
            if (state is ClassError) {
              return AppErrorState(
                message: state.message,
                onRetry: () => context.read<ClassCubit>().loadClasses(),
              );
            }
            if (state is ClassLoaded) {
              final classes = state.classes;
              if (classes.isEmpty) {
                return AppEmptyState(
                  title: 'Chưa tham gia lớp học phần nào',
                  subtitle: 'Các lớp môn học đăng ký thành công sẽ hiển thị tại đây.',
                  icon: Icons.school_outlined,
                  onAction: () => context.read<ClassCubit>().loadClasses(),
                  actionLabel: 'Tải lại',
                );
              }

              return RefreshIndicator(
                onRefresh: () => context.read<ClassCubit>().loadClasses(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: classes.length,
                  itemBuilder: (context, index) {
                    final item = classes[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AppCard(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ClassDetailScreen(
                                courseClass: item,
                                currentUser: _currentUser ?? const UserEntity(id: 1, fullName: 'Người dùng', email: 'user@edu.vn', role: 'STUDENT'),
                              ),
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                AppBadge(
                                  text: item.classCode,
                                  variant: AppBadgeVariant.primary,
                                ),
                                Text(
                                  'Sĩ số: ${item.enrolledCount}/${item.maxStudents}',
                                  style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              item.courseTitle,
                              style: AppTextStyles.h3.copyWith(fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.person_outline_rounded, size: 16, color: AppColors.textSecondary),
                                const SizedBox(width: 4),
                                Text(
                                  'GV: ${item.lecturerName ?? "Đang cập nhật"}',
                                  style: AppTextStyles.body2,
                                ),
                              ],
                            ),
                            if (item.scheduleText != null && item.scheduleText!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.access_time_rounded, size: 16, color: AppColors.textSecondary),
                                  const SizedBox(width: 4),
                                  Text(
                                    item.scheduleText!,
                                    style: AppTextStyles.body2,
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
