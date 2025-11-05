import '../../../../core/config/api_config.dart';
import '../../../../core/networking/dio_client.dart';
import '../models/work_schedule_model.dart';

/// Work Schedule Repository
///
/// Handles all API calls related to work schedule
class WorkScheduleRepo {
  final DioClient _dioClient = DioClient.getInstance();

  /// Get Work Schedule
  ///
  /// Fetches the employee's work schedule/shift information
  Future<WorkScheduleModel> getWorkSchedule() async {
    final response = await _dioClient.get(ApiConfig.workSchedule);

    return WorkScheduleModel.fromJson(response.data['data']);
  }
}
