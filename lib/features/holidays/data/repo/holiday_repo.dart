import 'package:dio/dio.dart';
import '../../../../core/networking/dio_client.dart';
import '../../../../core/config/api_config.dart';
import '../models/holiday_model.dart';

class HolidayRepo {
  final DioClient _dioClient = DioClient.getInstance();

  /// Get all holidays with optional filters
  /// [filter] can be: 'all', 'upcoming', 'current', 'past'
  /// [year] to filter by specific year (default: current year)
  Future<List<HolidayModel>> getHolidays({
    String filter = 'all',
    int? year,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'filter': filter,
      };

      if (year != null) {
        queryParams['year'] = year;
      }

      final response = await _dioClient.get(
        '${ApiConfig.baseUrl}/holidays',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] as List<dynamic>;
        return data.map((json) => HolidayModel.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch holidays');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error occurred');
    } catch (e) {
      throw Exception('Failed to fetch holidays: $e');
    }
  }

  /// Get upcoming holidays
  /// [days] number of days to look ahead (default: 30)
  Future<List<HolidayModel>> getUpcomingHolidays({int days = 30}) async {
    try {
      final response = await _dioClient.get(
        '${ApiConfig.baseUrl}/holidays/upcoming',
        queryParameters: {'days': days},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] as List<dynamic>;
        return data.map((json) => HolidayModel.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch upcoming holidays');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Network error occurred');
    } catch (e) {
      throw Exception('Failed to fetch upcoming holidays: $e');
    }
  }
}
