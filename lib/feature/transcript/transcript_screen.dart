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
import 'transcript_cubit.dart';
import 'transcript_state.dart';

class TranscriptScreen extends StatelessWidget {
  const TranscriptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TranscriptCubit(getIt())..loadGrades(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bảng điểm cá nhân'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: BlocBuilder<TranscriptCubit, TranscriptState>(
          builder: (context, state) {
            if (state is TranscriptLoading) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const AppSkeleton.rectangular(height: 100),
                    const SizedBox(height: 20),
                    AppSkeleton.listLoader(count: 4, height: 110),
                  ],
                ),
              );
            }
            if (state is TranscriptError) {
              return AppErrorState(
                message: state.message,
                onRetry: () => context.read<TranscriptCubit>().loadGrades(),
              );
            }
            if (state is TranscriptLoaded) {
              final grades = state.grades;

              return RefreshIndicator(
                onRefresh: () => context.read<TranscriptCubit>().loadGrades(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Academic Summary Header Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text(
                                  state.gpa.toStringAsFixed(2),
                                  style: AppTextStyles.h1.copyWith(
                                    fontSize: 32,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Điểm trung bình (GPA)',
                                  style: AppTextStyles.caption.copyWith(
                                    color: Colors.white.withOpacity(0.85),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              height: 40,
                              width: 1,
                              color: Colors.white.withOpacity(0.25),
                            ),
                            Column(
                              children: [
                                Text(
                                  '${state.totalCreditsSum}',
                                  style: AppTextStyles.h1.copyWith(
                                    fontSize: 32,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Tổng số tín chỉ',
                                  style: AppTextStyles.caption.copyWith(
                                    color: Colors.white.withOpacity(0.85),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Grades List Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Bảng điểm môn học', style: AppTextStyles.h3),
                          Text(
                            '${grades.length} môn',
                            style: AppTextStyles.body2,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      grades.isEmpty
                          ? const AppEmptyState(
                              title: 'Chưa có dữ liệu điểm môn học',
                              subtitle: 'Điểm tổng kết các môn học sẽ được cập nhật sau khi kết thúc học phần.',
                              icon: Icons.assignment_turned_in_outlined,
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: grades.length,
                              itemBuilder: (context, index) {
                                final g = grades[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: AppCard(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                g.courseName,
                                                style: AppTextStyles.body1.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ),
                                            if (g.letterGrade != null)
                                              AppBadge(
                                                text: 'Điểm ${g.letterGrade}',
                                                variant: AppBadgeVariant.success,
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Mã môn: ${g.courseCode} • Số tín chỉ: ${g.credits}',
                                          style: AppTextStyles.body2,
                                        ),
                                        const Divider(height: 20),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            _buildGradeColumn('Chuyên cần', g.attendanceGrade),
                                            _buildGradeColumn('Giữa kỳ', g.midtermGrade),
                                            _buildGradeColumn('Cuối kỳ', g.finalGrade),
                                            _buildGradeColumn('Tổng kết', g.overallGrade, isBold: true),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildGradeColumn(String label, double? val, {bool isBold = false}) {
    return Column(
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 4),
        Text(
          val != null ? val.toStringAsFixed(1) : '-',
          style: AppTextStyles.body1.copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: isBold ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
