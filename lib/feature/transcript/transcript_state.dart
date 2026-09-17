import '../../domain/entities/grade_entity.dart';

abstract class TranscriptState {}

class TranscriptInitial extends TranscriptState {}

class TranscriptLoading extends TranscriptState {}

class TranscriptLoaded extends TranscriptState {
  final List<GradeEntity> grades;

  TranscriptLoaded(this.grades);

  double get gpa {
    if (grades.isEmpty) return 0.0;
    double totalPoints = 0.0;
    int totalCredits = 0;
    for (var g in grades) {
      if (g.overallGrade != null) {
        totalPoints += g.overallGrade! * g.credits;
        totalCredits += g.credits;
      }
    }
    return totalCredits == 0 ? 0.0 : totalPoints / totalCredits;
  }

  int get totalCreditsSum {
    return grades.fold(0, (sum, g) => sum + g.credits);
  }
}

class TranscriptError extends TranscriptState {
  final String message;
  TranscriptError(this.message);
}
