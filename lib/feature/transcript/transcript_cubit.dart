import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/student_repository.dart';
import 'transcript_state.dart';

class TranscriptCubit extends Cubit<TranscriptState> {
  final StudentRepository studentRepository;

  TranscriptCubit(this.studentRepository) : super(TranscriptInitial());

  Future<void> loadGrades() async {
    emit(TranscriptLoading());
    try {
      final grades = await studentRepository.getMyGrades();
      emit(TranscriptLoaded(grades));
    } catch (e) {
      emit(TranscriptError(e.toString()));
    }
  }
}
