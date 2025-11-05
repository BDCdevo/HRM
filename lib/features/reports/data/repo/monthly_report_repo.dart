import '../../../../core/config/api_config.dart';
import '../../../../core/networking/dio_client.dart';
import '../models/monthly_report_model.dart';

/// Monthly Report Repository
///
/// Handles all API calls related to monthly reports
class MonthlyReportRepo {
  final DioClient _dioClient = DioClient.getInstance();

  /// Get Monthly Report
  ///
  /// Fetches monthly attendance report for the specified year and month
  /// [year] - Year (defaults to current year)
  /// [month] - Month (1-12, defaults to current month)
  Future<MonthlyReportModel> getMonthlyReport({
    int? year,
    int? month,
  }) async {
    final queryParameters = <String, dynamic>{};

    if (year != null) {
      queryParameters['year'] = year;
    }

    if (month != null) {
      queryParameters['month'] = month;
    }

    final response = await _dioClient.get(
      ApiConfig.monthlyReport,
      queryParameters: queryParameters,
    );

    return MonthlyReportModel.fromJson(response.data['data']);
  }
}
