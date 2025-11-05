import 'package:equatable/equatable.dart';
import '../../data/models/monthly_report_model.dart';

/// Monthly Report State
///
/// Represents different states of monthly report operations
abstract class MonthlyReportState extends Equatable {
  const MonthlyReportState();

  @override
  List<Object?> get props => [];

  /// Display message for UI
  String get displayMessage {
    if (this is MonthlyReportError) {
      return (this as MonthlyReportError).message;
    }
    return '';
  }
}

/// Initial State
class MonthlyReportInitial extends MonthlyReportState {
  const MonthlyReportInitial();
}

/// Loading State
class MonthlyReportLoading extends MonthlyReportState {
  const MonthlyReportLoading();
}

/// Monthly Report Loaded
class MonthlyReportLoaded extends MonthlyReportState {
  final MonthlyReportModel report;

  const MonthlyReportLoaded({required this.report});

  @override
  List<Object?> get props => [report];
}

/// Error State
class MonthlyReportError extends MonthlyReportState {
  final String message;

  const MonthlyReportError({required this.message});

  @override
  List<Object?> get props => [message];
}
