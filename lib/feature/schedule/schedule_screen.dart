import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_badge.dart';
import '../../core/widgets/app_card.dart';
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
  // View mode: 0 = Lưới Tuần (Web Grid), 1 = Danh sách Ngày (List)
  int _viewMode = 0;

  static const List<Map<String, dynamic>> days = [
    {'label': 'Thứ 2', 'value': 2, 'short': 'T2'},
    {'label': 'Thứ 3', 'value': 3, 'short': 'T3'},
    {'label': 'Thứ 4', 'value': 4, 'short': 'T4'},
    {'label': 'Thứ 5', 'value': 5, 'short': 'T5'},
    {'label': 'Thứ 6', 'value': 6, 'short': 'T6'},
    {'label': 'Thứ 7', 'value': 7, 'short': 'T7'},
    {'label': 'Chủ nhật', 'value': 8, 'short': 'CN'},
  ];

  static const List<Map<String, String>> timeSlots = [
    {'code': 'Ca 1', 'time': '07:00 - 09:15'},
    {'code': 'Ca 2', 'time': '09:30 - 11:45'},
    {'code': 'Ca 3', 'time': '13:00 - 15:15'},
    {'code': 'Ca 4', 'time': '15:30 - 17:45'},
    {'code': 'Ca 5', 'time': '18:00 - 20:15'},
  ];

  // Helper color palette for schedule blocks
  static const List<Color> _blockColors = [
    Color(0xFF2563EB), // Royal Blue
    Color(0xFF7C3AED), // Purple
    Color(0xFF059669), // Emerald
    Color(0xFFD97706), // Amber
    Color(0xFF0284C7), // Sky Blue
    Color(0xFFE11D48), // Rose
  ];

  Color _getCourseColor(String courseName) {
    final hash = courseName.hashCode.abs();
    return _blockColors[hash % _blockColors.length];
  }

  int _getSlotIndex(String slotStr) {
    final lower = slotStr.toLowerCase();
    if (lower.contains('ca 1') || lower.contains('07:') || lower.contains('08:')) return 0;
    if (lower.contains('ca 2') || lower.contains('09:') || lower.contains('10:') || lower.contains('11:')) return 1;
    if (lower.contains('ca 3') || lower.contains('13:') || lower.contains('14:')) return 2;
    if (lower.contains('ca 4') || lower.contains('15:') || lower.contains('16:') || lower.contains('17:')) return 3;
    if (lower.contains('ca 5') || lower.contains('18:') || lower.contains('19:') || lower.contains('20:')) return 4;
    return 0;
  }

  void _showItemDetails(BuildContext context, ScheduleItemEntity item) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomCtx) {
        final color = _getCourseColor(item.courseName);
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
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
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.school, color: color, size: 28),
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
                        AppBadge(text: item.classCode, variant: AppBadgeVariant.info),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),
              _buildDetailRow(Icons.access_time_filled_rounded, 'Thời gian', item.timeSlot),
              const SizedBox(height: 10),
              _buildDetailRow(Icons.calendar_month_rounded, 'Thứ / Ngày', 'Thứ ${item.dayOfWeek} ${item.date.isNotEmpty ? "(${item.date})" : ""}'),
              const SizedBox(height: 10),
              _buildDetailRow(Icons.room_rounded, 'Phòng học', item.room.isNotEmpty ? item.room : 'Chưa xếp phòng'),
              const SizedBox(height: 10),
              _buildDetailRow(Icons.person_rounded, 'Giảng viên', item.teacherName.isNotEmpty ? item.teacherName : 'Chưa phân công'),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.psychology_outlined),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Text('$label: ', style: AppTextStyles.body2.copyWith(color: AppColors.textMuted)),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ScheduleCubit(getIt())..loadSchedule(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Thời khóa biểu'),
          actions: [
            IconButton(
              icon: Icon(_viewMode == 0 ? Icons.view_agenda_rounded : Icons.grid_on_rounded),
              tooltip: _viewMode == 0 ? 'Chuyển sang Danh sách' : 'Chuyển sang Lưới Tuần (Web)',
              onPressed: () {
                setState(() {
                  _viewMode = _viewMode == 0 ? 1 : 0;
                });
              },
            ),
          ],
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
              final allSchedule = state.scheduleList;

              return Column(
                children: [
                  // View Switcher Banner
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: Colors.white,
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() => _viewMode = 0),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      decoration: BoxDecoration(
                                        color: _viewMode == 0 ? AppColors.primary : Colors.transparent,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      alignment: Alignment.center,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.grid_on_rounded,
                                            size: 16,
                                            color: _viewMode == 0 ? Colors.white : AppColors.textSecondary,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Lưới Tuần (Web)',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: _viewMode == 0 ? Colors.white : AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() => _viewMode = 1),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      decoration: BoxDecoration(
                                        color: _viewMode == 1 ? AppColors.primary : Colors.transparent,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      alignment: Alignment.center,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.view_agenda_rounded,
                                            size: 16,
                                            color: _viewMode == 1 ? Colors.white : AppColors.textSecondary,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Theo Ngày',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: _viewMode == 1 ? Colors.white : AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Mode 0: Web Timetable Grid View
                  if (_viewMode == 0)
                    Expanded(
                      child: _buildWebTimetableGrid(context, allSchedule),
                    ),

                  // Mode 1: Day List View
                  if (_viewMode == 1) ...[
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
                                final color = _getCourseColor(item.courseName);
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: GestureDetector(
                                    onTap: () => _showItemDetails(context, item),
                                    child: AppCard(
                                      border: Border(
                                        left: BorderSide(color: color, width: 5),
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
                                                  'Phòng: ${item.room} • GV: ${item.teacherName}',
                                                  style: AppTextStyles.body2,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  // Web Timetable Grid Builder (7 days x 5 slots)
  Widget _buildWebTimetableGrid(BuildContext context, List<ScheduleItemEntity> allItems) {
    // Current day of week (2..8)
    final nowDayOfWeek = DateTime.now().weekday + 1; // Mon = 2 ... Sun = 8

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Table(
            defaultColumnWidth: const FixedColumnWidth(110),
            border: TableBorder.all(
              color: Colors.grey.withOpacity(0.2),
              width: 1,
              borderRadius: BorderRadius.circular(12),
            ),
            children: [
              // Header Row: Time Column + 7 Day Headers
              TableRow(
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                ),
                children: [
                  Container(
                    height: 48,
                    alignment: Alignment.center,
                    child: Text(
                      'Ca / Thứ',
                      style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  ...days.map((d) {
                    final isToday = d['value'] == nowDayOfWeek;
                    return Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: isToday ? AppColors.primary.withOpacity(0.15) : Colors.transparent,
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            d['short'],
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isToday ? AppColors.primary : AppColors.textPrimary,
                            ),
                          ),
                          if (isToday)
                            Container(
                              margin: const EdgeInsets.only(top: 2),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Hôm nay',
                                style: TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),

              // Time Slot Rows (Ca 1 to Ca 5)
              ...List.generate(timeSlots.length, (slotIdx) {
                final slot = timeSlots[slotIdx];
                return TableRow(
                  children: [
                    // Left Column: Slot label
                    Container(
                      height: 90,
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            slot['code']!,
                            style: AppTextStyles.caption.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            slot['time']!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 9, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),

                    // 7 Day Cells for this slot
                    ...days.map((d) {
                      final dayValue = d['value'] as int;

                      // Find schedule item for (dayValue, slotIdx)
                      final matched = allItems.where((item) {
                        return item.dayOfWeek == dayValue && _getSlotIndex(item.timeSlot) == slotIdx;
                      }).toList();

                      if (matched.isEmpty) {
                        return Container(
                          height: 90,
                          color: Colors.white,
                        );
                      }

                      final item = matched.first;
                      final color = _getCourseColor(item.courseName);

                      return InkWell(
                        onTap: () => _showItemDetails(context, item),
                        child: Container(
                          height: 90,
                          margin: const EdgeInsets.all(2),
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: color.withOpacity(0.4), width: 1.2),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                item.courseName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: color,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      item.room.isNotEmpty ? item.room : 'Chưa xếp',
                                      style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.classCode,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 8, color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
