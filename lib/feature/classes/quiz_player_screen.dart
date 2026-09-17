import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/di/service_locator.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/entities/quiz_entity.dart';
import '../../domain/repositories/lms_repository.dart';

class QuizPlayerScreen extends StatefulWidget {
  final QuizEntity quiz;
  final List<QuizQuestionEntity> questions;

  const QuizPlayerScreen({
    super.key,
    required this.quiz,
    required this.questions,
  });

  @override
  State<QuizPlayerScreen> createState() => _QuizPlayerScreenState();
}

class _QuizPlayerScreenState extends State<QuizPlayerScreen> {
  final LmsRepository _repo = getIt<LmsRepository>();

  int _currentIndex = 0;
  final Map<int, String> _userAnswers = {};

  late Timer _timer;
  late int _remainingSeconds;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.quiz.durationMinutes * 60;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remainingSeconds <= 1) {
        t.cancel();
        _autoSubmit();
      } else {
        setState(() {
          _remainingSeconds--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> _autoSubmit() async {
    if (_isSubmitting) return;
    _submitQuiz(isAuto: true);
  }

  Future<void> _submitQuiz({bool isAuto = false}) async {
    setState(() => _isSubmitting = true);
    _timer.cancel();

    try {
      final attempt = await _repo.submitQuizAttempt(widget.quiz.id, _userAnswers);
      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(
                attempt.score >= 5.0 ? Icons.stars_rounded : Icons.warning_amber_rounded,
                color: attempt.score >= 5.0 ? Colors.amber : Colors.orange,
                size: 28,
              ),
              const SizedBox(width: 10),
              Text(isAuto ? 'Hết giờ làm bài!' : 'Kết quả bài kiểm tra'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  attempt.score.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Thang điểm: ${widget.quiz.totalScore}',
                style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Chip(
                label: Text(
                  attempt.score >= 5.0 ? '🎉 ĐẠT BÀI KIỂM TRA' : '⚠️ CHƯA ĐẠT',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
                backgroundColor: attempt.score >= 5.0 ? AppColors.success : Colors.red,
              ),
              const SizedBox(height: 12),
              Text(
                'Số câu đã trả lời: ${_userAnswers.length} / ${widget.questions.length}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pop(ctx); // Close dialog
                Navigator.pop(context, true); // Return to class screen
              },
              child: const Text('Hoàn tất & Quay lại'),
            ),
          ],
        ),
      );
    } catch (_) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể gửi bài kiểm tra. Vui lòng thử lại!'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentQ = widget.questions[_currentIndex];
    final totalQ = widget.questions.length;
    final isLastQ = _currentIndex == totalQ - 1;
    final isWarningTime = _remainingSeconds < 120;

    return WillPopScope(
      onWillPop: () async {
        final shouldLeave = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Thoát bài kiểm tra?'),
            content: const Text('Bài làm của bạn chưa được nộp. Bạn có chắc muốn rời đi?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Làm tiếp')),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                child: const Text('Thoát'),
              ),
            ],
          ),
        );
        return shouldLeave ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.quiz.title),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isWarningTime ? Colors.red : Colors.white24,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 18,
                    color: isWarningTime ? Colors.white : Colors.amberAccent,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formattedTime,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: _isSubmitting
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Đang nộp & chấm điểm tự động...', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              )
            : Column(
                children: [
                  // Progress Bar
                  LinearProgressIndicator(
                    value: (_currentIndex + 1) / totalQ,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),

                  // Question Selector Chips
                  Container(
                    height: 50,
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: totalQ,
                      itemBuilder: (ctx, idx) {
                        final isSelected = idx == _currentIndex;
                        final isAnswered = _userAnswers.containsKey(widget.questions[idx].id);

                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: InkWell(
                            onTap: () => setState(() => _currentIndex = idx),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: 34,
                              height: 34,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : (isAnswered ? AppColors.success.withOpacity(0.15) : Colors.grey.shade100),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : (isAnswered ? AppColors.success : Colors.grey.shade300),
                                  width: 1.5,
                                ),
                              ),
                              child: Text(
                                '${idx + 1}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: isSelected
                                      ? Colors.white
                                      : (isAnswered ? AppColors.success : Colors.grey.shade700),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const Divider(height: 1),

                  // Main Question Card
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Câu ${_currentIndex + 1} / $totalQ',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 14),
                              ),
                              if (_userAnswers.containsKey(currentQ.id))
                                const Chip(
                                  label: Text('Đã chọn', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                  backgroundColor: AppColors.success,
                                  visualDensity: VisualDensity.compact,
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                currentQ.questionText,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, height: 1.4),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Option Selectors (A, B, C, D)
                          _buildOptionTile('A', currentQ.optionA, currentQ.id),
                          _buildOptionTile('B', currentQ.optionB, currentQ.id),
                          _buildOptionTile('C', currentQ.optionC, currentQ.id),
                          _buildOptionTile('D', currentQ.optionD, currentQ.id),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Action Navigation Bar
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _currentIndex > 0 ? () => setState(() => _currentIndex--) : null,
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Câu trước'),
                        ),
                        if (isLastQ)
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.check_circle_outline),
                            label: const Text('Nộp bài ngay', style: TextStyle(fontWeight: FontWeight.bold)),
                            onPressed: () => _submitQuiz(),
                          )
                        else
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.arrow_forward),
                            label: const Text('Câu tiếp'),
                            onPressed: () => setState(() => _currentIndex++),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildOptionTile(String key, String text, int questionId) {
    final isSelected = _userAnswers[questionId] == key;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () {
          setState(() {
            _userAnswers[questionId] = key;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withOpacity(0.08) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.grey.shade300,
              width: isSelected ? 2.0 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  key,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? AppColors.primary : Colors.black87,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle, color: AppColors.primary, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
