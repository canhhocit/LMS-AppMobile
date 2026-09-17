import '../../domain/entities/schedule_entity.dart';

abstract class ScheduleState {}

class ScheduleInitial extends ScheduleState {}

class ScheduleLoading extends ScheduleState {}

class ScheduleLoaded extends ScheduleState {
  final List<ScheduleItemEntity> scheduleList;
  final int selectedDayOfWeek; // 2 = Mon, 3 = Tue, ..., 8 = Sun

  ScheduleLoaded({
    required this.scheduleList,
    this.selectedDayOfWeek = 2,
  });

  List<ScheduleItemEntity> get filteredSchedule {
    return scheduleList.where((e) => e.dayOfWeek == selectedDayOfWeek).toList();
  }
}

class ScheduleError extends ScheduleState {
  final String message;
  ScheduleError(this.message);
}
