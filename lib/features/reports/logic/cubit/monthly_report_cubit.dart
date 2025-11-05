import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../data/repo/monthly_report_repo.dart';
import 'monthly_report_state.dart';

/// Monthly Report Cubit
///
/// Manages monthly report state and handles report-related operations
class MonthlyReportCubit extends Cubit<MonthlyReportState> {
  final MonthlyReportRepo _monthlyReportRepo = MonthlyReportRepo();

  MonthlyReportCubit() : super(const MonthlyReportInitial());

  /// Fetch Monthly Report
  ///
  /// Loads monthly attendance report for specified year and month
  /// [year] - Year (defaults to current year)
  /// [month] - Month (1-12, defaults to current month)
  Future<void> fetchMonthlyReport({
    int? year,
    int? month,
  }) async {
    try {
      emit(const MonthlyReportLoading());

      final report = await _monthlyReportRepo.getMonthlyReport(
        year: year,
        month: month,
      );

      emit(MonthlyReportLoaded(report: report));
    } on DioException catch (e) {
      _handleDioException(e);
    } catch (e) {
      emit(MonthlyReportError(
        message: 'An unexpected error occurred: ${e.toString()}',
      ));
    }
  }

  /// Handle Dio Exception
  void _handleDioException(DioException e) {
    String errorMessage = 'An error occurred';

    if (e.response != null) {
      final statusCode = e.response?.statusCode;
      final responseData = e.response?.data;

      switch (statusCode) {
        case 400:
          errorMessage = responseData['message'] ?? 'Invalid request';
          break;
        case 401:
          errorMessage = 'Session expired. Please login again';
          break;
        case 403:
          errorMessage = 'Access denied';
          break;
        case 404:
          errorMessage = responseData['message'] ?? 'Report data not found';
          break;
        case 422:
          errorMessage = responseData['message'] ?? 'Validation error';
          break;
        case 500:
          errorMessage = 'Server error. Please try again later';
          break;
        default:
          errorMessage = responseData['message'] ?? 'An error occurred';
      }
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      errorMessage = 'Connection timeout. Please check your internet connection';
    } else if (e.type == DioExceptionType.connectionError) {
      errorMessage = 'No internet connection';
    } else {
      errorMessage = e.message ?? 'An error occurred';
    }

    emit(MonthlyReportError(message: errorMessage));
  }
}
