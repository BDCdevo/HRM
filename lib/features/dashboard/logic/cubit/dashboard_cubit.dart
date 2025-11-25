import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../data/models/dashboard_stats_model.dart';
import '../../data/repo/dashboard_repo.dart';
import 'dashboard_state.dart';

/// Dashboard Cubit
///
/// Manages dashboard state and handles fetching dashboard statistics
/// Keeps previous data visible during loading and errors
class DashboardCubit extends Cubit<DashboardState> {
  final DashboardRepo _dashboardRepo = DashboardRepo();

  DashboardCubit() : super(const DashboardInitial());

  /// Get current cached stats
  DashboardStatsModel? get _cachedStats => state.previousStats;

  /// Fetch Dashboard Statistics
  ///
  /// Keeps previous data visible during loading and error states
  Future<void> fetchDashboardStats() async {
    try {
      // Keep previous data visible during loading
      emit(DashboardLoading(previousStats: _cachedStats));

      final stats = await _dashboardRepo.getDashboardStats();

      emit(DashboardLoaded(stats: stats));
    } on DioException catch (e) {
      // Keep previous data, just show error
      final errorMessage = _getErrorMessage(e);
      emit(DashboardError(
        message: errorMessage,
        previousStats: _cachedStats,
      ));
    } catch (e) {
      emit(DashboardError(
        message: e.toString(),
        previousStats: _cachedStats,
      ));
    }
  }

  /// Get user-friendly error message from DioException
  String _getErrorMessage(DioException e) {
    if (e.response != null) {
      final statusCode = e.response?.statusCode;
      if (statusCode == 401) return 'Unauthenticated';
      if (statusCode == 500) return '500 Server Error';
      return e.response?.data?['message'] ?? 'Server error';
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'timeout';
    }

    if (e.type == DioExceptionType.unknown ||
        e.type == DioExceptionType.connectionError) {
      return 'Network connection error';
    }

    return e.message ?? 'Unknown error';
  }

  /// Refresh Dashboard
  Future<void> refresh() async {
    await fetchDashboardStats();
  }
}
