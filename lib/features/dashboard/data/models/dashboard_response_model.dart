import 'package:equatable/equatable.dart';
import 'dashboard_stats_model.dart';

/// Dashboard Stats Response Model
///
/// Wraps the dashboard statistics data from the API
/// Matches Laravel's DataResponse structure
class DashboardResponseModel extends Equatable {
  final bool success;
  final String message;
  final DashboardStatsModel data;

  const DashboardResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory DashboardResponseModel.fromJson(Map<String, dynamic> json) {
    return DashboardResponseModel(
      success: json['success'] as bool? ?? true,
      message: json['message'] as String? ?? '',
      data: DashboardStatsModel.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.toJson(),
    };
  }

  @override
  List<Object?> get props => [success, message, data];
}
