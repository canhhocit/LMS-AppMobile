import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/entities/chapter_lesson_entity.dart';
import '../../domain/entities/assignment_entity.dart';
import '../../domain/entities/quiz_entity.dart';
import '../../domain/entities/forum_entity.dart';
import '../../domain/entities/attendance_entity.dart';
import '../../domain/entities/class_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/lms_repository.dart';

class ClassDetailScreen extends StatefulWidget {
  final CourseClassEntity courseClass;
  final UserEntity currentUser;

  const ClassDetailScreen({
    super.key,
    required this.courseClass,
    required this.currentUser,
  });

  @override
  State<ClassDetailScreen> createState() => _ClassDetailScreenState();
}

class _ClassDetailScreenState extends State<ClassDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final LmsRepository _repo = getIt<LmsRepository>();

  bool _isLoading = true;
  List<ChapterEntity> _chapters = [];
  List<AssignmentEntity> _assignments = [];
  List<QuizEntity> _quizzes = [];
  List<ForumPostEntity> _forumPosts = [];
  List<AttendanceEntity> _attendanceRecords = [];
  List<Map<String, dynamic>> _gradebookRecords = [];

  // Active video lesson
  LessonEntity? _activeLesson;

  @override
  void initState() {
    super.initState();
    final tabCount = widget.currentUser.isLecturer ? 6 : 5;
    _tabController = TabController(length: tabCount, vsync: this);
    _loadAllClassData();
  }

  Future<void> _loadAllClassData() async {
    setState(() => _isLoading = true);
    try {
      final classId = widget.courseClass.id;
      final results = await Future.wait([
        _repo.getClassChapters(classId),
        _repo.getClassAssignments(classId),
        _repo.getClassQuizzes(classId),
        _repo.getClassForumPosts(classId),
        _repo.getClassAttendance(classId),
        widget.currentUser.isLecturer ? _repo.getClassGradebook(classId) : Future.value(<Map<String, dynamic>>[]),
      ]);

      setState(() {
        _chapters = results[0] as List<ChapterEntity>;
        _assignments = results[1] as List<AssignmentEntity>;
        _quizzes = results[2] as List<QuizEntity>;
        _forumPosts = results[3] as List<ForumPostEntity>;
        _attendanceRecords = results[4] as List<AttendanceEntity>;
        _gradebookRecords = results[5] as List<Map<String, dynamic>>;

        if (_chapters.isNotEmpty && _chapters.first.lessons.isNotEmpty) {
          _activeLesson = _chapters.first.lessons.first;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLecturer = widget.currentUser.isLecturer;
    final tabs = [
      const Tab(text: 'Bài giảng'),
      const Tab(text: 'Bài tập'),
      const Tab(text: 'Kiểm tra'),
      const Tab(text: 'Diễn đàn'),
      const Tab(text: 'Điểm danh'),
      if (isLecturer) const Tab(text: 'Sổ điểm'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.courseClass.courseTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('${widget.courseClass.classCode} • GV: ${widget.courseClass.lecturerName ?? "Phân công sau"}', style: const TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        backgroundColor: AppColors.primary,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: tabs,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildLessonsTab(),
                _buildAssignmentsTab(),
                _buildQuizzesTab(),
                _buildForumTab(),
                _buildAttendanceTab(),
                if (isLecturer) _buildGradebookTab(),
              ],
            ),
    );
  }

  // --- TAB 1: BÀI GIẢNG & VIDEO ---
  Widget _buildLessonsTab() {
    if (_chapters.isEmpty) {
      return const Center(child: Text('Chưa có chương học nào'));
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Active Video Header
          if (_activeLesson != null) ...[
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.play_circle_fill, size: 64, color: AppColors.primary),
                  Positioned(
                    bottom: 12,
                    left: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(6)),
                      child: Text(
                        _activeLesson!.title,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(_activeLesson!.title, style: AppTextStyles.h3)),
                        IconButton(
                          icon: Icon(
                            _activeLesson!.isCompleted ? Icons.check_circle : Icons.check_circle_outline,
                            color: _activeLesson!.isCompleted ? AppColors.success : Colors.grey,
                          ),
                          onPressed: () async {
                            final nextVal = !_activeLesson!.isCompleted;
                            await _repo.markLessonProgress(_activeLesson!.id, nextVal);
                            _loadAllClassData();
                          },
                        ),
                      ],
                    ),
                    if (_activeLesson!.content != null && _activeLesson!.content!.isNotEmpty) ...[
                      const Divider(),
                      Text(_activeLesson!.content!, style: AppTextStyles.body2),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          Text('Danh sách chương học', style: AppTextStyles.h3),
          const SizedBox(height: 8),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _chapters.length,
            itemBuilder: (context, chapterIdx) {
              final chapter = _chapters[chapterIdx];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ExpansionTile(
                  initiallyExpanded: chapterIdx == 0,
                  title: Text(chapter.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${chapter.lessons.length} bài học', style: const TextStyle(fontSize: 12)),
                  children: chapter.lessons.map((lesson) {
                    final isSelected = _activeLesson?.id == lesson.id;
                    return ListTile(
                      selected: isSelected,
                      selectedTileColor: AppColors.primaryLight,
                      leading: Icon(
                        lesson.videoUrl != null ? Icons.play_lesson : Icons.article_outlined,
                        color: lesson.isCompleted ? AppColors.success : AppColors.primary,
                      ),
                      title: Text(lesson.title, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                      subtitle: Text('${lesson.duration} phút'),
                      trailing: Icon(
                        lesson.isCompleted ? Icons.check_circle : Icons.circle_outlined,
                        color: lesson.isCompleted ? AppColors.success : Colors.grey,
                        size: 20,
                      ),
                      onTap: () {
                        setState(() {
                          _activeLesson = lesson;
                        });
                      },
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // --- TAB 2: BÀI TẬP ---
  Widget _buildAssignmentsTab() {
    final isLecturer = widget.currentUser.isLecturer;
    return Scaffold(
      floatingActionButton: isLecturer
          ? FloatingActionButton.extended(
              onPressed: _showCreateAssignmentModal,
              label: const Text('Tạo bài tập'),
              icon: const Icon(Icons.add),
              backgroundColor: AppColors.primary,
            )
          : null,
      body: _assignments.isEmpty
          ? const Center(child: Text('Chưa có bài tập nào'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _assignments.length,
              itemBuilder: (context, idx) {
                final assign = _assignments[idx];
                final sub = assign.mySubmission;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(assign.title, style: AppTextStyles.h3),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Thang điểm: ${assign.maxScore}',
                                style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        if (assign.description != null) ...[
                          const SizedBox(height: 6),
                          Text(assign.description!, style: AppTextStyles.body2),
                        ],
                        const SizedBox(height: 8),
                        Text('Hạn nộp: ${assign.dueDate}', style: TextStyle(fontSize: 12, color: Colors.red[700], fontWeight: FontWeight.w600)),
                        const Divider(),
                        if (!isLecturer) ...[
                          if (sub != null) ...[
                            Row(
                              children: [
                                const Icon(Icons.check_circle, color: AppColors.success, size: 18),
                                const SizedBox(width: 6),
                                Expanded(child: Text('Đã nộp: ${sub.fileUrl}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                                if (sub.score != null)
                                  Chip(
                                    label: Text('Điểm: ${sub.score}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                    backgroundColor: AppColors.success,
                                  )
                              ],
                            ),
                            if (sub.feedback != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text('Nhận xét: ${sub.feedback}', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                              ),
                          ] else ...[
                            ElevatedButton.icon(
                              onPressed: () => _showSubmitAssignmentModal(assign),
                              icon: const Icon(Icons.upload_file, size: 18),
                              label: const Text('Nộp bài tập'),
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                            ),
                          ],
                        ] else ...[
                          ElevatedButton.icon(
                            onPressed: () => _viewSubmissionsForLecturer(assign),
                            icon: const Icon(Icons.rate_review, size: 18),
                            label: const Text('Xem & Chấm điểm bài nộp'),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showSubmitAssignmentModal(AssignmentEntity assign) {
    final controller = TextEditingController(text: 'https://github.com/myrepo/submission.pdf');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Nộp bài tập: ${assign.title}'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Đường dẫn File / Báo cáo (URL)', hintText: 'https://...'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                await _repo.submitAssignment(assign.id, controller.text.trim());
                Navigator.pop(ctx);
                _loadAllClassData();
              }
            },
            child: const Text('Gửi bài'),
          ),
        ],
      ),
    );
  }

  void _showCreateAssignmentModal() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final dateCtrl = TextEditingController(text: '2026-10-01 23:59');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tạo bài tập mới'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Tên bài tập')),
            TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Mô tả bài tập')),
            TextField(controller: dateCtrl, decoration: const InputDecoration(labelText: 'Hạn nộp (YYYY-MM-DD HH:mm)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              if (titleCtrl.text.trim().isNotEmpty) {
                await _repo.createAssignment(
                  widget.courseClass.id,
                  titleCtrl.text.trim(),
                  descCtrl.text.trim(),
                  dateCtrl.text.trim(),
                  10.0,
                );
                Navigator.pop(ctx);
                _loadAllClassData();
              }
            },
            child: const Text('Tạo mới'),
          ),
        ],
      ),
    );
  }

  void _viewSubmissionsForLecturer(AssignmentEntity assign) async {
    final subs = await _repo.getAssignmentSubmissions(assign.id);
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Bài nộp: ${assign.title}', style: AppTextStyles.h3),
              const Divider(),
              Expanded(
                child: subs.isEmpty
                    ? const Center(child: Text('Chưa có sinh viên nào nộp bài'))
                    : ListView.builder(
                        itemCount: subs.length,
                        itemBuilder: (c, i) {
                          final s = subs[i];
                          final scoreCtrl = TextEditingController(text: s.score?.toString() ?? '');
                          final fbCtrl = TextEditingController(text: s.feedback ?? '');
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${s.studentName ?? "SV"} (${s.studentCode ?? "N/A"})', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text('File: ${s.fileUrl}', style: const TextStyle(color: Colors.blue, fontSize: 12)),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: scoreCtrl,
                                          keyboardType: TextInputType.number,
                                          decoration: const InputDecoration(labelText: 'Điểm số (0-10)'),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        flex: 2,
                                        child: TextField(
                                          controller: fbCtrl,
                                          decoration: const InputDecoration(labelText: 'Nhận xét'),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.save, color: AppColors.primary),
                                        onPressed: () async {
                                          final val = double.tryParse(scoreCtrl.text);
                                          if (val != null) {
                                            await _repo.gradeSubmission(s.id, val, fbCtrl.text);
                                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã lưu điểm!')));
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- TAB 3: QUIZZES ---
  Widget _buildQuizzesTab() {
    if (_quizzes.isEmpty) {
      return const Center(child: Text('Chưa có bài trắc nghiệm nào'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _quizzes.length,
      itemBuilder: (context, idx) {
        final quiz = _quizzes[idx];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: AppColors.primaryLight,
              child: Icon(Icons.quiz, color: AppColors.primary),
            ),
            title: Text(quiz.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Thời gian: ${quiz.durationMinutes} phút • Tổng điểm: ${quiz.totalScore}'),
            trailing: quiz.latestAttempt != null
                ? Chip(
                    label: Text('Điểm: ${quiz.latestAttempt!.score}'),
                    backgroundColor: AppColors.success,
                    labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  )
                : ElevatedButton(
                    onPressed: () => _startQuizAttempt(quiz),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                    child: const Text('Làm bài'),
                  ),
          ),
        );
      },
    );
  }

  void _startQuizAttempt(QuizEntity quiz) async {
    final questions = await _repo.getQuizQuestions(quiz.id);
    if (!mounted) return;
    if (questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bài quiz chưa có câu hỏi nào')));
      return;
    }

    final Map<int, String> userAnswers = {};
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setQuizState) => AlertDialog(
          title: Text('Kiểm tra: ${quiz.title} (${quiz.durationMinutes} phút)'),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: ListView.builder(
              itemCount: questions.length,
              itemBuilder: (c, i) {
                final q = questions[i];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Câu ${i + 1}: ${q.questionText}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    RadioListTile<String>(
                      title: Text('A. ${q.optionA}'),
                      value: 'A',
                      groupValue: userAnswers[q.id],
                      onChanged: (val) => setQuizState(() => userAnswers[q.id] = val!),
                    ),
                    RadioListTile<String>(
                      title: Text('B. ${q.optionB}'),
                      value: 'B',
                      groupValue: userAnswers[q.id],
                      onChanged: (val) => setQuizState(() => userAnswers[q.id] = val!),
                    ),
                    RadioListTile<String>(
                      title: Text('C. ${q.optionC}'),
                      value: 'C',
                      groupValue: userAnswers[q.id],
                      onChanged: (val) => setQuizState(() => userAnswers[q.id] = val!),
                    ),
                    RadioListTile<String>(
                      title: Text('D. ${q.optionD}'),
                      value: 'D',
                      groupValue: userAnswers[q.id],
                      onChanged: (val) => setQuizState(() => userAnswers[q.id] = val!),
                    ),
                    const Divider(),
                  ],
                );
              },
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                final attempt = await _repo.submitQuizAttempt(quiz.id, userAnswers);
                Navigator.pop(ctx);
                _loadAllClassData();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Nộp bài thành công! Số điểm đạt được: ${attempt.score}')));
              },
              child: const Text('Nộp bài kiểm tra'),
            ),
          ],
        ),
      ),
    );
  }

  // --- TAB 4: DIỄN ĐÀN (FORUM) ---
  Widget _buildForumTab() {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreatePostModal,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.create),
      ),
      body: _forumPosts.isEmpty
          ? const Center(child: Text('Chưa có bài thảo luận nào'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _forumPosts.length,
              itemBuilder: (context, idx) {
                final post = _forumPosts[idx];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(child: Text(post.authorName.isNotEmpty ? post.authorName[0] : 'U')),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(post.authorName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text(post.createdAt, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(post.title, style: AppTextStyles.h3),
                        const SizedBox(height: 4),
                        Text(post.content, style: AppTextStyles.body2),
                        const Divider(),
                        Text('Bình luận (${post.comments.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ...post.comments.map((c) => Padding(
                          padding: const EdgeInsets.only(left: 16, top: 6),
                          child: Text('${c.authorName}: ${c.content}', style: const TextStyle(fontSize: 12)),
                        )),
                        TextButton.icon(
                          onPressed: () => _showAddCommentModal(post),
                          icon: const Icon(Icons.reply, size: 16),
                          label: const Text('Bình luận'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showCreatePostModal() {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tạo bài thảo luận'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Tiêu đề')),
            TextField(controller: contentCtrl, decoration: const InputDecoration(labelText: 'Nội dung thắc mắc')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              if (titleCtrl.text.trim().isNotEmpty) {
                await _repo.createForumPost(widget.courseClass.id, titleCtrl.text.trim(), contentCtrl.text.trim());
                Navigator.pop(ctx);
                _loadAllClassData();
              }
            },
            child: const Text('Đăng bài'),
          ),
        ],
      ),
    );
  }

  void _showAddCommentModal(ForumPostEntity post) {
    final commentCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Trả lời: ${post.title}'),
        content: TextField(controller: commentCtrl, decoration: const InputDecoration(labelText: 'Nội dung bình luận')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              if (commentCtrl.text.trim().isNotEmpty) {
                await _repo.addForumComment(post.id, commentCtrl.text.trim());
                Navigator.pop(ctx);
                _loadAllClassData();
              }
            },
            child: const Text('Gửi'),
          ),
        ],
      ),
    );
  }

  // --- TAB 5: ĐIỂM DANH ---
  Widget _buildAttendanceTab() {
    final isLecturer = widget.currentUser.isLecturer;
    if (!isLecturer) {
      final present = _attendanceRecords.where((r) => r.status == 'PRESENT').length;
      final lateCount = _attendanceRecords.where((r) => r.status == 'LATE').length;
      final absent = _attendanceRecords.where((r) => r.status == 'ABSENT').length;
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(children: [Text('$present', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.success)), const Text('Có mặt')]),
                    Column(children: [Text('$lateCount', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.orange)), const Text('Đi muộn')]),
                    Column(children: [Text('$absent', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red)), const Text('Vắng mặt')]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _attendanceRecords.length,
                itemBuilder: (c, i) {
                  final att = _attendanceRecords[i];
                  return ListTile(
                    leading: const Icon(Icons.event_available),
                    title: Text('Ngày: ${att.attendanceDate}'),
                    trailing: Chip(
                      label: Text(att.status),
                      backgroundColor: att.status == 'PRESENT' ? AppColors.success : (att.status == 'LATE' ? Colors.orange : Colors.red),
                      labelStyle: const TextStyle(color: Colors.white),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    }

    // Lecturer Attendance View
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            title: const Text('Điểm danh lớp hôm nay', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Bấm để tích điểm danh PRESENT / LATE / ABSENT cho sinh viên'),
            trailing: ElevatedButton(
              onPressed: _showLecturerMarkAttendanceModal,
              child: const Text('Điểm danh'),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text('Lịch sử điểm danh', style: AppTextStyles.h3),
        ..._attendanceRecords.map((att) => ListTile(
          title: Text('${att.studentName ?? "SV"} (${att.studentCode ?? "N/A"})'),
          subtitle: Text('Ngày: ${att.attendanceDate}'),
          trailing: Text(att.status, style: const TextStyle(fontWeight: FontWeight.bold)),
        )),
      ],
    );
  }

  void _showLecturerMarkAttendanceModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Điểm danh Lớp: ${widget.courseClass.classCode}', style: AppTextStyles.h3),
            const Divider(),
            const Expanded(
              child: Center(child: Text('Danh sách sinh viên đang tải... Tất cả mặc định PRESENT.')),
            ),
            ElevatedButton(
              onPressed: () async {
                await _repo.markClassAttendance(
                  widget.courseClass.id,
                  DateTime.now().toIso8601String().substring(0, 10),
                  [],
                );
                Navigator.pop(ctx);
                _loadAllClassData();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lưu điểm danh thành công!')));
              },
              child: const Text('Lưu điểm danh'),
            ),
          ],
        ),
      ),
    );
  }

  // --- TAB 6: SỔ ĐIỂM (LECTURER) ---
  Widget _buildGradebookTab() {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await _repo.publishGrades(widget.courseClass.id);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã công bố điểm cho toàn bộ Sinh viên!')));
        },
        label: const Text('Công bố điểm'),
        icon: const Icon(Icons.publish),
        backgroundColor: AppColors.success,
      ),
      body: _gradebookRecords.isEmpty
          ? const Center(child: Text('Chưa có dữ liệu bảng điểm'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _gradebookRecords.length,
              itemBuilder: (c, i) {
                final item = _gradebookRecords[i];
                final studentId = item['studentId'] as int? ?? 0;
                final studentName = item['studentName'] as String? ?? 'Sinh viên';
                final midCtrl = TextEditingController(text: item['midtermScore']?.toString() ?? '');
                final finalCtrl = TextEditingController(text: item['finalScore']?.toString() ?? '');

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(studentName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: midCtrl,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'Điểm Giữa Kỳ'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: finalCtrl,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(labelText: 'Điểm Cuối Kỳ'),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.save, color: AppColors.primary),
                              onPressed: () async {
                                final m = double.tryParse(midCtrl.text);
                                final f = double.tryParse(finalCtrl.text);
                                await _repo.updateStudentGrade(widget.courseClass.id, studentId, m, f);
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã cập nhật điểm!')));
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
