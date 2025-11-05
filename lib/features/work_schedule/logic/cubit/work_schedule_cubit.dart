import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../data/repo/work_schedule_repo.dart';
import 'work_schedule_state.dart';

/// Work Schedule Cubit
///
/// Manages work schedule state and handles schedule-related operations
class WorkScheduleCubit extends Cubit<WorkScheduleState> {
  final WorkScheduleRepo _workScheduleRepo = WorkScheduleRepo();

  WorkScheduleCubit() : super(const WorkScheduleInitial());

  /// Fetch Work Schedule
  ///
  /// Loads the employee's work schedule information
  Future<void> fetchWorkSchedule() async {
    try {
      emit(const WorkScheduleLoading());

      final workSchedule = await _workScheduleRepo.getWorkSchedule();

      emit(WorkScheduleLoaded(workSchedule: workSchedule));
    } on DioException catch (e) {
      _handleDioException(e);
    } catch (e) {
      emit(WorkScheduleError(
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
          errorMessage = responseData['message'] ?? 'Bad request';
          break;
        case 401:
          errorMessage = 'Session expired. Please login again';
          break;
        case 403:
          errorMessage = 'Access denied';
          break;
        case 404:
          errorMessage = responseData['message'] ?? 'No work schedule assigned';
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

    emit(WorkScheduleError(message: errorMessage));
  }
}
