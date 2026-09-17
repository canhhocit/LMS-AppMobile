import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/entities/attendance_entity.dart';
import '../../domain/repositories/lms_repository.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final LmsRepository _repo = getIt<LmsRepository>();

  bool _isLoading = true;
  List<StudentAttendanceSummary> _summaries = [];

  @override
  void initState() {
    super.initState();
    _loadAttendance();
  }

  Future<void> _loadAttendance() async {
    setState(() => _isLoading = true);
    try {
      final list = await _repo.getStudentAttendanceSummary();
      setState(() {
        _summaries = list;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống kê Điểm danh'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAttendance,
              child: _summaries.isEmpty
                  ? const Center(child: Text('Chưa có lịch sử điểm danh'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _summaries.length,
                      itemBuilder: (context, idx) {
                        final s = _summaries[idx];
                        final ratioPct = (s.absentRatio * 100).toStringAsFixed(1);
                        final isWarning = s.absentRatio >= 0.2;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(s.className, style: AppTextStyles.h3),
                                    ),
                                    Chip(
                                      label: Text('Nghỉ: $ratioPct%'),
                                      backgroundColor: isWarning ? Colors.red : AppColors.success,
                                      labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Text('Mã lớp: ${s.classCode}', style: AppTextStyles.body2),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildStatBox('Có mặt', '${s.presentCount}', AppColors.success),
                                    _buildStatBox('Đi muộn', '${s.lateCount}', Colors.orange),
                                    _buildStatBox('Vắng mặt', '${s.absentCount}', Colors.red),
                                  ],
                                ),
                                if (isWarning)
                                  const Padding(
                                    padding: EdgeInsets.only(top: 8),
                                    child: Text(
                                      '⚠️ Cảnh báo: Tỷ lệ vắng mặt đã vượt quá 20%! Nguy cơ bị cấm thi.',
                                      style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }

  Widget _buildStatBox(String label, String val, Color color) {
    return Column(
      children: [
        Text(val, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
