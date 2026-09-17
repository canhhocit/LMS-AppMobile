import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_badge.dart';
import '../../core/widgets/app_card.dart';
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
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ClassError) {
              return Center(child: Text(state.message));
            }
            if (state is ClassLoaded) {
              final classes = state.classes;
              if (classes.isEmpty) {
                return Center(
                  child: Text('Chưa có lớp học nào', style: AppTextStyles.body1),
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
                                currentUser: _currentUser ?? const UserEntity(id: 1, fullName: 'Demo', email: 'demo@edu.vn', role: 'STUDENT'),
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
                                  style: AppTextStyles.caption,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              item.courseTitle,
                              style: AppTextStyles.h3,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.person_outline, size: 16, color: AppColors.textSecondary),
                                const SizedBox(width: 4),
                                Text(
                                  'GV: ${item.lecturerName ?? "Phân công sau"}',
                                  style: AppTextStyles.body2,
                                ),
                              ],
                            ),
                            if (item.scheduleText != null) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
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
