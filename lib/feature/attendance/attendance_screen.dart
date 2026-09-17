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

  void _showQrCheckInDialog() {
    final otpController = TextEditingController();
    int? selectedClassId = _summaries.isNotEmpty ? _summaries.first.classId : null;
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.qr_code_scanner, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Check-in QR / OTP'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Chọn lớp học:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              DropdownButtonFormField<int>(
                value: selectedClassId,
                items: _summaries.map((s) => DropdownMenuItem<int>(
                  value: s.classId,
                  child: Text('${s.classCode} - ${s.className}', overflow: TextOverflow.ellipsis),
                )).toList(),
                onChanged: (val) => setDialogState(() => selectedClassId = val),
                decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
              ),
              const SizedBox(height: 16),
              const Text('Nhập mã OTP (6 chữ số) từ Giảng viên:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, letterSpacing: 8, fontWeight: FontWeight.bold, color: AppColors.primary),
                decoration: const InputDecoration(
                  hintText: '123456',
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy'),
            ),
            ElevatedButton.icon(
              icon: isSubmitting ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.check_circle),
              label: Text(isSubmitting ? 'Đang gửi...' : 'Xác nhận Điểm danh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: isSubmitting || selectedClassId == null
                  ? null
                  : () async {
                      final otp = otpController.text.trim();
                      if (otp.length < 6) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Vui lòng nhập đủ 6 chữ số OTP!'), backgroundColor: Colors.orange),
                        );
                        return;
                      }
                      setDialogState(() => isSubmitting = true);
                      final ok = await _repo.submitQrAttendance(selectedClassId!, otp);
                      if (mounted) {
                        Navigator.pop(ctx);
                        if (ok) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('✅ Điểm danh QR thành công!'), backgroundColor: AppColors.success),
                          );
                          _loadAttendance();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('❌ Mã OTP không hợp lệ hoặc đã hết hạn!'), backgroundColor: Colors.red),
                          );
                        }
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống kê Điểm danh'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showQrCheckInDialog,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
        label: const Text('Quét QR Check-in', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
