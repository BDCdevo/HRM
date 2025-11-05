import 'package:equatable/equatable.dart';

/// Work Plan Model
///
/// Represents the employee's work plan/shift details
class WorkPlanModel extends Equatable {
  final int id;
  final String name;
  final String startTime;
  final String endTime;
  final int permissionMinutes;
  final List<int> workingDays;

  const WorkPlanModel({
    required this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.permissionMinutes,
    required this.workingDays,
  });

  factory WorkPlanModel.fromJson(Map<String, dynamic> json) {
    return WorkPlanModel(
      id: json['id'] as int,
      name: json['name'] as String,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      permissionMinutes: json['permission_minutes'] as int,
      workingDays: (json['working_days'] as List<dynamic>)
          .map((e) => e as int)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'start_time': startTime,
      'end_time': endTime,
      'permission_minutes': permissionMinutes,
      'working_days': workingDays,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        startTime,
        endTime,
        permissionMinutes,
        workingDays,
      ];
}
