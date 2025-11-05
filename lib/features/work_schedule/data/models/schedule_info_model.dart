import 'package:equatable/equatable.dart';

/// Schedule Info Model
///
/// Contains summary information about the work schedule
class ScheduleInfoModel extends Equatable {
  final String shiftType;
  final int workDaysCount;
  final String weeklyHours;
  final String breakTime;

  const ScheduleInfoModel({
    required this.shiftType,
    required this.workDaysCount,
    required this.weeklyHours,
    required this.breakTime,
  });

  factory ScheduleInfoModel.fromJson(Map<String, dynamic> json) {
    return ScheduleInfoModel(
      shiftType: json['shift_type'] as String,
      workDaysCount: json['work_days_count'] as int,
      weeklyHours: json['weekly_hours'] as String,
      breakTime: json['break_time'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shift_type': shiftType,
      'work_days_count': workDaysCount,
      'weekly_hours': weeklyHours,
      'break_time': breakTime,
    };
  }

  @override
  List<Object?> get props => [
        shiftType,
        workDaysCount,
        weeklyHours,
        breakTime,
      ];
}
