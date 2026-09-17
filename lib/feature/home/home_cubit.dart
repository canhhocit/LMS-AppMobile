import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/student_repository.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final AuthRepository authRepository;
  final StudentRepository studentRepository;

  HomeCubit({
    required this.authRepository,
    required this.studentRepository,
  }) : super(HomeInitial());

  Future<void> loadDashboard() async {
    emit(HomeLoading());
    try {
      final user = await authRepository.getCurrentUser();
      final classes = await studentRepository.getMyClasses();
      final schedule = await studentRepository.getMySchedule();

      emit(HomeLoaded(
        user: user,
        classes: classes,
        todaySchedule: schedule,
      ));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}
