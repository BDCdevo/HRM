import 'package:equatable/equatable.dart';
import '../../data/models/vacation_type_model.dart';
import '../../data/models/leave_request_model.dart';
import '../../data/models/leave_balance_model.dart';

/// Leave State
///
/// Represents different states of leave management operations
abstract class LeaveState extends Equatable {
  const LeaveState();

  @override
  List<Object?> get props => [];

  /// Display message for UI
  String get displayMessage {
    if (this is LeaveError) {
      return (this as LeaveError).message;
    }
    return '';
  }
}

/// Initial State
class LeaveInitial extends LeaveState {
  const LeaveInitial();
}

/// Loading State (vacation types)
class VacationTypesLoading extends LeaveState {
  const VacationTypesLoading();
}

/// Vacation Types Loaded
class VacationTypesLoaded extends LeaveState {
  final List<VacationTypeModel> availableTypes;
  final List<VacationTypeModel> unavailableTypes;

  const VacationTypesLoaded({
    required this.availableTypes,
    this.unavailableTypes = const [],
  });

  @override
  List<Object?> get props => [availableTypes, unavailableTypes];

  /// Get all vacation types (available + unavailable)
  List<VacationTypeModel> get allTypes => [...availableTypes, ...unavailableTypes];
}

/// Applying Leave State
class ApplyingLeave extends LeaveState {
  const ApplyingLeave();
}

/// Leave Applied Successfully
class LeaveApplied extends LeaveState {
  final LeaveRequestModel leaveRequest;
  final String message;

  const LeaveApplied({
    required this.leaveRequest,
    this.message = 'Leave request submitted successfully',
  });

  @override
  List<Object?> get props => [leaveRequest, message];
}

/// Loading Leave History
class LeaveHistoryLoading extends LeaveState {
  const LeaveHistoryLoading();
}

/// Loading More Leave History (Pagination)
class LeaveHistoryLoadingMore extends LeaveState {
  final List<LeaveRequestModel> currentRequests;

  const LeaveHistoryLoadingMore({required this.currentRequests});

  @override
  List<Object?> get props => [currentRequests];
}

/// Leave History Loaded
class LeaveHistoryLoaded extends LeaveState {
  final List<LeaveRequestModel> leaveRequests;
  final int currentPage;
  final int lastPage;
  final int total;
  final bool hasMore;
  final String? statusFilter;

  const LeaveHistoryLoaded({
    required this.leaveRequests,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.hasMore,
    this.statusFilter,
  });

  @override
  List<Object?> get props => [
        leaveRequests,
        currentPage,
        lastPage,
        total,
        hasMore,
        statusFilter,
      ];

  /// Get requests by status
  List<LeaveRequestModel> get pendingRequests =>
      leaveRequests.where((r) => r.isPending).toList();

  List<LeaveRequestModel> get approvedRequests =>
      leaveRequests.where((r) => r.isApproved).toList();
}

/// Refreshing Leave History
class LeaveHistoryRefreshing extends LeaveState {
  final List<LeaveRequestModel> currentRequests;

  const LeaveHistoryRefreshing({required this.currentRequests});

  @override
  List<Object?> get props => [currentRequests];
}

/// Loading Leave Balance
class LeaveBalanceLoading extends LeaveState {
  const LeaveBalanceLoading();
}

/// Leave Balance Loaded
class LeaveBalanceLoaded extends LeaveState {
  final List<LeaveBalanceModel> balances;
  final int totalRemaining;
  final int year;

  const LeaveBalanceLoaded({
    required this.balances,
    required this.totalRemaining,
    required this.year,
  });

  @override
  List<Object?> get props => [balances, totalRemaining, year];

  /// Get available balances
  List<LeaveBalanceModel> get availableBalances =>
      balances.where((b) => b.isAvailable).toList();
}

/// Cancelling Leave
class CancellingLeave extends LeaveState {
  final int leaveId;

  const CancellingLeave({required this.leaveId});

  @override
  List<Object?> get props => [leaveId];
}

/// Leave Cancelled
class LeaveCancelled extends LeaveState {
  final int leaveId;
  final String message;

  const LeaveCancelled({
    required this.leaveId,
    this.message = 'Leave request cancelled successfully',
  });

  @override
  List<Object?> get props => [leaveId, message];
}

/// Error State
class LeaveError extends LeaveState {
  final String message;
  final String? errorDetails;

  const LeaveError({
    required this.message,
    this.errorDetails,
  });

  @override
  List<Object?> get props => [message, errorDetails];
}
