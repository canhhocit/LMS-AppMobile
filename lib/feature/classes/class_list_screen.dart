import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_badge.dart';
import '../../core/widgets/app_card.dart';
import 'class_cubit.dart';
import 'class_detail_screen.dart';
import 'class_state.dart';

class ClassListScreen extends StatelessWidget {
  const ClassListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ClassCubit(getIt())..loadClasses(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Danh sách lớp học'),
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
                  padding: const EdgeInsets.all(20),
                  itemCount: classes.length,
                  itemBuilder: (context, index) {
                    final item = classes[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AppCard(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ClassDetailScreen(courseClass: item),
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
                                  '${item.studentCount} sinh viên',
                                  style: AppTextStyles.caption,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              item.courseName,
                              style: AppTextStyles.h3,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.person_outline, size: 16, color: AppColors.textSecondary),
                                const SizedBox(width: 4),
                                Text(
                                  'GV: ${item.teacherName}',
                                  style: AppTextStyles.body2,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
                                const SizedBox(width: 4),
                                Text(
                                  item.scheduleText,
                                  style: AppTextStyles.body2,
                                ),
                              ],
                            ),
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
