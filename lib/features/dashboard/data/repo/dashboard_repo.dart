import 'package:dio/dio.dart';
import '../../../../core/networking/dio_client.dart';
import '../../../../core/config/api_config.dart';
import '../models/dashboard_response_model.dart';
import '../models/dashboard_stats_model.dart';

/// Dashboard Repository
///
/// Handles all dashboard-related API calls
/// Uses Dio for HTTP requests with automatic token injection
class DashboardRepo {
  final DioClient _dioClient = DioClient.getInstance();

  /// Get Dashboard Statistics
  ///
  /// Fetches dashboard stats including:
  /// - Attendance percentage
  /// - Leave balance
  /// - Hours worked this month
  /// - Pending tasks count
  /// - User information
  ///
  /// Requires authentication (token automatically included)
  /// Throws [DioException] on network errors
  Future<DashboardStatsModel> getDashboardStats() async {
    try {
      final response = await _dioClient.get(
        ApiConfig.dashboardStats,
      );

      print('📊 Dashboard Stats Response: ${response.data}');

      final dashboardResponse = DashboardResponseModel.fromJson(response.data);

      return dashboardResponse.data;
    } on DioException catch (e) {
      print('❌ Dashboard Stats Error: ${e.message}');
      print('❌ Response: ${e.response?.data}');
      rethrow;
    }
  }
}
