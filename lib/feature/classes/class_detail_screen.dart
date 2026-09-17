import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_badge.dart';
import '../../core/widgets/app_card.dart';
import '../../domain/entities/class_entity.dart';

class ClassDetailScreen extends StatelessWidget {
  final CourseClassEntity courseClass;

  const ClassDetailScreen({super.key, required this.courseClass});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(courseClass.courseName),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Class Overview Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppBadge(
                    text: courseClass.classCode,
                    variant: AppBadgeVariant.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    courseClass.courseName,
                    style: AppTextStyles.h2.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Học kỳ: ${courseClass.semester}',
                    style: AppTextStyles.body2.copyWith(color: Colors.white.withOpacity(0.85)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Class Information Details
            Text('Thông tin chi tiết', style: AppTextStyles.h3),
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                children: [
                  _buildDetailItem(
                    icon: Icons.person_outline,
                    label: 'Giảng viên phụ trách',
                    value: courseClass.teacherName,
                  ),
                  const Divider(height: 24),
                  _buildDetailItem(
                    icon: Icons.meeting_room_outlined,
                    label: 'Phòng học',
                    value: courseClass.room,
                  ),
                  const Divider(height: 24),
                  _buildDetailItem(
                    icon: Icons.access_time_rounded,
                    label: 'Lịch học hàng tuần',
                    value: courseClass.scheduleText,
                  ),
                  const Divider(height: 24),
                  _buildDetailItem(
                    icon: Icons.group_outlined,
                    label: 'Sĩ số sinh viên',
                    value: '${courseClass.studentCount} sinh viên',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Announcement Tab preview
            Text('Thông báo từ lớp học', style: AppTextStyles.h3),
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.campaign, color: AppColors.warning, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Thông báo nộp bài tập lớn',
                        style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Sinh viên nộp báo cáo đồ án đúng hạn trước 23:59 ngày chủ nhật tuần này.',
                    style: AppTextStyles.body2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.caption),
              const SizedBox(height: 2),
              Text(value, style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}
