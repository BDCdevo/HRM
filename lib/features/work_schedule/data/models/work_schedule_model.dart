import 'package:equatable/equatable.dart';
import 'day_schedule_model.dart';
import 'schedule_info_model.dart';
import 'work_plan_model.dart';

/// Work Schedule Model
///
/// Complete work schedule response from the API
class WorkScheduleModel extends Equatable {
  final WorkPlanModel workPlan;
  final ScheduleInfoModel schedule;
  final Map<String, DayScheduleModel> weeklySchedule;

  const WorkScheduleModel({
    required this.workPlan,
    required this.schedule,
    required this.weeklySchedule,
  });

  factory WorkScheduleModel.fromJson(Map<String, dynamic> json) {
    // Parse weekly schedule
    final weeklyScheduleJson = json['weekly_schedule'] as Map<String, dynamic>;
    final weeklySchedule = <String, DayScheduleModel>{};

    weeklyScheduleJson.forEach((day, scheduleJson) {
      weeklySchedule[day] = DayScheduleModel.fromJson(scheduleJson as Map<String, dynamic>);
    });

    return WorkScheduleModel(
      workPlan: WorkPlanModel.fromJson(json['work_plan'] as Map<String, dynamic>),
      schedule: ScheduleInfoModel.fromJson(json['schedule'] as Map<String, dynamic>),
      weeklySchedule: weeklySchedule,
    );
  }

  Map<String, dynamic> toJson() {
    final weeklyScheduleJson = <String, dynamic>{};
    weeklySchedule.forEach((day, schedule) {
      weeklyScheduleJson[day] = schedule.toJson();
    });

    return {
      'work_plan': workPlan.toJson(),
      'schedule': schedule.toJson(),
      'weekly_schedule': weeklyScheduleJson,
    };
  }

  @override
  List<Object?> get props => [
        workPlan,
        schedule,
        weeklySchedule,
      ];
}
