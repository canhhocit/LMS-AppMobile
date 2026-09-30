import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_badge.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../core/widgets/app_skeleton.dart';
import '../../domain/entities/registration_entity.dart';
import '../../domain/repositories/lms_repository.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final LmsRepository _repo = getIt<LmsRepository>();

  bool _isLoading = true;
  RegistrationPeriodEntity? _period;
  List<AvailableClassEntity> _classes = [];
  String _searchKeyword = '';

  @override
  void initState() {
    super.initState();
    _loadRegistrationData();
  }

  Future<void> _loadRegistrationData() async {
    setState(() => _isLoading = true);
    try {
      final period = await _repo.getActiveRegistrationPeriod();
      final list = await _repo.getAvailableClasses();
      setState(() {
        _period = period;
        _classes = list;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _classes.where((c) {
      if (_searchKeyword.isEmpty) return true;
      return c.className.toLowerCase().contains(_searchKeyword.toLowerCase()) ||
          c.courseTitle.toLowerCase().contains(_searchKeyword.toLowerCase()) ||
          c.courseCode.toLowerCase().contains(_searchKeyword.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng ký học phần'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const AppSkeleton.rectangular(height: 90),
                  const SizedBox(height: 16),
                  const AppSkeleton.rectangular(height: 48),
                  const SizedBox(height: 16),
                  AppSkeleton.listLoader(count: 3, height: 100),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadRegistrationData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Period Status Banner
                  if (_period != null && _period!.isActive) ...[
                    AppCard(
                      backgroundColor: AppColors.primaryBackground,
                      border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.event_available_rounded, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _period!.name,
                                  style: AppTextStyles.h3.copyWith(color: AppColors.primary, fontSize: 16),
                                ),
                              ),
                              const AppBadge(text: 'Đang mở', variant: AppBadgeVariant.success),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Học kỳ: ${_period!.semester} (${_period!.academicYear})', style: AppTextStyles.body2),
                          Text('Hạn đăng ký: ${_period!.closeAt}', style: AppTextStyles.body2),
                          Text('Giới hạn tối đa: ${_period!.maxCredits} tín chỉ', style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ] else ...[
                    const AppCard(
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          'Hiện tại chưa có đợt đăng ký học phần nào đang mở.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),

                  // Search Field
                  TextField(
                    onChanged: (val) => setState(() => _searchKeyword = val),
                    decoration: InputDecoration(
                      hintText: 'Tìm theo tên môn, mã học phần...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Danh sách lớp học phần mở', style: AppTextStyles.h3),
                      Text('${filtered.length} lớp', style: AppTextStyles.body2),
                    ],
                  ),
                  const SizedBox(height: 10),

                  filtered.isEmpty
                      ? const AppEmptyState(
                          title: 'Không tìm thấy lớp học phần phù hợp',
                          subtitle: 'Thử tìm kiếm với từ khóa khác hoặc kiểm tra lại đợt đăng ký.',
                          icon: Icons.find_in_page_outlined,
                        )
                      : Column(
                          children: filtered.map((item) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: AppCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '${item.courseTitle} (${item.courseCode})',
                                            style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold, fontSize: 15),
                                          ),
                                        ),
                                        AppBadge(
                                          text: '${item.credit} TC',
                                          variant: AppBadgeVariant.primary,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Mã lớp: ${item.classCode} • GV: ${item.lecturerName ?? "Đang cập nhật"}',
                                      style: AppTextStyles.body2,
                                    ),
                                    Text(
                                      'Sĩ số hiện tại: ${item.currentEnrolled}/${item.maxStudents}',
                                      style: AppTextStyles.body2,
                                    ),
                                    const Divider(height: 20),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: ElevatedButton.icon(
                                        onPressed: () async {
                                          if (item.isRegistered) {
                                            await _repo.cancelCourseRegistration(item.id);
                                            if (mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('Đã hủy đăng ký môn học!'), backgroundColor: AppColors.info),
                                              );
                                            }
                                          } else {
                                            await _repo.registerCourseClass(item.id);
                                            if (mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('Đăng ký môn học thành công!'), backgroundColor: AppColors.success),
                                              );
                                            }
                                          }
                                          _loadRegistrationData();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: item.isRegistered ? AppColors.error : AppColors.primary,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                        icon: Icon(item.isRegistered ? Icons.cancel_outlined : Icons.add_circle_outline_rounded, size: 18),
                                        label: Text(item.isRegistered ? 'Hủy đăng ký' : 'Đăng ký học'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                ],
              ),
            ),
    );
  }
}
