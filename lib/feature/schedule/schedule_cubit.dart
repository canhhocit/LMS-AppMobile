import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/student_repository.dart';
import 'schedule_state.dart';

class ScheduleCubit extends Cubit<ScheduleState> {
  final StudentRepository studentRepository;

  ScheduleCubit(this.studentRepository) : super(ScheduleInitial());

  Future<void> loadSchedule() async {
    emit(ScheduleLoading());
    try {
      final list = await studentRepository.getMySchedule();
      emit(ScheduleLoaded(scheduleList: list, selectedDayOfWeek: 2));
    } catch (e) {
      emit(ScheduleError(e.toString()));
    }
  }

  void selectDay(int dayOfWeek) {
    if (state is ScheduleLoaded) {
      final current = state as ScheduleLoaded;
      emit(ScheduleLoaded(
        scheduleList: current.scheduleList,
        selectedDayOfWeek: dayOfWeek,
      ));
    }
  }
}
