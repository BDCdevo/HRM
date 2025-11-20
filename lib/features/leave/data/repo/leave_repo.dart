import '../../../../core/config/api_config.dart';
import '../../../../core/networking/dio_client.dart';
import '../models/vacation_type_model.dart';
import '../models/leave_request_model.dart';
import '../models/leave_balance_model.dart';
import '../models/leave_history_response_model.dart';

/// Leave Repository
///
/// Handles all API calls related to leave management
class LeaveRepo {
  final DioClient _dioClient = DioClient.getInstance();

  /// Get Vacation Types
  ///
  /// Fetches all available vacation types for the employee
  Future<List<VacationTypeModel>> getVacationTypes() async {
    try {
      final response = await _dioClient.get(ApiConfig.vacationTypes);

      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data == null) {
          return [];
        }

        final List<dynamic> list = data is List ? data : [];
        return list.map((json) => VacationTypeModel.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch vacation types');
      }
    } catch (e) {
      print('❌ Error fetching vacation types: $e');
      rethrow;
    }
  }

  /// Apply for Leave
  ///
  /// Creates a new leave request
  /// [vacationTypeId] - ID of the vacation type
  /// [startDate] - Start date (YYYY-MM-DD)
  /// [endDate] - End date (YYYY-MM-DD)
  /// [reason] - Reason for the leave
  Future<LeaveRequestModel> applyLeave({
    required int vacationTypeId,
    required String startDate,
    required String endDate,
    required String reason,
  }) async {
    print('🔵 Applying leave: vacation_type_id=$vacationTypeId, start=$startDate, end=$endDate');

    final response = await _dioClient.post(
      ApiConfig.applyLeave,
      data: {
        'vacation_type_id': vacationTypeId,
        'start_date': startDate,
        'end_date': endDate,
        'reason': reason,
      },
    );

    print('✅ Apply leave response: ${response.statusCode}');
    print('📦 Response data: ${response.data}');

    return LeaveRequestModel.fromJson(response.data['data']);
  }

  /// Get Leave History
  ///
  /// Fetches paginated leave request history
  /// [page] - Page number
  /// [perPage] - Items per page
  /// [status] - Optional status filter (pending, approved, rejected, cancelled)
  Future<LeaveHistoryResponseModel> getLeaveHistory({
    int page = 1,
    int perPage = 15,
    String? status,
  }) async {
    final queryParameters = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };

    if (status != null && status.isNotEmpty) {
      queryParameters['status'] = status;
    }

    final response = await _dioClient.get(
      ApiConfig.leaveHistory,
      queryParameters: queryParameters,
    );

    return LeaveHistoryResponseModel.fromJson(response.data);
  }

  /// Get Leave Balance
  ///
  /// Fetches leave balance for all vacation types
  Future<LeaveBalanceResponseModel> getLeaveBalance() async {
    final response = await _dioClient.get(ApiConfig.leaveBalance);

    return LeaveBalanceResponseModel.fromJson(response.data);
  }

  /// Get Leave Details
  ///
  /// Fetches detailed information about a specific leave request
  Future<LeaveRequestModel> getLeaveDetails(int leaveId) async {
    final response = await _dioClient.get(ApiConfig.leaveDetails(leaveId));

    return LeaveRequestModel.fromJson(response.data['data']);
  }

  /// Cancel Leave
  ///
  /// Cancels a leave request
  Future<void> cancelLeave(int leaveId) async {
    await _dioClient.delete(ApiConfig.cancelLeave(leaveId));
  }
}
