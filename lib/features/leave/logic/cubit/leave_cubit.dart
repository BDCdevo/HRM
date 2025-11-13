import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../data/repo/leave_repo.dart';
import '../../data/models/leave_request_model.dart';
import 'leave_state.dart';

/// Leave Cubit
///
/// Manages leave management state and handles all leave-related operations
class LeaveCubit extends Cubit<LeaveState> {
  final LeaveRepo _leaveRepo = LeaveRepo();

  LeaveCubit() : super(const LeaveInitial());

  int _currentPage = 1;
  final int _perPage = 15;
  List<LeaveRequestModel> _allLeaveRequests = [];
  String? _statusFilter;

  /// Fetch Vacation Types
  ///
  /// Loads all available vacation types
  Future<void> fetchVacationTypes() async {
    try {
      emit(const VacationTypesLoading());

      final vacationTypes = await _leaveRepo.getVacationTypes();

      print('✅ LeaveCubit: Loaded ${vacationTypes.length} vacation types');

      // Log each type for debugging
      for (var type in vacationTypes) {
        print('  - ${type.name}: isAvailable=${type.isAvailable}, balance=${type.balance}');
      }

      if (vacationTypes.isEmpty) {
        emit(const LeaveError(
          message: 'لا توجد أنواع إجازات متاحة.\nيرجى التواصل مع قسم الموارد البشرية.',
        ));
        return;
      }

      // Return ALL vacation types (available and unavailable)
      // The UI will handle disabling unavailable types
      emit(VacationTypesLoaded(
        availableTypes: vacationTypes.where((type) => type.isAvailable).toList(),
        unavailableTypes: vacationTypes.where((type) => !type.isAvailable).toList(),
      ));
    } on DioException catch (e) {
      _handleDioException(e);
    } catch (e) {
      print('❌ LeaveCubit: Error fetching vacation types - $e');
      emit(LeaveError(
        message: 'حدث خطأ أثناء تحميل أنواع الإجازات: ${e.toString()}',
      ));
    }
  }

  /// Apply for Leave
  ///
  /// Creates a new leave request
  Future<void> applyLeave({
    required int vacationTypeId,
    required String startDate,
    required String endDate,
    required String reason,
  }) async {
    try {
      emit(const ApplyingLeave());

      final leaveRequest = await _leaveRepo.applyLeave(
        vacationTypeId: vacationTypeId,
        startDate: startDate,
        endDate: endDate,
        reason: reason,
      );

      emit(LeaveApplied(leaveRequest: leaveRequest));
    } on DioException catch (e) {
      _handleDioException(e);
    } catch (e) {
      emit(LeaveError(
        message: 'An unexpected error occurred: ${e.toString()}',
      ));
    }
  }

  /// Fetch Leave History (First Page)
  ///
  /// Loads the first page of leave history
  Future<void> fetchLeaveHistory({String? status}) async {
    try {
      print('🔵 LeaveCubit: Fetching leave history...');
      emit(const LeaveHistoryLoading());

      _currentPage = 1;
      _allLeaveRequests = [];
      _statusFilter = status;

      final response = await _leaveRepo.getLeaveHistory(
        page: _currentPage,
        perPage: _perPage,
        status: _statusFilter,
      );

      _allLeaveRequests = response.leaveRequests;

      print('✅ LeaveCubit: Leave history loaded - ${_allLeaveRequests.length} requests');

      emit(LeaveHistoryLoaded(
        leaveRequests: _allLeaveRequests,
        currentPage: response.currentPage,
        lastPage: response.lastPage,
        total: response.total,
        hasMore: response.hasMore,
        statusFilter: _statusFilter,
      ));
    } on DioException catch (e) {
      print('❌ LeaveCubit: Dio error - ${e.message}');
      _handleDioException(e);
    } catch (e) {
      print('❌ LeaveCubit: Error - ${e.toString()}');
      emit(LeaveError(
        message: 'An unexpected error occurred: ${e.toString()}',
      ));
    }
  }

  /// Load More Leave History (Pagination)
  ///
  /// Loads the next page of leave history
  Future<void> loadMoreLeaveHistory() async {
    final currentState = state;

    // Only load more if we have a loaded state and there are more pages
    if (currentState is! LeaveHistoryLoaded || !currentState.hasMore) {
      return;
    }

    try {
      emit(LeaveHistoryLoadingMore(currentRequests: _allLeaveRequests));

      _currentPage++;

      final response = await _leaveRepo.getLeaveHistory(
        page: _currentPage,
        perPage: _perPage,
        status: _statusFilter,
      );

      _allLeaveRequests.addAll(response.leaveRequests);

      emit(LeaveHistoryLoaded(
        leaveRequests: _allLeaveRequests,
        currentPage: response.currentPage,
        lastPage: response.lastPage,
        total: response.total,
        hasMore: response.hasMore,
        statusFilter: _statusFilter,
      ));
    } on DioException catch (e) {
      _handleDioException(e);
    } catch (e) {
      emit(LeaveError(
        message: 'An unexpected error occurred: ${e.toString()}',
      ));
    }
  }

  /// Refresh Leave History
  ///
  /// Refreshes the leave history (pulls first page again)
  Future<void> refreshLeaveHistory() async {
    final currentState = state;

    try {
      // Show refreshing state if we already have data
      if (currentState is LeaveHistoryLoaded) {
        emit(LeaveHistoryRefreshing(currentRequests: _allLeaveRequests));
      } else {
        emit(const LeaveHistoryLoading());
      }

      _currentPage = 1;
      _allLeaveRequests = [];

      final response = await _leaveRepo.getLeaveHistory(
        page: _currentPage,
        perPage: _perPage,
        status: _statusFilter,
      );

      _allLeaveRequests = response.leaveRequests;

      emit(LeaveHistoryLoaded(
        leaveRequests: _allLeaveRequests,
        currentPage: response.currentPage,
        lastPage: response.lastPage,
        total: response.total,
        hasMore: response.hasMore,
        statusFilter: _statusFilter,
      ));
    } on DioException catch (e) {
      _handleDioException(e);
    } catch (e) {
      emit(LeaveError(
        message: 'An unexpected error occurred: ${e.toString()}',
      ));
    }
  }

  /// Fetch Leave Balance
  ///
  /// Loads leave balance for all vacation types
  Future<void> fetchLeaveBalance() async {
    try {
      print('🔵 LeaveCubit: Fetching leave balance...');
      emit(const LeaveBalanceLoading());

      final balanceResponse = await _leaveRepo.getLeaveBalance();

      print('✅ LeaveCubit: Leave balance loaded - ${balanceResponse.balances.length} types');

      emit(LeaveBalanceLoaded(
        balances: balanceResponse.balances,
        totalRemaining: balanceResponse.totalRemaining,
        year: balanceResponse.year,
      ));
    } on DioException catch (e) {
      print('❌ LeaveCubit: Dio error - ${e.message}');
      _handleDioException(e);
    } catch (e) {
      print('❌ LeaveCubit: Error - ${e.toString()}');
      emit(LeaveError(
        message: 'An unexpected error occurred: ${e.toString()}',
      ));
    }
  }

  /// Cancel Leave Request
  ///
  /// Cancels a leave request and updates the local state
  Future<void> cancelLeave(int leaveId) async {
    try {
      emit(CancellingLeave(leaveId: leaveId));

      await _leaveRepo.cancelLeave(leaveId);

      // Update local state
      final index = _allLeaveRequests.indexWhere((r) => r.id == leaveId);
      if (index != -1) {
        // Update the status to cancelled in local state
        // Since LeaveRequestModel is immutable, we need to recreate it
        // For now, we'll just remove it and refetch
        // In a production app, you might want to implement a copyWith method
      }

      emit(LeaveCancelled(leaveId: leaveId));

      // Refresh the list after cancellation
      await refreshLeaveHistory();
    } on DioException catch (e) {
      _handleDioException(e);
    } catch (e) {
      emit(LeaveError(
        message: 'An unexpected error occurred: ${e.toString()}',
      ));
    }
  }

  /// Change Status Filter
  ///
  /// Changes the status filter and refetches data
  Future<void> changeStatusFilter(String? status) async {
    if (_statusFilter == status) return;

    _statusFilter = status;
    await fetchLeaveHistory(status: status);
  }

  /// Handle Dio Exception
  void _handleDioException(DioException e) {
    print('❌ DioException: ${e.type} - ${e.message}');
    print('Response: ${e.response?.data}');

    if (e.response != null) {
      // Server responded with error
      final statusCode = e.response?.statusCode;
      final errorMessage = e.response?.data?['message'] ?? 'فشلت العملية';

      // Handle 401 Unauthorized
      if (statusCode == 401) {
        emit(const LeaveError(
          message: 'انتهت صلاحية الجلسة. يرجى تسجيل الدخول مرة أخرى',
        ));
        return;
      }

      // Handle 403 Forbidden
      if (statusCode == 403) {
        emit(const LeaveError(
          message: 'ليس لديك صلاحية لهذه العملية',
        ));
        return;
      }

      // Handle 404 Not Found
      if (statusCode == 404) {
        emit(const LeaveError(
          message: 'البيانات المطلوبة غير موجودة',
        ));
        return;
      }

      // Handle validation errors (422)
      if (statusCode == 422 && e.response?.data?['errors'] != null) {
        final errors = e.response?.data?['errors'];
        final errorList = <String>[];

        if (errors is Map) {
          errors.forEach((key, value) {
            if (value is List) {
              errorList.addAll(value.cast<String>());
            } else {
              errorList.add(value.toString());
            }
          });
        } else if (errors is List) {
          errorList.addAll(errors.cast<String>());
        }

        emit(LeaveError(
          message: errorList.isNotEmpty ? errorList.first : errorMessage,
          errorDetails: errorList.join('\n'),
        ));
        return;
      }

      // Handle 500 Server Error
      if (statusCode != null && statusCode >= 500) {
        emit(const LeaveError(
          message: 'خطأ في الخادم. يرجى المحاولة لاحقاً',
        ));
        return;
      }

      emit(LeaveError(
        message: errorMessage,
        errorDetails: e.response?.data?.toString(),
      ));
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      // Timeout error
      emit(const LeaveError(
        message: 'انتهت مهلة الاتصال. يرجى المحاولة مرة أخرى',
      ));
    } else if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.unknown) {
      // Network error (no internet connection)
      emit(const LeaveError(
        message: 'خطأ في الاتصال. تحقق من الإنترنت',
      ));
    } else {
      // Other Dio errors
      emit(const LeaveError(
        message: 'حدث خطأ غير متوقع',
      ));
    }
  }
}
