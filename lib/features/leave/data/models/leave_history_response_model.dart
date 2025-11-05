import 'package:equatable/equatable.dart';
import 'leave_request_model.dart';

/// Leave History Response Model
///
/// Wrapper for paginated leave history API response
class LeaveHistoryResponseModel extends Equatable {
  final List<LeaveRequestModel> leaveRequests;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  const LeaveHistoryResponseModel({
    required this.leaveRequests,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory LeaveHistoryResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];

    // Try both 'items' and 'data' keys for leave requests list
    final itemsData = data['items'] ?? data['data'];
    final List<LeaveRequestModel> requestsList = [];

    if (itemsData != null && itemsData is List) {
      for (var item in itemsData) {
        try {
          requestsList.add(LeaveRequestModel.fromJson(item as Map<String, dynamic>));
        } catch (e) {
          // Skip invalid items
          continue;
        }
      }
    }

    // Handle pagination data from either direct fields or nested pagination object
    final paginationData = data['pagination'] as Map<String, dynamic>?;

    return LeaveHistoryResponseModel(
      leaveRequests: requestsList,
      currentPage: (data['current_page'] as int?) ??
                   (paginationData?['current_page'] as int?) ?? 1,
      lastPage: (data['last_page'] as int?) ??
                (paginationData?['total_pages'] as int?) ?? 1,
      perPage: (data['per_page'] as int?) ??
               (paginationData?['per_page'] as int?) ?? 15,
      total: (data['total'] as int?) ??
             (paginationData?['total'] as int?) ?? 0,
    );
  }

  @override
  List<Object?> get props => [
        leaveRequests,
        currentPage,
        lastPage,
        perPage,
        total,
      ];

  /// Check if there are more pages to load
  bool get hasMore => currentPage < lastPage;
}
