import 'package:equatable/equatable.dart';
import '../../data/models/employee_attendance_model.dart';

/// Attendance Summary State
abstract class AttendanceSummaryState extends Equatable {
  const AttendanceSummaryState();

  @override
  List<Object?> get props => [];
}

/// Initial State
class AttendanceSummaryInitial extends AttendanceSummaryState {
  const AttendanceSummaryInitial();
}

/// Loading State
class AttendanceSummaryLoading extends AttendanceSummaryState {
  const AttendanceSummaryLoading();
}

/// Loaded State
class AttendanceSummaryLoaded extends AttendanceSummaryState {
  final AttendanceSummaryModel summary;

  const AttendanceSummaryLoaded(this.summary);

  @override
  List<Object?> get props => [summary];
}

/// Error State
class AttendanceSummaryError extends AttendanceSummaryState {
  final String message;

  const AttendanceSummaryError(this.message);

  @override
  List<Object?> get props => [message];
}
