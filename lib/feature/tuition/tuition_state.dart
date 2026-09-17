import '../../domain/entities/tuition_entity.dart';

abstract class TuitionState {}

class TuitionInitial extends TuitionState {}

class TuitionLoading extends TuitionState {}

class TuitionLoaded extends TuitionState {
  final List<TuitionItemEntity> list;
  TuitionLoaded(this.list);

  double get totalUnpaid {
    return list.fold(0.0, (sum, item) => sum + item.remainingAmount);
  }
}

class TuitionError extends TuitionState {
  final String message;
  TuitionError(this.message);
}
