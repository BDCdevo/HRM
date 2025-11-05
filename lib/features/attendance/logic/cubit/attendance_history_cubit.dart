import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../data/repo/attendance_repo.dart';
import '../../data/models/attendance_history_model.dart';
import 'attendance_history_state.dart';

/// Attendance History Cubit
///
/// Manages attendance history state and handles pagination
class AttendanceHistoryCubit extends Cubit<AttendanceHistoryState> {
  final AttendanceRepo _attendanceRepo = AttendanceRepo();

  AttendanceHistoryCubit() : super(const AttendanceHistoryInitial());

  int _currentPage = 1;
  final int _perPage = 15;
  List<AttendanceHistoryItemModel> _allRecords = [];

  /// Fetch Attendance History (First Page)
  ///
  /// Loads the first page of attendance history
  /// Emits:
  /// - [AttendanceHistoryLoading] while fetching
  /// - [AttendanceHistoryLoaded] on success
  /// - [AttendanceHistoryError] on failure
  Future<void> fetchHistory() async {
    try {
      emit(const AttendanceHistoryLoading());

      _currentPage = 1;
      _allRecords = [];

      final historyModel = await _attendanceRepo.getHistory(
        page: _currentPage,
        perPage: _perPage,
      );

      _allRecords = historyModel.items;

      emit(AttendanceHistoryLoaded(
        records: _allRecords,
        currentPage: historyModel.currentPage,
        lastPage: historyModel.totalPages,
        total: historyModel.pagination.total,
        hasMore: historyModel.hasMore,
      ));
    } on DioException catch (e) {
      _handleDioException(e);
    } catch (e) {
      emit(AttendanceHistoryError(
        message: 'An unexpected error occurred: ${e.toString()}',
      ));
    }
  }

  /// Load More (Pagination)
  ///
  /// Loads the next page of attendance history
  /// Emits:
  /// - [AttendanceHistoryLoadingMore] while fetching
  /// - [AttendanceHistoryLoaded] on success with updated records
  /// - [AttendanceHistoryError] on failure
  Future<void> loadMore() async {
    final currentState = state;

    // Only load more if we have a loaded state and there are more pages
    if (currentState is! AttendanceHistoryLoaded || !currentState.hasMore) {
      return;
    }

    try {
      emit(AttendanceHistoryLoadingMore(currentRecords: _allRecords));

      _currentPage++;

      final historyModel = await _attendanceRepo.getHistory(
        page: _currentPage,
        perPage: _perPage,
      );

      _allRecords.addAll(historyModel.items);

      emit(AttendanceHistoryLoaded(
        records: _allRecords,
        currentPage: historyModel.currentPage,
        lastPage: historyModel.totalPages,
        total: historyModel.pagination.total,
        hasMore: historyModel.hasMore,
      ));
    } on DioException catch (e) {
      _handleDioException(e);
    } catch (e) {
      emit(AttendanceHistoryError(
        message: 'An unexpected error occurred: ${e.toString()}',
      ));
    }
  }

  /// Refresh
  ///
  /// Refreshes the attendance history (pulls first page again)
  /// Emits:
  /// - [AttendanceHistoryRefreshing] while refreshing
  /// - [AttendanceHistoryLoaded] on success
  /// - [AttendanceHistoryError] on failure
  Future<void> refresh() async {
    final currentState = state;

    try {
      // Show refreshing state if we already have data
      if (currentState is AttendanceHistoryLoaded) {
        emit(AttendanceHistoryRefreshing(currentRecords: _allRecords));
      } else {
        emit(const AttendanceHistoryLoading());
      }

      _currentPage = 1;
      _allRecords = [];

      final historyModel = await _attendanceRepo.getHistory(
        page: _currentPage,
        perPage: _perPage,
      );

      _allRecords = historyModel.items;

      emit(AttendanceHistoryLoaded(
        records: _allRecords,
        currentPage: historyModel.currentPage,
        lastPage: historyModel.totalPages,
        total: historyModel.pagination.total,
        hasMore: historyModel.hasMore,
      ));
    } on DioException catch (e) {
      _handleDioException(e);
    } catch (e) {
      emit(AttendanceHistoryError(
        message: 'An unexpected error occurred: ${e.toString()}',
      ));
    }
  }

  /// Handle Dio Exception
  void _handleDioException(DioException e) {
    if (e.response != null) {
      // Server responded with error
      final statusCode = e.response?.statusCode;
      final errorMessage = e.response?.data?['message'] ?? 'Operation failed';

      emit(AttendanceHistoryError(
        message: '[$statusCode] $errorMessage',
        errorDetails: e.response?.data?.toString(),
      ));
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      // Timeout error
      emit(const AttendanceHistoryError(
        message: 'Request timeout. Please try again.',
      ));
    } else if (e.type == DioExceptionType.unknown) {
      // Network error (no internet connection)
      emit(const AttendanceHistoryError(
        message: 'Network error. Please check your internet connection.',
      ));
    } else {
      // Other Dio errors
      emit(AttendanceHistoryError(
        message: e.message ?? 'An unexpected error occurred',
      ));
    }
  }
}
