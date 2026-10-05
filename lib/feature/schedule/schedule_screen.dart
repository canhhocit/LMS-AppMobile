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
import '../../domain/entities/schedule_entity.dart';
import '../ai_advisor/ai_advisor_screen.dart';
import 'schedule_cubit.dart';
import 'schedule_state.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  static const List<Map<String, dynamic>> _days = [
    {'label': 'Thứ 2', 'value': 2, 'short': 'T2'},
    {'label': 'Thứ 3', 'value': 3, 'short': 'T3'},
    {'label': 'Thứ 4', 'value': 4, 'short': 'T4'},
    {'label': 'Thứ 5', 'value': 5, 'short': 'T5'},
    {'label': 'Thứ 6', 'value': 6, 'short': 'T6'},
    {'label': 'Thứ 7', 'value': 7, 'short': 'T7'},
    {'label': 'Chủ nhật', 'value': 8, 'short': 'CN'},
  ];

  int _getTodayDayOfWeek() {
    final weekday = DateTime.now().weekday; // 1 = Mon ... 7 = Sun
    return weekday == 7 ? 8 : weekday + 1; // Map to 2..8
  }

  void _showItemDetails(BuildContext context, ScheduleItemEntity item) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomCtx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBgColor(context),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.school_outlined, color: AppColors.primary, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.courseName,
                          style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        AppBadge(text: item.classCode, variant: AppBadgeVariant.primary),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),
              _buildDetailRow(Icons.access_time_filled_rounded, 'Thời gian', item.timeSlot),
              const SizedBox(height: 12),
              _buildDetailRow(Icons.calendar_month_rounded, 'Thứ / Ngày', 'Thứ ${item.dayOfWeek} ${item.date.isNotEmpty ? "(${item.date})" : ""}'),
              const SizedBox(height: 12),
              _buildDetailRow(Icons.meeting_room_rounded, 'Phòng học', item.room.isNotEmpty ? item.room : 'Chưa xếp phòng'),
              const SizedBox(height: 12),
              _buildDetailRow(Icons.person_rounded, 'Giảng viên', item.teacherName.isNotEmpty ? item.teacherName : 'Chưa phân công'),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.assistant_outlined, size: 18),
                      label: const Text('Hỏi AI môn này'),
                      onPressed: () {
                        Navigator.pop(bottomCtx);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AiAdvisorScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => Navigator.pop(bottomCtx),
                      child: const Text('Đóng', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Text('$label: ', style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary)),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final todayVal = _getTodayDayOfWeek();

    return BlocProvider(
      create: (_) => ScheduleCubit(getIt())..loadSchedule(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Lịch học / Lịch dạy'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: BlocBuilder<ScheduleCubit, ScheduleState>(
          builder: (context, state) {
            if (state is ScheduleLoading) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const AppSkeleton.rectangular(height: 50),
                    const SizedBox(height: 20),
                    AppSkeleton.listLoader(count: 4, height: 90),
                  ],
                ),
              );
            }
            if (state is ScheduleError) {
              return AppErrorState(
                message: state.message,
                onRetry: () => context.read<ScheduleCubit>().loadSchedule(),
              );
            }
            if (state is ScheduleLoaded) {
              final selectedDay = state.selectedDayOfWeek;
              final filtered = state.filteredSchedule;

              return Column(
                children: [
                  // Horizontal Day Bar Selector
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _days.map((day) {
                          final isSelected = day['value'] == selectedDay;
                          final isToday = day['value'] == todayVal;

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: InkWell(
                              onTap: () {
                                context.read<ScheduleCubit>().selectDay(day['value'] as int);
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.primary : (isToday ? AppColors.primaryBackground : Colors.grey.shade100),
                                  borderRadius: BorderRadius.circular(12),
                                  border: isToday && !isSelected ? Border.all(color: AppColors.primary, width: 1.5) : null,
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      day['short'] as String,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected ? Colors.white : (isToday ? AppColors.primary : AppColors.textPrimary),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      day['label'] as String,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isSelected ? Colors.white70 : (isToday ? AppColors.primary : AppColors.textMuted),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const Divider(height: 1),

                  // Schedule List View
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () => context.read<ScheduleCubit>().loadSchedule(),
                      child: filtered.isEmpty
                          ? const AppEmptyState(
                              title: 'Không có lịch học trong ngày',
                              subtitle: 'Hãy chọn ngày khác trên thanh công cụ để xem thời khóa biểu.',
                              icon: Icons.event_available_outlined,
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final item = filtered[index];

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: AppCard(
                                    onTap: () => _showItemDetails(context, item),
                                    border: const Border(
                                      left: BorderSide(color: AppColors.primary, width: 4),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Left Time Column
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            AppBadge(
                                              text: item.timeSlot,
                                              variant: AppBadgeVariant.primary,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 14),
                                        // Main Course info
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.courseName,
                                                style: AppTextStyles.body1.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  const Icon(Icons.meeting_room_outlined, size: 15, color: AppColors.textSecondary),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    'Phòng: ${item.room.isNotEmpty ? item.room : "Chưa xếp"}',
                                                    style: AppTextStyles.body2,
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 2),
                                              Row(
                                                children: [
                                                  const Icon(Icons.person_outline_rounded, size: 15, color: AppColors.textSecondary),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      'GV: ${item.teacherName.isNotEmpty ? item.teacherName : "Chưa cập nhật"}',
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
                                        const Icon(
                                          Icons.chevron_right_rounded,
                                          color: AppColors.textMuted,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
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
