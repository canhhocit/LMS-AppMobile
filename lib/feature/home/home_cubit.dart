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
      final allSchedule = await studentRepository.getMySchedule();

      // Filter today's schedule based on current weekday
      final now = DateTime.now();
      // DateTime.weekday: 1 = Mon ... 7 = Sun -> Map to 2 = Mon ... 8 = Sun
      final todayDayOfWeek = (now.weekday == 7) ? 8 : (now.weekday + 1);

      final todaySchedule = allSchedule.where((s) => s.dayOfWeek == todayDayOfWeek).toList();

      emit(HomeLoaded(
        user: user,
        classes: classes,
        todaySchedule: todaySchedule,
      ));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}
