import 'package:equatable/equatable.dart';
import '../../data/models/dashboard_stats_model.dart';

/// Base Dashboard State
abstract class DashboardState extends Equatable {
  /// Previous stats to keep showing data even during errors
  final DashboardStatsModel? previousStats;

  /// Error message if any
  final String? errorMessage;

  /// Whether currently loading
  final bool isLoading;

  const DashboardState({
    this.previousStats,
    this.errorMessage,
    this.isLoading = false,
  });

  @override
  List<Object?> get props => [previousStats, errorMessage, isLoading];

  /// Check if has cached data
  bool get hasData => previousStats != null;

  /// Check if has error
  bool get hasError => errorMessage != null;

  /// Get user-friendly error message
  String? get displayError {
    if (errorMessage == null) return null;

    if (errorMessage!.contains('401') || errorMessage!.contains('Unauthenticated')) {
      return 'Session expired. Please login again';
    } else if (errorMessage!.contains('500')) {
      return 'Server error. Please try again later';
    } else if (errorMessage!.contains('Network') || errorMessage!.contains('connection')) {
      return 'No internet connection';
    } else if (errorMessage!.contains('timeout')) {
      return 'Connection timeout. Please try again';
    }
    return errorMessage;
  }
}

/// Dashboard Initial State
class DashboardInitial extends DashboardState {
  const DashboardInitial() : super();
}

/// Dashboard Loading State - keeps previous data visible
class DashboardLoading extends DashboardState {
  const DashboardLoading({super.previousStats}) : super(isLoading: true);
}

/// Dashboard Loaded State
class DashboardLoaded extends DashboardState {
  final DashboardStatsModel stats;

  const DashboardLoaded({required this.stats}) : super(previousStats: stats);

  @override
  List<Object?> get props => [stats, previousStats, errorMessage, isLoading];
}

/// Dashboard Error State - keeps previous data visible with error banner
class DashboardError extends DashboardState {
  const DashboardError({
    required String message,
    super.previousStats,
  }) : super(errorMessage: message);
}
