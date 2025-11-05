import 'package:equatable/equatable.dart';

/// Monthly Report Model
///
/// Represents monthly attendance report data
class MonthlyReportModel extends Equatable {
  final String month;
  final int year;
  final int monthNumber;
  final int totalDays;
  final int presentDays;
  final int absentDays;
  final int lateDays;
  final int earlyLeaveDays;
  final double totalHours;
  final double expectedHours;
  final double overtimeHours;
  final double attendancePercentage;

  const MonthlyReportModel({
    required this.month,
    required this.year,
    required this.monthNumber,
    required this.totalDays,
    required this.presentDays,
    required this.absentDays,
    required this.lateDays,
    required this.earlyLeaveDays,
    required this.totalHours,
    required this.expectedHours,
    required this.overtimeHours,
    required this.attendancePercentage,
  });

  factory MonthlyReportModel.fromJson(Map<String, dynamic> json) {
    return MonthlyReportModel(
      month: json['month'] as String,
      year: json['year'] as int,
      monthNumber: json['month_number'] as int,
      totalDays: json['total_days'] as int,
      presentDays: json['present_days'] as int,
      absentDays: json['absent_days'] as int,
      lateDays: json['late_days'] as int,
      earlyLeaveDays: json['early_leave_days'] as int,
      totalHours: (json['total_hours'] as num).toDouble(),
      expectedHours: (json['expected_hours'] as num).toDouble(),
      overtimeHours: (json['overtime_hours'] as num).toDouble(),
      attendancePercentage: (json['attendance_percentage'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'month': month,
      'year': year,
      'month_number': monthNumber,
      'total_days': totalDays,
      'present_days': presentDays,
      'absent_days': absentDays,
      'late_days': lateDays,
      'early_leave_days': earlyLeaveDays,
      'total_hours': totalHours,
      'expected_hours': expectedHours,
      'overtime_hours': overtimeHours,
      'attendance_percentage': attendancePercentage,
    };
  }

  @override
  List<Object?> get props => [
        month,
        year,
        monthNumber,
        totalDays,
        presentDays,
        absentDays,
        lateDays,
        earlyLeaveDays,
        totalHours,
        expectedHours,
        overtimeHours,
        attendancePercentage,
      ];
}
