import '../../../../core/config/api_config.dart';
import '../../../../core/networking/dio_client.dart';
import '../models/weekly_stats_model.dart';

/// Weekly Stats Repository
///
/// Handles fetching weekly attendance statistics from the API
class WeeklyStatsRepo {
  final _dioClient = DioClient.getInstance();

  /// Fetch weekly stats for the current employee
  ///
  /// Returns [WeeklyStatsModel] with total hours worked this week
  Future<WeeklyStatsModel> fetchWeeklyStats() async {
    try {
      final response = await _dioClient.get(ApiConfig.weeklyStats);

      if (response.statusCode == 200) {
        final data = response.data;

        // Handle both wrapped and unwrapped responses
        if (data is Map<String, dynamic>) {
          if (data.containsKey('data')) {
            return WeeklyStatsModel.fromJson(data['data']);
          }
          return WeeklyStatsModel.fromJson(data);
        }
      }

      throw Exception('Failed to fetch weekly stats');
    } catch (e) {
      // Return empty stats on error (API might not be implemented yet)
      // This allows graceful fallback
      print('WeeklyStatsRepo: Error fetching weekly stats: $e');
      return WeeklyStatsModel.empty();
    }
  }
}
