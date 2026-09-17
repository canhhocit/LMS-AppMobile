import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/student_repository.dart';
import 'tuition_state.dart';

class TuitionCubit extends Cubit<TuitionState> {
  final StudentRepository studentRepository;

  TuitionCubit(this.studentRepository) : super(TuitionInitial());

  Future<void> loadTuition() async {
    emit(TuitionLoading());
    try {
      final list = await studentRepository.getMyTuition();
      emit(TuitionLoaded(list));
    } catch (e) {
      emit(TuitionError(e.toString()));
    }
  }
}
