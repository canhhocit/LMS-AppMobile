import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_badge.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../core/widgets/app_skeleton.dart';
import '../../domain/entities/attendance_entity.dart';
import '../../domain/repositories/lms_repository.dart';
import 'qr_scanner_dialog.dart';

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
              Icon(Icons.qr_code_scanner_rounded, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Điểm danh QR / OTP', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Attendance session payload:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 6),
                DropdownButtonFormField<int>(
                  value: selectedClassId,
                  items: _summaries.map((s) => DropdownMenuItem<int>(
                    value: s.classId,
                    child: Text('${s.classCode} - ${s.className}', overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13)),
                  )).toList(),
                  onChanged: (val) => setDialogState(() => selectedClassId = val),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () async {
                    final scannedOtp = await showDialog<String>(
                      context: context,
                      builder: (_) => const QrScannerDialog(),
                    );
                    if (scannedOtp != null && scannedOtp.isNotEmpty) {
                      otpController.text = scannedOtp;
                      setDialogState(() {});
                    }
                  },
                  icon: const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
                  label: const Text('Scan the attendance QR code'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Attendance session payload:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 6),
                TextField(
                  controller: otpController,
                  keyboardType: TextInputType.text,
                  maxLength: 100,
                  readOnly: true,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22, letterSpacing: 8, fontWeight: FontWeight.bold, color: AppColors.primary),
                  decoration: const InputDecoration(
                    hintText: '123456',
                    border: OutlineInputBorder(),
                    counterText: '',
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy'),
            ),
            ElevatedButton.icon(
              icon: isSubmitting
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.check_circle_rounded, size: 18),
              label: Text(isSubmitting ? 'Đang gửi...' : 'Xác nhận Điểm danh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: isSubmitting || selectedClassId == null
                  ? null
                  : () async {
                      final otp = otpController.text.trim();
                      if (!otp.startsWith('LEARNINGHUB_QR|')) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Vui lòng nhập đủ 6 chữ số OTP!'), backgroundColor: AppColors.warning),
                        );
                        return;
                      }
                      setDialogState(() => isSubmitting = true);
                      final ok = await _repo.submitQrAttendance(selectedClassId!, otp);
                      if (mounted) {
                        Navigator.pop(ctx);
                        if (ok) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Điểm danh QR thành công!'), backgroundColor: AppColors.success),
                          );
                          _loadAttendance();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Mã OTP không hợp lệ hoặc đã hết hạn!'), backgroundColor: AppColors.error),
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
        title: const Text('Thống kê điểm danh'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showQrCheckInDialog,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white),
        label: const Text('Quét QR Check-in', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? AppSkeleton.listLoader(count: 3, height: 140)
          : RefreshIndicator(
              onRefresh: _loadAttendance,
              child: _summaries.isEmpty
                  ? const AppEmptyState(
                      title: 'Chưa có dữ liệu điểm danh',
                      subtitle: 'Lịch sử điểm danh các môn học sẽ được thống kê tại đây.',
                      icon: Icons.fact_check_outlined,
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _summaries.length,
                      itemBuilder: (context, idx) {
                        final s = _summaries[idx];
                        final ratioPct = (s.absentRatio * 100).toStringAsFixed(1);
                        final isWarning = s.absentRatio >= 0.2;
                        final totalLessons = s.presentCount + s.lateCount + s.absentCount;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: AppCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(s.className, style: AppTextStyles.h3.copyWith(fontSize: 16)),
                                    ),
                                    AppBadge(
                                      text: 'Vắng: $ratioPct%',
                                      variant: isWarning ? AppBadgeVariant.error : AppBadgeVariant.success,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text('Mã lớp: ${s.classCode}', style: AppTextStyles.body2),
                                const SizedBox(height: 16),
                                // Attendance Progress Bar
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: totalLessons > 0 ? (s.presentCount + s.lateCount) / totalLessons : 1.0,
                                    backgroundColor: AppColors.error.withOpacity(0.2),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      isWarning ? AppColors.warning : AppColors.success,
                                    ),
                                    minHeight: 8,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildStatBox('Có mặt', '${s.presentCount}', AppColors.success),
                                    _buildStatBox('Đi muộn', '${s.lateCount}', AppColors.warning),
                                    _buildStatBox('Vắng mặt', '${s.absentCount}', AppColors.error),
                                  ],
                                ),
                                if (isWarning) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppColors.badgeRedBg,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: const [
                                        Icon(Icons.warning_amber_rounded, color: AppColors.badgeRedText, size: 18),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Cảnh báo: Tỷ lệ vắng mặt vượt quá 20%. Bạn có nguy cơ không được tham dự thi kết thúc học phần!',
                                            style: TextStyle(color: AppColors.badgeRedText, fontSize: 11, fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
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
        Text(val, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}
