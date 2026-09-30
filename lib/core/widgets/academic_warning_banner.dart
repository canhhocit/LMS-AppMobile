import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AcademicWarningBanner extends StatefulWidget {
  final String? studentName;
  final String? studentCode;
  final int debtCredits;
  final int maxAllowedCredits;
  final double? gpa;
  final VoidCallback? onRegisterRemediation;
  final VoidCallback? onAskAiAdvisor;

  const AcademicWarningBanner({
    super.key,
    this.studentName,
    this.studentCode,
    this.debtCredits = 0,
    this.maxAllowedCredits = 10,
    this.gpa,
    this.onRegisterRemediation,
    this.onAskAiAdvisor,
  });

  @override
  State<AcademicWarningBanner> createState() => _AcademicWarningBannerState();
}

class _AcademicWarningBannerState extends State<AcademicWarningBanner> {
  bool _dismissed = false;
  bool _showDetails = false;

  @override
  Widget build(BuildContext context) {
    final isLowGpa = widget.gpa != null && widget.gpa! < 2.0;
    final isOverDebt = widget.debtCredits > widget.maxAllowedCredits;

    if (_dismissed || (!isLowGpa && !isOverDebt && widget.debtCredits == 0)) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red.shade700,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'CẢNH BÁO HỌC VỤ',
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (widget.studentCode != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            'MSV: ${widget.studentCode}',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.red.shade900),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isOverDebt
                          ? 'Cảnh báo tự động: Tín chỉ nợ (${widget.debtCredits}/${widget.maxAllowedCredits} tín chỉ) vượt ngưỡng quy định'
                          : 'Cảnh báo học tập: GPA (${widget.gpa?.toStringAsFixed(2) ?? "-"}) dưới ngưỡng an toàn (< 2.0/4.0)',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.studentName != null ? "${widget.studentName}, " : ""}hệ thống ghi nhận nguy cơ rủi ro học tập. Vui lòng lập kế hoạch học bù và tư vấn với Giảng viên chủ nhiệm hoặc Cố vấn AI.',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade800, height: 1.3),
                    ),
                  ],
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                onPressed: () => setState(() => _dismissed = true),
              ),
            ],
          ),

          if (_showDetails) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.shield_outlined, color: Colors.red, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Quy trình Khắc phục Cảnh báo Học vụ:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.red),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text('• Đăng ký cải thiện/học lại các môn điểm F/D trong đợt mở đăng ký.', style: TextStyle(fontSize: 11, height: 1.3)),
                  const Text('• Liên hệ Giáo viên Chủ nhiệm (GVCN) để định hướng lại khối lượng học tập.', style: TextStyle(fontSize: 11, height: 1.3)),
                  Text('• Nếu không cải thiện ở kỳ kế tiếp, sinh viên đối mặt với Cảnh báo Học vụ Lần 2 (Buộc thôi học).', style: TextStyle(fontSize: 11, color: Colors.red.shade800, fontWeight: FontWeight.bold, height: 1.3)),
                ],
              ),
            ),
          ],

          const SizedBox(height: 10),
          Row(
            children: [
              TextButton.icon(
                onPressed: () => setState(() => _showDetails = !_showDetails),
                icon: Icon(_showDetails ? Icons.expand_less : Icons.expand_more, size: 16, color: Colors.red.shade700),
                label: Text(
                  _showDetails ? 'Thu gọn' : 'Xem hướng dẫn',
                  style: TextStyle(fontSize: 11, color: Colors.red.shade700, fontWeight: FontWeight.bold),
                ),
                style: TextButton.styleFrom(padding: EdgeInsets.zero, visualDensity: VisualDensity.compact),
              ),
              const Spacer(),
              if (widget.onAskAiAdvisor != null) ...[
                OutlinedButton.icon(
                  onPressed: widget.onAskAiAdvisor,
                  icon: const Icon(Icons.psychology, size: 14),
                  label: const Text('Hỏi AI Cố vấn'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    visualDensity: VisualDensity.compact,
                    textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              if (widget.onRegisterRemediation != null)
                ElevatedButton.icon(
                  onPressed: widget.onRegisterRemediation,
                  icon: const Icon(Icons.arrow_forward, size: 14),
                  label: const Text('Học bù ngay'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    visualDensity: VisualDensity.compact,
                    textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
