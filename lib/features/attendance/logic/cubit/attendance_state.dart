import 'package:equatable/equatable.dart';
import '../../data/models/attendance_model.dart';
import '../../data/models/attendance_session_model.dart';

/// Base Attendance State
abstract class AttendanceState extends Equatable {
  const AttendanceState();

  @override
  List<Object?> get props => [];
}

/// Attendance Initial State
class AttendanceInitial extends AttendanceState {
  const AttendanceInitial();
}

/// Attendance Loading State
class AttendanceLoading extends AttendanceState {
  const AttendanceLoading();
}

/// Attendance Status Loaded State
///
/// Contains today's attendance status
class AttendanceStatusLoaded extends AttendanceState {
  final AttendanceStatusModel status;

  const AttendanceStatusLoaded({required this.status});

  @override
  List<Object?> get props => [status];
}

/// Check-in Success State
class CheckInSuccess extends AttendanceState {
  final AttendanceModel attendance;

  const CheckInSuccess({required this.attendance});

  @override
  List<Object?> get props => [attendance];
}

/// Check-out Success State
class CheckOutSuccess extends AttendanceState {
  final AttendanceModel attendance;

  const CheckOutSuccess({required this.attendance});

  @override
  List<Object?> get props => [attendance];
}

/// Sessions Loading State
class SessionsLoading extends AttendanceState {
  const SessionsLoading();
}

/// Sessions Loaded State
///
/// Contains all check-in/check-out sessions for today
class SessionsLoaded extends AttendanceState {
  final TodaySessionsDataModel sessionsData;

  const SessionsLoaded({required this.sessionsData});

  @override
  List<Object?> get props => [sessionsData];
}

/// Attendance Error State
class AttendanceError extends AttendanceState {
  final String message;
  final String? errorDetails;

  const AttendanceError({
    required this.message,
    this.errorDetails,
  });

  @override
  List<Object?> get props => [message, errorDetails];

  /// Get user-friendly error message
  String get displayMessage {
    // If message contains distance info, return as-is
    if (message.contains('You are far') ||
        message.contains('Current distance') ||
        message.contains('Request timeout') ||
        message.contains('Network error')) {
      return message;
    }

    // Otherwise, provide user-friendly translations
    if (message.contains('401') || message.contains('Unauthenticated')) {
      return 'Session expired. Please login again.';
    } else if (message.contains('already checked in')) {
      return 'You have already checked in today.';
    } else if (message.contains('already checked out')) {
      return 'You have already checked out today.';
    } else if (message.contains('No check-in record')) {
      return 'Please check in first before checking out.';
    } else if (message.contains('500')) {
      return 'Server error. Please try again later.';
    } else if (message.contains('Network')) {
      return 'Network error. Please check your connection.';
    } else {
      return message;
    }
  }
}
