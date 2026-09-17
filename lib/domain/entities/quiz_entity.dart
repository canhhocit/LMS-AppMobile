class QuizEntity {
  final int id;
  final int classId;
  final String title;
  final int durationMinutes;
  final double totalScore;
  final List<QuizQuestionEntity> questions;
  final QuizAttemptEntity? latestAttempt;

  const QuizEntity({
    required this.id,
    required this.classId,
    required this.title,
    required this.durationMinutes,
    required this.totalScore,
    this.questions = const [],
    this.latestAttempt,
  });

  factory QuizEntity.fromJson(Map<String, dynamic> json) {
    return QuizEntity(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      classId: json['classId'] ?? json['class_id'] ?? 0,
      title: json['title'] ?? '',
      durationMinutes: json['durationMinutes'] ?? json['duration_minutes'] ?? 15,
      totalScore: (json['totalScore'] ?? json['total_score'] ?? 10.0).toDouble(),
      questions: (json['questions'] as List<dynamic>?)
              ?.map((q) => QuizQuestionEntity.fromJson(q as Map<String, dynamic>))
              .toList() ??
          [],
      latestAttempt: json['latestAttempt'] != null
          ? QuizAttemptEntity.fromJson(json['latestAttempt'] as Map<String, dynamic>)
          : null,
    );
  }
}

class QuizQuestionEntity {
  final int id;
  final String questionText;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String? correctAnswer;

  const QuizQuestionEntity({
    required this.id,
    required this.questionText,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    this.correctAnswer,
  });

  factory QuizQuestionEntity.fromJson(Map<String, dynamic> json) {
    return QuizQuestionEntity(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      questionText: json['questionText'] ?? json['question_text'] ?? '',
      optionA: json['optionA'] ?? json['option_a'] ?? '',
      optionB: json['optionB'] ?? json['option_b'] ?? '',
      optionC: json['optionC'] ?? json['option_c'] ?? '',
      optionD: json['optionD'] ?? json['option_d'] ?? '',
      correctAnswer: json['correctAnswer'] ?? json['correct_answer'],
    );
  }
}

class QuizAttemptEntity {
  final int id;
  final int quizId;
  final double score;
  final String startedAt;
  final String submittedAt;

  const QuizAttemptEntity({
    required this.id,
    required this.quizId,
    required this.score,
    required this.startedAt,
    required this.submittedAt,
  });

  factory QuizAttemptEntity.fromJson(Map<String, dynamic> json) {
    return QuizAttemptEntity(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      quizId: json['quizId'] ?? json['quiz_id'] ?? 0,
      score: (json['score'] as num).toDouble(),
      startedAt: json['startedAt'] ?? json['started_at'] ?? '',
      submittedAt: json['submittedAt'] ?? json['submitted_at'] ?? '',
    );
  }
}
