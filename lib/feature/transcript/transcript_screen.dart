import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_badge.dart';
import '../../core/widgets/app_card.dart';
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
        ),
        body: BlocBuilder<TranscriptCubit, TranscriptState>(
          builder: (context, state) {
            if (state is TranscriptLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is TranscriptError) {
              return Center(child: Text(state.message));
            }
            if (state is TranscriptLoaded) {
              final grades = state.grades;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // GPA Overview Header Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              Text(
                                state.gpa.toStringAsFixed(2),
                                style: AppTextStyles.h1.copyWith(
                                  fontSize: 36,
                                  color: Colors.white,
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
                            color: Colors.white.withOpacity(0.3),
                          ),
                          Column(
                            children: [
                              Text(
                                '${state.totalCreditsSum}',
                                style: AppTextStyles.h1.copyWith(
                                  fontSize: 36,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tín chỉ tích lũy',
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
                        Text('Chi tiết điểm môn học', style: AppTextStyles.h3),
                        Text(
                          '${grades.length} môn học',
                          style: AppTextStyles.body2,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Grades List
                    ListView.builder(
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
                                  'Mã môn: ${g.courseCode} • Số TC: ${g.credits}',
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
