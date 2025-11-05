import 'package:equatable/equatable.dart';
import '../../data/models/work_schedule_model.dart';

/// Work Schedule State
///
/// Represents different states of work schedule operations
abstract class WorkScheduleState extends Equatable {
  const WorkScheduleState();

  @override
  List<Object?> get props => [];

  /// Display message for UI
  String get displayMessage {
    if (this is WorkScheduleError) {
      return (this as WorkScheduleError).message;
    }
    return '';
  }
}

/// Initial State
class WorkScheduleInitial extends WorkScheduleState {
  const WorkScheduleInitial();
}

/// Loading State
class WorkScheduleLoading extends WorkScheduleState {
  const WorkScheduleLoading();
}

/// Work Schedule Loaded
class WorkScheduleLoaded extends WorkScheduleState {
  final WorkScheduleModel workSchedule;

  const WorkScheduleLoaded({required this.workSchedule});

  @override
  List<Object?> get props => [workSchedule];
}

/// Error State
class WorkScheduleError extends WorkScheduleState {
  final String message;

  const WorkScheduleError({required this.message});

  @override
  List<Object?> get props => [message];
}
