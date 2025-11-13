import 'package:equatable/equatable.dart';
import '../../../branches/data/models/branch_model.dart';

/// Helper function to convert late_minutes from various types to int
int? _lateMinutesFromJson(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.round();
  if (value is String) return int.tryParse(value);
  return null;
}

/// Attendance Model
///
/// Represents an attendance record
class AttendanceModel extends Equatable {
  final int? id;
  final String? checkInTime;
  final String? checkOutTime;
  final double? workingHours;
  final String date;
  final String? message;
  final String? lateReason; // NEW: Late reason field
  final int? lateMinutes; // NEW: Late duration in minutes

  const AttendanceModel({
    this.id,
    this.checkInTime,
    this.checkOutTime,
    this.workingHours,
    required this.date,
    this.message,
    this.lateReason,
    this.lateMinutes,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] as int?,
      checkInTime: json['check_in_time'] != null && json['check_in_time'] != ''
          ? json['check_in_time'] as String
          : null,
      checkOutTime: json['check_out_time'] != null && json['check_out_time'] != ''
          ? json['check_out_time'] as String
          : null,
      workingHours: json['working_hours'] != null
          ? (json['working_hours'] is String
              ? double.tryParse(json['working_hours'] as String) ?? 0.0
              : (json['working_hours'] is int
                  ? (json['working_hours'] as int).toDouble()
                  : json['working_hours'] as double))
          : null,
      date: json['date'] as String,
      message: json['message'] as String?,
      lateReason: json['late_reason'] as String?,
      lateMinutes: _lateMinutesFromJson(json['late_minutes']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'check_in_time': checkInTime,
      'check_out_time': checkOutTime,
      'working_hours': workingHours,
      'date': date,
      'message': message,
      if (lateReason != null) 'late_reason': lateReason,
      if (lateMinutes != null) 'late_minutes': lateMinutes,
    };
  }

  @override
  List<Object?> get props => [
        id,
        checkInTime,
        checkOutTime,
        workingHours,
        date,
        message,
        lateReason,
        lateMinutes,
      ];
}

/// Work Plan Model
///
/// Represents employee's work plan/schedule
class WorkPlanModel extends Equatable {
  final String name;
  final String? startTime;
  final String? endTime;
  final String schedule;
  final int permissionMinutes;
  final bool lateDetectionEnabled; // NEW: Enable/disable late detection

  const WorkPlanModel({
    required this.name,
    this.startTime,
    this.endTime,
    required this.schedule,
    this.permissionMinutes = 0,
    this.lateDetectionEnabled = true, // Default: enabled
  });

  factory WorkPlanModel.fromJson(Map<String, dynamic> json) {
    return WorkPlanModel(
      name: json['name'] as String,
      startTime: json['start_time'] as String?,
      endTime: json['end_time'] as String?,
      schedule: json['schedule'] as String,
      permissionMinutes: json['permission_minutes'] as int? ?? 0,
      lateDetectionEnabled: _parseBool(json['late_detection_enabled']) ?? true,
    );
  }

  /// Helper method to parse boolean from API (handles both int and bool)
  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value == '1' || value.toLowerCase() == 'true';
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      'schedule': schedule,
      'permission_minutes': permissionMinutes,
      'late_detection_enabled': lateDetectionEnabled,
    };
  }

  @override
  List<Object?> get props => [name, startTime, endTime, schedule, permissionMinutes, lateDetectionEnabled];
}

/// Attendance Status Model
///
/// Represents today's attendance status with sessions support
class AttendanceStatusModel extends Equatable {
  final bool hasCheckedIn;
  final bool? hasCheckedOut;
  final bool? hasActiveSession;
  final bool hasLateReason; // Whether employee HAS PROVIDED late reason (true = provided, false = not provided yet)
  final String? checkInTime;
  final String? checkOutTime;
  final double workingHours;
  final String? workingHoursLabel;
  final int lateMinutes;
  final String? lateLabel;
  final String date;
  final String duration;
  final WorkPlanModel? workPlan;

  // New fields for multiple sessions
  final CurrentSessionModel? currentSession;
  final SessionsSummaryResponseModel? sessionsSummary;
  final DailySummaryModel? dailySummary;

  // Branch information for geofencing
  final BranchModel? branch;

  const AttendanceStatusModel({
    required this.hasCheckedIn,
    this.hasCheckedOut,
    this.hasActiveSession,
    this.hasLateReason = false, // Default: false (hasn't provided yet)
    this.checkInTime,
    this.checkOutTime,
    required this.workingHours,
    this.workingHoursLabel,
    this.lateMinutes = 0,
    this.lateLabel,
    required this.date,
    this.duration = '00:00:00',
    this.workPlan,
    this.currentSession,
    this.sessionsSummary,
    this.dailySummary,
    this.branch,
  });

  factory AttendanceStatusModel.fromJson(Map<String, dynamic> json) {
    return AttendanceStatusModel(
      hasCheckedIn: json['has_checked_in'] as bool,
      hasCheckedOut: json['has_checked_out'] as bool?,
      hasActiveSession: json['has_active_session'] as bool?,
      hasLateReason: json['has_late_reason'] as bool? ?? false,
      checkInTime: json['check_in_time'] as String?,
      checkOutTime: json['check_out_time'] as String?,
      workingHours: json['working_hours'] != null
          ? (json['working_hours'] is String
              ? double.tryParse(json['working_hours'] as String) ?? 0.0
              : (json['working_hours'] is int
                  ? (json['working_hours'] as int).toDouble()
                  : json['working_hours'] as double))
          : 0.0,
      workingHoursLabel: json['working_hours_label'] as String?,
      lateMinutes: _lateMinutesFromJson(json['late_minutes']) ?? 0,
      lateLabel: json['late_label'] as String?,
      date: json['date'] as String,
      duration: json['duration'] as String? ?? '00:00:00',
      workPlan: json['work_plan'] != null
          ? WorkPlanModel.fromJson(json['work_plan'] as Map<String, dynamic>)
          : null,
      currentSession: json['current_session'] != null
          ? CurrentSessionModel.fromJson(json['current_session'] as Map<String, dynamic>)
          : null,
      sessionsSummary: json['sessions_summary'] != null
          ? SessionsSummaryResponseModel.fromJson(json['sessions_summary'] as Map<String, dynamic>)
          : null,
      dailySummary: json['daily_summary'] != null
          ? DailySummaryModel.fromJson(json['daily_summary'] as Map<String, dynamic>)
          : null,
      branch: json['branch'] != null
          ? BranchModel.fromJson(json['branch'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'has_checked_in': hasCheckedIn,
      if (hasCheckedOut != null) 'has_checked_out': hasCheckedOut,
      if (hasActiveSession != null) 'has_active_session': hasActiveSession,
      'has_late_reason': hasLateReason,
      'check_in_time': checkInTime,
      'check_out_time': checkOutTime,
      'working_hours': workingHours,
      'working_hours_label': workingHoursLabel,
      'late_minutes': lateMinutes,
      'late_label': lateLabel,
      'date': date,
      'duration': duration,
      'work_plan': workPlan?.toJson(),
      'current_session': currentSession?.toJson(),
      'sessions_summary': sessionsSummary?.toJson(),
      'daily_summary': dailySummary?.toJson(),
      'branch': branch?.toJson(),
    };
  }

  String get workingHoursFormatted =>
      workingHoursLabel ?? '${workingHours.toStringAsFixed(1)}h';

  String get lateMinutesFormatted {
    if (lateLabel != null) return lateLabel!;
    if (lateMinutes == 0) return 'On time';

    final hours = lateMinutes ~/ 60;
    final minutes = lateMinutes % 60;

    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m late';
    } else if (hours > 0) {
      return '${hours}h late';
    } else {
      return '${minutes}m late';
    }
  }
  
  /// Get total duration including all sessions
  String get totalDuration => sessionsSummary?.totalDuration ?? duration;
  
  /// Get total hours from all sessions
  double get totalHours => sessionsSummary?.totalHours ?? workingHours;

  @override
  List<Object?> get props => [
        hasCheckedIn,
        hasCheckedOut,
        hasActiveSession,
        hasLateReason,
        checkInTime,
        checkOutTime,
        workingHours,
        workingHoursLabel,
        lateMinutes,
        lateLabel,
        date,
        duration,
        workPlan,
        currentSession,
        sessionsSummary,
        dailySummary,
        branch,
      ];
}

/// Current Session Model
class CurrentSessionModel extends Equatable {
  final int sessionId;
  final String checkInTime;
  final String duration;

  const CurrentSessionModel({
    required this.sessionId,
    required this.checkInTime,
    required this.duration,
  });

  factory CurrentSessionModel.fromJson(Map<String, dynamic> json) {
    return CurrentSessionModel(
      sessionId: json['session_id'] as int,
      checkInTime: json['check_in_time'] as String,
      duration: json['duration'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session_id': sessionId,
      'check_in_time': checkInTime,
      'duration': duration,
    };
  }

  @override
  List<Object?> get props => [sessionId, checkInTime, duration];
}

/// Sessions Summary Response Model
class SessionsSummaryResponseModel extends Equatable {
  final int totalSessions;
  final int completedSessions;
  final String totalDuration;
  final double totalHours;

  const SessionsSummaryResponseModel({
    required this.totalSessions,
    required this.completedSessions,
    required this.totalDuration,
    required this.totalHours,
  });

  factory SessionsSummaryResponseModel.fromJson(Map<String, dynamic> json) {
    return SessionsSummaryResponseModel(
      totalSessions: json['total_sessions'] as int? ?? 0,
      completedSessions: json['completed_sessions'] as int? ?? 0,
      totalDuration: json['total_duration'] as String? ?? '0h 0m',
      totalHours: json['total_hours'] != null
          ? (json['total_hours'] is String
              ? double.tryParse(json['total_hours'] as String) ?? 0.0
              : (json['total_hours'] is int
                  ? (json['total_hours'] as int).toDouble()
                  : json['total_hours'] as double))
          : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_sessions': totalSessions,
      'completed_sessions': completedSessions,
      'total_duration': totalDuration,
      'total_hours': totalHours,
    };
  }

  String get formattedHours => '${totalHours.toStringAsFixed(1)}h';

  @override
  List<Object?> get props => [totalSessions, completedSessions, totalDuration, totalHours];
}

/// Daily Summary Model
class DailySummaryModel extends Equatable {
  final String? checkInTime;
  final String? checkOutTime;
  final double workingHours;
  final String workingHoursLabel;
  final int lateMinutes;
  final String lateLabel;

  const DailySummaryModel({
    this.checkInTime,
    this.checkOutTime,
    required this.workingHours,
    required this.workingHoursLabel,
    required this.lateMinutes,
    required this.lateLabel,
  });

  factory DailySummaryModel.fromJson(Map<String, dynamic> json) {
    return DailySummaryModel(
      checkInTime: json['check_in_time'] as String?,
      checkOutTime: json['check_out_time'] as String?,
      workingHours: json['working_hours'] != null
          ? (json['working_hours'] is String
              ? double.tryParse(json['working_hours'] as String) ?? 0.0
              : (json['working_hours'] is int
                  ? (json['working_hours'] as int).toDouble()
                  : json['working_hours'] as double))
          : 0.0,
      workingHoursLabel: json['working_hours_label'] as String,
      lateMinutes: _lateMinutesFromJson(json['late_minutes']) ?? 0,
      lateLabel: json['late_label'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'check_in_time': checkInTime,
      'check_out_time': checkOutTime,
      'working_hours': workingHours,
      'working_hours_label': workingHoursLabel,
      'late_minutes': lateMinutes,
      'late_label': lateLabel,
    };
  }

  @override
  List<Object?> get props => [checkInTime, checkOutTime, workingHours, workingHoursLabel, lateMinutes, lateLabel];
}

/// Attendance Record Model
///
/// Comprehensive attendance record with all fields from the backend
/// Used for attendance history
class AttendanceRecordModel extends Equatable {
  final int id;
  final int employeeId;
  final int? workPlanId;
  final String date;
  final String? checkInTime;
  final String? checkOutTime;
  final double workingHours;
  final double missingHours;
  final int lateMinutes;
  final String? notes;
  final bool isManual;
  final String? createdAt;
  final String? updatedAt;

  const AttendanceRecordModel({
    required this.id,
    required this.employeeId,
    this.workPlanId,
    required this.date,
    this.checkInTime,
    this.checkOutTime,
    this.workingHours = 0.0,
    this.missingHours = 0.0,
    this.lateMinutes = 0,
    this.notes,
    this.isManual = false,
    this.createdAt,
    this.updatedAt,
  });

  /// Check if checked in
  bool get hasCheckedIn => checkInTime != null;

  /// Check if checked out
  bool get hasCheckedOut => checkOutTime != null;

  /// Is completed (both check-in and check-out)
  bool get isCompleted => hasCheckedIn && hasCheckedOut;

  /// Formatted working hours
  String get workingHoursFormatted => '${workingHours.toStringAsFixed(1)}h';

  /// Formatted missing hours
  String get missingHoursFormatted => '${missingHours.toStringAsFixed(1)}h';

  /// Formatted late minutes
  String get lateMinutesFormatted {
    if (lateMinutes == 0) return 'On time';

    final hours = lateMinutes ~/ 60;
    final minutes = lateMinutes % 60;

    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m late';
    } else if (hours > 0) {
      return '${hours}h late';
    } else {
      return '${minutes}m late';
    }
  }

  /// Status text for display
  String get statusText {
    if (!hasCheckedIn) return 'Absent';
    if (!hasCheckedOut) return 'In Progress';
    return 'Completed';
  }

  /// Status color indicator
  String get statusColor {
    if (!hasCheckedIn) return 'error';
    if (!hasCheckedOut) return 'warning';
    if (lateMinutes > 0) return 'warning';
    return 'success';
  }

  factory AttendanceRecordModel.fromJson(Map<String, dynamic> json) {
    return AttendanceRecordModel(
      id: json['id'] as int,
      employeeId: json['employee_id'] as int,
      workPlanId: json['work_plan_id'] as int?,
      date: json['date'] as String,
      checkInTime: json['check_in_time'] as String?,
      checkOutTime: json['check_out_time'] as String?,
      workingHours: json['working_hours'] != null
          ? (json['working_hours'] is String
              ? double.tryParse(json['working_hours'] as String) ?? 0.0
              : (json['working_hours'] as num).toDouble())
          : 0.0,
      missingHours: json['missing_hours'] != null
          ? (json['missing_hours'] is String
              ? double.tryParse(json['missing_hours'] as String) ?? 0.0
              : (json['missing_hours'] as num).toDouble())
          : 0.0,
      lateMinutes: _lateMinutesFromJson(json['late_minutes']) ?? 0,
      notes: json['notes'] as String?,
      isManual: json['is_manual'] as bool? ?? false,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'work_plan_id': workPlanId,
      'date': date,
      'check_in_time': checkInTime,
      'check_out_time': checkOutTime,
      'working_hours': workingHours,
      'missing_hours': missingHours,
      'late_minutes': lateMinutes,
      'notes': notes,
      'is_manual': isManual,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  List<Object?> get props => [
        id,
        employeeId,
        workPlanId,
        date,
        checkInTime,
        checkOutTime,
        workingHours,
        missingHours,
        lateMinutes,
        notes,
        isManual,
        createdAt,
        updatedAt,
      ];
}
