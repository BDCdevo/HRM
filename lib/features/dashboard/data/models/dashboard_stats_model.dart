import 'package:equatable/equatable.dart';

/// Dashboard Statistics Model
///
/// Represents the complete dashboard statistics data
/// Matches the Laravel API response from /api/v1/dashboard/stats
class DashboardStatsModel extends Equatable {
  final AttendanceStats attendance;
  final LeaveBalanceStats leaveBalance;
  final HoursStats hoursThisMonth;
  final PendingTasksStats pendingTasks;
  final PerformanceMetrics performance;
  final UserInfo userInfo;
  final ChartsData charts;

  // Today's attendance counts
  final int todayPresent;
  final int todayAbsent;
  final int todayCheckedOut;

  const DashboardStatsModel({
    required this.attendance,
    required this.leaveBalance,
    required this.hoursThisMonth,
    required this.pendingTasks,
    required this.performance,
    required this.userInfo,
    required this.charts,
    this.todayPresent = 0,
    this.todayAbsent = 0,
    this.todayCheckedOut = 0,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      attendance: AttendanceStats.fromJson(json['attendance'] as Map<String, dynamic>),
      leaveBalance: LeaveBalanceStats.fromJson(json['leave_balance'] as Map<String, dynamic>),
      hoursThisMonth: HoursStats.fromJson(json['hours_this_month'] as Map<String, dynamic>),
      pendingTasks: PendingTasksStats.fromJson(json['pending_tasks'] as Map<String, dynamic>),
      performance: PerformanceMetrics.fromJson(json['performance'] as Map<String, dynamic>),
      userInfo: UserInfo.fromJson(json['user_info'] as Map<String, dynamic>),
      charts: ChartsData.fromJson(json['charts'] as Map<String, dynamic>),
      todayPresent: json['today_present'] as int? ?? 0,
      todayAbsent: json['today_absent'] as int? ?? 0,
      todayCheckedOut: json['today_checked_out'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attendance': attendance.toJson(),
      'leave_balance': leaveBalance.toJson(),
      'hours_this_month': hoursThisMonth.toJson(),
      'pending_tasks': pendingTasks.toJson(),
      'performance': performance.toJson(),
      'user_info': userInfo.toJson(),
      'charts': charts.toJson(),
      'today_present': todayPresent,
      'today_absent': todayAbsent,
      'today_checked_out': todayCheckedOut,
    };
  }

  @override
  List<Object?> get props => [
        attendance,
        leaveBalance,
        hoursThisMonth,
        pendingTasks,
        performance,
        userInfo,
        charts,
        todayPresent,
        todayAbsent,
        todayCheckedOut,
      ];
}

/// Attendance Statistics
class AttendanceStats extends Equatable {
  final double percentage;
  final int presentDays;
  final int totalDays;

  const AttendanceStats({
    required this.percentage,
    required this.presentDays,
    required this.totalDays,
  });

  factory AttendanceStats.fromJson(Map<String, dynamic> json) {
    return AttendanceStats(
      percentage: json['percentage'] != null
          ? (json['percentage'] is String
              ? double.tryParse(json['percentage'] as String) ?? 0.0
              : (json['percentage'] as num).toDouble())
          : 0.0,
      presentDays: json['present_days'] as int,
      totalDays: json['total_days'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'percentage': percentage,
      'present_days': presentDays,
      'total_days': totalDays,
    };
  }

  String get percentageFormatted => '${percentage.toStringAsFixed(1)}%';

  @override
  List<Object?> get props => [percentage, presentDays, totalDays];
}

/// Leave Balance Statistics
class LeaveBalanceStats extends Equatable {
  final int days;
  final int totalAllocated;

  const LeaveBalanceStats({
    required this.days,
    required this.totalAllocated,
  });

  factory LeaveBalanceStats.fromJson(Map<String, dynamic> json) {
    return LeaveBalanceStats(
      days: json['days'] as int,
      totalAllocated: json['total_allocated'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'days': days,
      'total_allocated': totalAllocated,
    };
  }

  String get daysFormatted => '$days Days';

  @override
  List<Object?> get props => [days, totalAllocated];
}

/// Hours Statistics
class HoursStats extends Equatable {
  final double hours;
  final int expectedHours;

  const HoursStats({
    required this.hours,
    required this.expectedHours,
  });

  factory HoursStats.fromJson(Map<String, dynamic> json) {
    return HoursStats(
      hours: json['hours'] != null
          ? (json['hours'] is String
              ? double.tryParse(json['hours'] as String) ?? 0.0
              : (json['hours'] as num).toDouble())
          : 0.0,
      expectedHours: json['expected_hours'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hours': hours,
      'expected_hours': expectedHours,
    };
  }

  String get hoursFormatted => '${hours.toStringAsFixed(1)}h';

  @override
  List<Object?> get props => [hours, expectedHours];
}

/// Pending Tasks Statistics
class PendingTasksStats extends Equatable {
  final int count;

  const PendingTasksStats({
    required this.count,
  });

  factory PendingTasksStats.fromJson(Map<String, dynamic> json) {
    return PendingTasksStats(
      count: json['count'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
    };
  }

  String get countFormatted => count.toString();

  @override
  List<Object?> get props => [count];
}

/// User Information
class UserInfo extends Equatable {
  final int id;
  final String name;
  final String email;

  const UserInfo({
    required this.id,
    required this.name,
    required this.email,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }

  @override
  List<Object?> get props => [id, name, email];
}

/// Performance Metrics
class PerformanceMetrics extends Equatable {
  final PerformanceStats taskCompletion;
  final PerformanceStats monthlyGoals;

  const PerformanceMetrics({
    required this.taskCompletion,
    required this.monthlyGoals,
  });

  factory PerformanceMetrics.fromJson(Map<String, dynamic> json) {
    return PerformanceMetrics(
      taskCompletion: PerformanceStats.fromJson(json['task_completion'] as Map<String, dynamic>),
      monthlyGoals: PerformanceStats.fromJson(json['monthly_goals'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'task_completion': taskCompletion.toJson(),
      'monthly_goals': monthlyGoals.toJson(),
    };
  }

  @override
  List<Object?> get props => [taskCompletion, monthlyGoals];
}

/// Performance Stats (for Task Completion and Monthly Goals)
class PerformanceStats extends Equatable {
  final int percentage;
  final String label;
  final double value;

  const PerformanceStats({
    required this.percentage,
    required this.label,
    required this.value,
  });

  factory PerformanceStats.fromJson(Map<String, dynamic> json) {
    return PerformanceStats(
      percentage: json['percentage'] as int,
      label: json['label'] as String,
      value: json['value'] != null
          ? (json['value'] is String
              ? double.tryParse(json['value'] as String) ?? 0.0
              : (json['value'] as num).toDouble())
          : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'percentage': percentage,
      'label': label,
      'value': value,
    };
  }

  @override
  List<Object?> get props => [percentage, label, value];
}

/// Charts Data
class ChartsData extends Equatable {
  final List<AttendanceTrendData> attendanceTrend;
  final List<MonthlyHoursData> monthlyHours;
  final List<LeaveBreakdownData> leaveBreakdown;

  const ChartsData({
    required this.attendanceTrend,
    required this.monthlyHours,
    required this.leaveBreakdown,
  });

  factory ChartsData.fromJson(Map<String, dynamic> json) {
    return ChartsData(
      attendanceTrend: (json['attendance_trend'] as List)
          .map((e) => AttendanceTrendData.fromJson(e as Map<String, dynamic>))
          .toList(),
      monthlyHours: (json['monthly_hours'] as List)
          .map((e) => MonthlyHoursData.fromJson(e as Map<String, dynamic>))
          .toList(),
      leaveBreakdown: (json['leave_breakdown'] as List)
          .map((e) => LeaveBreakdownData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attendance_trend': attendanceTrend.map((e) => e.toJson()).toList(),
      'monthly_hours': monthlyHours.map((e) => e.toJson()).toList(),
      'leave_breakdown': leaveBreakdown.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [attendanceTrend, monthlyHours, leaveBreakdown];
}

/// Attendance Trend Data (for line chart)
class AttendanceTrendData extends Equatable {
  final String date;
  final String day;
  final double hours;
  final String status;

  const AttendanceTrendData({
    required this.date,
    required this.day,
    required this.hours,
    required this.status,
  });

  factory AttendanceTrendData.fromJson(Map<String, dynamic> json) {
    return AttendanceTrendData(
      date: json['date'] as String,
      day: json['day'] as String,
      hours: json['hours'] != null
          ? (json['hours'] is String
              ? double.tryParse(json['hours'] as String) ?? 0.0
              : (json['hours'] as num).toDouble())
          : 0.0,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'day': day,
      'hours': hours,
      'status': status,
    };
  }

  @override
  List<Object?> get props => [date, day, hours, status];
}

/// Monthly Hours Data (for bar chart)
class MonthlyHoursData extends Equatable {
  final String month;
  final String year;
  final double hours;

  const MonthlyHoursData({
    required this.month,
    required this.year,
    required this.hours,
  });

  factory MonthlyHoursData.fromJson(Map<String, dynamic> json) {
    return MonthlyHoursData(
      month: json['month'] as String,
      year: json['year'] as String,
      hours: json['hours'] != null
          ? (json['hours'] is String
              ? double.tryParse(json['hours'] as String) ?? 0.0
              : (json['hours'] as num).toDouble())
          : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'month': month,
      'year': year,
      'hours': hours,
    };
  }

  @override
  List<Object?> get props => [month, year, hours];
}

/// Leave Breakdown Data (for pie chart)
class LeaveBreakdownData extends Equatable {
  final String type;
  final int total;
  final int used;
  final int remaining;

  const LeaveBreakdownData({
    required this.type,
    required this.total,
    required this.used,
    required this.remaining,
  });

  factory LeaveBreakdownData.fromJson(Map<String, dynamic> json) {
    return LeaveBreakdownData(
      type: json['type'] as String,
      total: json['total'] as int,
      used: json['used'] as int,
      remaining: json['remaining'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'total': total,
      'used': used,
      'remaining': remaining,
    };
  }

  @override
  List<Object?> get props => [type, total, used, remaining];
}
