import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
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
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadRegistrationData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Period Banner
                  if (_period != null && _period!.isActive) ...[
                    Card(
                      color: AppColors.primaryLight,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.event_available, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(_period!.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('Học kỳ: ${_period!.semester} (${_period!.academicYear})'),
                            Text('Hạn đăng ký: ${_period!.closeAt}'),
                            Text('Giới hạn: ${_period!.maxCredits} tín chỉ max'),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Hiện tại chưa có Đợt đăng ký học phần nào đang mở.'),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),

                  TextField(
                    onChanged: (val) => setState(() => _searchKeyword = val),
                    decoration: InputDecoration(
                      hintText: 'Tìm theo môn học, mã môn...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text('Danh sách lớp mở (${filtered.length})', style: AppTextStyles.h3),
                  const SizedBox(height: 8),

                  ...filtered.map((item) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        title: Text('${item.courseTitle} (${item.courseCode})', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Mã lớp: ${item.classCode} • Số tín chỉ: ${item.credit}'),
                            Text('GV: ${item.lecturerName ?? "Đang cập nhật"} • Sĩ số: ${item.currentEnrolled}/${item.maxStudents}'),
                          ],
                        ),
                        trailing: ElevatedButton(
                          onPressed: () async {
                            if (item.isRegistered) {
                              await _repo.cancelCourseRegistration(item.id);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã hủy đăng ký môn!')));
                            } else {
                              await _repo.registerCourseClass(item.id);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đăng ký môn học thành công!')));
                            }
                            _loadRegistrationData();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: item.isRegistered ? Colors.red : AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(item.isRegistered ? 'Hủy đăng ký' : 'Đăng ký'),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
    );
  }
}
