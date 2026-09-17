import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_badge.dart';
import '../../core/widgets/app_card.dart';
import 'schedule_cubit.dart';
import 'schedule_state.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  static const List<Map<String, dynamic>> days = [
    {'label': 'Thứ 2', 'value': 2},
    {'label': 'Thứ 3', 'value': 3},
    {'label': 'Thứ 4', 'value': 4},
    {'label': 'Thứ 5', 'value': 5},
    {'label': 'Thứ 6', 'value': 6},
    {'label': 'Thứ 7', 'value': 7},
    {'label': 'Chủ nhật', 'value': 8},
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ScheduleCubit(getIt())..loadSchedule(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Thời khóa biểu'),
        ),
        body: BlocBuilder<ScheduleCubit, ScheduleState>(
          builder: (context, state) {
            if (state is ScheduleLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ScheduleError) {
              return Center(child: Text(state.message));
            }
            if (state is ScheduleLoaded) {
              final selectedDay = state.selectedDayOfWeek;
              final filtered = state.filteredSchedule;

              return Column(
                children: [
                  // Days Selector Bar
                  Container(
                    height: 54,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    color: Colors.white,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: days.length,
                      itemBuilder: (context, index) {
                        final day = days[index];
                        final isSelected = day['value'] == selectedDay;

                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(day['label']),
                            selected: isSelected,
                            selectedColor: AppColors.primary,
                            backgroundColor: AppColors.surface,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            onSelected: (_) {
                              context.read<ScheduleCubit>().selectDay(day['value']);
                            },
                          ),
                        );
                      },
                    ),
                  ),

                  // Schedule Items List
                  Expanded(
                    child: filtered.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.event_available_outlined,
                                  size: 48,
                                  color: AppColors.textMuted,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Không có lịch học cho ngày này',
                                  style: AppTextStyles.body1.copyWith(color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(20),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final item = filtered[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: AppCard(
                                  border: const Border(
                                    left: BorderSide(color: AppColors.secondary, width: 5),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        children: [
                                          AppBadge(
                                            text: item.timeSlot,
                                            variant: AppBadgeVariant.info,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 14),
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
                                              'Lớp: ${item.classCode}',
                                              style: AppTextStyles.body2,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Phòng học: ${item.room} • GV: ${item.teacherName}',
                                              style: AppTextStyles.body2,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
