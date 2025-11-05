import 'package:equatable/equatable.dart';

/// Day Schedule Model
///
/// Represents schedule for a specific day of the week
class DayScheduleModel extends Equatable {
  final String start;
  final String end;
  final String hours;
  final bool isWorkingDay;

  const DayScheduleModel({
    required this.start,
    required this.end,
    required this.hours,
    required this.isWorkingDay,
  });

  factory DayScheduleModel.fromJson(Map<String, dynamic> json) {
    return DayScheduleModel(
      start: json['start'] as String,
      end: json['end'] as String? ?? '',
      hours: json['hours'] as String,
      isWorkingDay: json['is_working_day'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start': start,
      'end': end,
      'hours': hours,
      'is_working_day': isWorkingDay,
    };
  }

  @override
  List<Object?> get props => [
        start,
        end,
        hours,
        isWorkingDay,
      ];
}
