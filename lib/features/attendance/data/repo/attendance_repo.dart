import 'package:dio/dio.dart';
import '../../../../core/networking/dio_client.dart';
import '../../../../core/config/api_config.dart';
import '../models/attendance_response_model.dart';
import '../models/attendance_model.dart';
import '../models/attendance_history_model.dart';
import '../models/attendance_session_model.dart';

/// Attendance Repository
///
/// Handles all attendance-related API calls
/// Uses Dio for HTTP requests with automatic token injection
class AttendanceRepo {
  final DioClient _dioClient = DioClient.getInstance();

  /// Check In
  ///
  /// Records employee check-in time for today
  /// Optionally includes GPS location (latitude, longitude) for branch validation
  /// Throws [DioException] on network errors
  Future<AttendanceModel> checkIn({
    double? latitude,
    double? longitude,
    String? notes,
  }) async {
    try {
      print('🔵 AttendanceRepo.checkIn called');
      print('📍 Latitude: $latitude');
      print('📍 Longitude: $longitude');
      print('📝 Notes: $notes');

      final Map<String, dynamic> data = {};

      if (latitude != null) {
        data['latitude'] = latitude;
      }

      if (longitude != null) {
        data['longitude'] = longitude;
      }

      if (notes != null && notes.isNotEmpty) {
        data['notes'] = notes;
      }

      print('📦 Request data: $data');

      final response = await _dioClient.post(
        ApiConfig.checkIn,
        data: data,
      );

      print('✅ Check-in Response: ${response.data}');

      final attendanceResponse = AttendanceResponseModel.fromJson(response.data);

      return attendanceResponse.data;
    } on DioException catch (e) {
      print('❌ Check-in Error: ${e.message}');
      print('❌ Response: ${e.response?.data}');
      rethrow;
    }
  }

  /// Check Out
  ///
  /// Records employee check-out time for today
  /// Throws [DioException] on network errors
  Future<AttendanceModel> checkOut({
    double? latitude,
    double? longitude,
  }) async {
    try {
      final Map<String, dynamic> data = {};

      if (latitude != null) {
        data['latitude'] = latitude;
      }

      if (longitude != null) {
        data['longitude'] = longitude;
      }

      print('📦 Check-out Request data: $data');

      final response = await _dioClient.post(
        ApiConfig.checkOut,
        data: data.isNotEmpty ? data : null,
      );

      print('✅ Check-out Response: ${response.data}');

      final attendanceResponse = AttendanceResponseModel.fromJson(response.data);

      return attendanceResponse.data;
    } on DioException catch (e) {
      print('❌ Check-out Error: ${e.message}');
      print('❌ Response: ${e.response?.data}');
      rethrow;
    }
  }

  /// Get Today's Status
  ///
  /// Fetches today's attendance status
  /// Returns check-in/check-out status and times
  /// Throws [DioException] on network errors
  Future<AttendanceStatusModel> getTodayStatus() async {
    try {
      final response = await _dioClient.get(
        ApiConfig.todayStatus,
      );

      print('📊 Today Status Response: ${response.data}');

      final statusResponse = AttendanceStatusResponseModel.fromJson(response.data);

      return statusResponse.data;
    } on DioException catch (e) {
      print('❌ Today Status Error: ${e.message}');
      print('❌ Response: ${e.response?.data}');
      rethrow;
    }
  }

  /// Get Attendance History
  ///
  /// Fetches paginated attendance history for the authenticated user
  /// GET /api/v1/attendance/history?page=1&per_page=15
  Future<AttendanceHistoryModel> getHistory({
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final response = await _dioClient.get(
        ApiConfig.attendanceHistory,
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
      );

      print('📜 Attendance History Response: ${response.data}');

      return AttendanceHistoryModel.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ Attendance History Error: ${e.message}');
      print('❌ Response: ${e.response?.data}');
      rethrow;
    }
  }

  /// Get Today's Sessions
  ///
  /// Fetches all check-in/check-out sessions for today
  /// Supports multiple sessions per day
  /// GET /api/v1/employee/attendance/sessions
  Future<TodaySessionsDataModel> getTodaySessions({String? date}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (date != null) {
        queryParams['date'] = date;
      }

      final response = await _dioClient.get(
        ApiConfig.todaySession,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      print('📊 Today Sessions Response: ${response.data}');

      final sessionsResponse = TodaySessionsResponseModel.fromJson(response.data);

      return sessionsResponse.data;
    } on DioException catch (e) {
      print('❌ Today Sessions Error: ${e.message}');
      print('❌ Response: ${e.response?.data}');
      rethrow;
    }
  }
}
