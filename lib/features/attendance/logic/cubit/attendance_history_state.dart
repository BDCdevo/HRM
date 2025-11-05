import 'package:equatable/equatable.dart';
import '../../data/models/attendance_history_model.dart';

/// Attendance History State
///
/// Represents different states of attendance history operations
abstract class AttendanceHistoryState extends Equatable {
  const AttendanceHistoryState();

  @override
  List<Object?> get props => [];

  /// Display message for UI
  String get displayMessage {
    if (this is AttendanceHistoryError) {
      return (this as AttendanceHistoryError).message;
    }
    return '';
  }
}

/// Initial State
class AttendanceHistoryInitial extends AttendanceHistoryState {
  const AttendanceHistoryInitial();
}

/// Loading State (first page)
class AttendanceHistoryLoading extends AttendanceHistoryState {
  const AttendanceHistoryLoading();
}

/// Loading More State (pagination)
class AttendanceHistoryLoadingMore extends AttendanceHistoryState {
  final List<AttendanceHistoryItemModel> currentRecords;

  const AttendanceHistoryLoadingMore({required this.currentRecords});

  @override
  List<Object?> get props => [currentRecords];
}

/// Loaded State
class AttendanceHistoryLoaded extends AttendanceHistoryState {
  final List<AttendanceHistoryItemModel> records;
  final int currentPage;
  final int lastPage;
  final int total;
  final bool hasMore;

  const AttendanceHistoryLoaded({
    required this.records,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.hasMore,
  });

  @override
  List<Object?> get props => [
        records,
        currentPage,
        lastPage,
        total,
        hasMore,
      ];
}

/// Refreshing State
class AttendanceHistoryRefreshing extends AttendanceHistoryState {
  final List<AttendanceHistoryItemModel> currentRecords;

  const AttendanceHistoryRefreshing({required this.currentRecords});

  @override
  List<Object?> get props => [currentRecords];
}

/// Error State
class AttendanceHistoryError extends AttendanceHistoryState {
  final String message;
  final String? errorDetails;

  const AttendanceHistoryError({
    required this.message,
    this.errorDetails,
  });

  @override
  List<Object?> get props => [message, errorDetails];
}
