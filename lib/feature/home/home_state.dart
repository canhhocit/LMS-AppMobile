import '../../domain/entities/class_entity.dart';
import '../../domain/entities/schedule_entity.dart';
import '../../domain/entities/user_entity.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final UserEntity? user;
  final List<CourseClassEntity> classes;
  final List<ScheduleItemEntity> todaySchedule;

  HomeLoaded({
    this.user,
    required this.classes,
    required this.todaySchedule,
  });
}

class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}
