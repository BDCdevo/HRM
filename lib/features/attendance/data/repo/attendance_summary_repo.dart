import '../../../../core/networking/dio_client.dart';
import '../../../../core/config/api_config.dart';
import '../models/employee_attendance_model.dart';

/// Attendance Summary Repository
///
/// Handles API calls for fetching all employees' attendance summary
class AttendanceSummaryRepo {
  final DioClient _dioClient = DioClient.getInstance();

  /// Fetch Today's Attendance Summary
  ///
  /// Returns summary of all employees' attendance for today
  Future<AttendanceSummaryModel> fetchTodaySummary() async {
    try {
      final response = await _dioClient.get(
        ApiConfig.attendanceSummaryToday,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        return AttendanceSummaryModel.fromJson(data);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch attendance summary');
      }
    } catch (e) {
      throw Exception('Error fetching attendance summary: $e');
    }
  }

  /// Fetch Attendance Summary by Date
  ///
  /// Returns summary of all employees' attendance for a specific date
  Future<AttendanceSummaryModel> fetchSummaryByDate(DateTime date) async {
    try {
      final formattedDate = date.toIso8601String().split('T')[0]; // YYYY-MM-DD

      final response = await _dioClient.get(
        ApiConfig.attendanceSummary,
        queryParameters: {'date': formattedDate},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        return AttendanceSummaryModel.fromJson(data);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch attendance summary');
      }
    } catch (e) {
      throw Exception('Error fetching attendance summary: $e');
    }
  }
}
