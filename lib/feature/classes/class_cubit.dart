import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/student_repository.dart';
import 'class_state.dart';

class ClassCubit extends Cubit<ClassState> {
  final StudentRepository studentRepository;

  ClassCubit(this.studentRepository) : super(ClassInitial());

  Future<void> loadClasses() async {
    emit(ClassLoading());
    try {
      final classes = await studentRepository.getMyClasses();
      emit(ClassLoaded(classes));
    } catch (e) {
      emit(ClassError(e.toString()));
    }
  }
}
