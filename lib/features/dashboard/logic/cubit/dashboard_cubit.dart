import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../data/repo/dashboard_repo.dart';
import 'dashboard_state.dart';

/// Dashboard Cubit
///
/// Manages dashboard state and handles fetching dashboard statistics
class DashboardCubit extends Cubit<DashboardState> {
  final DashboardRepo _dashboardRepo = DashboardRepo();

  DashboardCubit() : super(const DashboardInitial());

  /// Fetch Dashboard Statistics
  ///
  /// Fetches dashboard stats from the API and updates state accordingly
  /// Emits:
  /// - [DashboardLoading] while fetching
  /// - [DashboardLoaded] on success
  /// - [DashboardError] on failure
  Future<void> fetchDashboardStats() async {
    try {
      emit(const DashboardLoading());

      final stats = await _dashboardRepo.getDashboardStats();

      emit(DashboardLoaded(stats: stats));
    } on DioException catch (e) {
      // Handle different types of Dio exceptions
      if (e.response != null) {
        // Server responded with error
        final statusCode = e.response?.statusCode;
        final errorMessage = e.response?.data?['message'] ?? 'Failed to fetch dashboard stats';

        emit(DashboardError(
          message: '[$statusCode] $errorMessage',
          errorDetails: e.response?.data?.toString(),
        ));
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        // Timeout error
        emit(const DashboardError(
          message: 'Request timeout. Please try again.',
        ));
      } else if (e.type == DioExceptionType.unknown) {
        // Network error (no internet connection)
        emit(const DashboardError(
          message: 'Network error. Please check your internet connection.',
        ));
      } else {
        // Other Dio errors
        emit(DashboardError(
          message: e.message ?? 'An unexpected error occurred',
        ));
      }
    } catch (e) {
      // Handle any other exceptions
      emit(DashboardError(
        message: 'An unexpected error occurred: ${e.toString()}',
      ));
    }
  }

  /// Refresh Dashboard
  ///
  /// Convenience method to refresh dashboard data
  /// Can be used for pull-to-refresh functionality
  Future<void> refresh() async {
    await fetchDashboardStats();
  }
}
