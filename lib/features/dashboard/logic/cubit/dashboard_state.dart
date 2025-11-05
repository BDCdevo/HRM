import 'package:equatable/equatable.dart';
import '../../data/models/dashboard_stats_model.dart';

/// Base Dashboard State
abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

/// Dashboard Initial State
///
/// Initial state when the dashboard cubit is created
class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

/// Dashboard Loading State
///
/// State when fetching dashboard statistics from API
class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

/// Dashboard Loaded State
///
/// State when dashboard statistics have been successfully fetched
class DashboardLoaded extends DashboardState {
  final DashboardStatsModel stats;

  const DashboardLoaded({required this.stats});

  @override
  List<Object?> get props => [stats];
}

/// Dashboard Error State
///
/// State when an error occurs while fetching dashboard statistics
class DashboardError extends DashboardState {
  final String message;
  final String? errorDetails;

  const DashboardError({
    required this.message,
    this.errorDetails,
  });

  @override
  List<Object?> get props => [message, errorDetails];

  /// Get user-friendly error message
  String get displayMessage {
    if (message.contains('401') || message.contains('Unauthenticated')) {
      return 'Session expired. Please login again.';
    } else if (message.contains('500')) {
      return 'Server error. Please try again later.';
    } else if (message.contains('Network')) {
      return 'Network error. Please check your connection.';
    } else {
      return message;
    }
  }
}
