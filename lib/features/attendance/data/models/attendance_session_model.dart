import 'package:json_annotation/json_annotation.dart';

part 'attendance_session_model.g.dart';

/// Attendance Session Model
///
/// Represents a single check-in/check-out session within a day
@JsonSerializable()
class AttendanceSessionModel {
  final int id;

  @JsonKey(name: 'attendance_id')
  final int? attendanceId;

  final String date;

  @JsonKey(name: 'check_in_time')
  final String checkInTime;

  @JsonKey(name: 'check_out_time')
  final String? checkOutTime;

  @JsonKey(name: 'duration_hours')
  final double? durationHours;

  @JsonKey(name: 'duration_label')
  final String? durationLabel;

  @JsonKey(name: 'session_type')
  final String? sessionType;

  final String? notes;

  @JsonKey(name: 'is_active')
  final bool? isActive;

  AttendanceSessionModel({
    required this.id,
    this.attendanceId,
    required this.date,
    required this.checkInTime,
    this.checkOutTime,
    this.durationHours,
    this.durationLabel,
    this.sessionType,
    this.notes,
    this.isActive,
  });

  factory AttendanceSessionModel.fromJson(Map<String, dynamic> json) =>
      _$AttendanceSessionModelFromJson(json);

  Map<String, dynamic> toJson() => _$AttendanceSessionModelToJson(this);

  /// Get session type display name
  String get sessionTypeDisplay {
    switch (sessionType) {
      case 'regular':
        return 'Regular';
      case 'overtime':
        return 'Overtime';
      case 'break':
        return 'Break';
      default:
        return sessionType ?? 'Regular';
    }
  }

  /// Check if session is currently active
  bool get active => (isActive ?? false) || checkOutTime == null;

  /// Get formatted duration
  String get formattedDuration => durationLabel ?? '0h';
}

/// Sessions Summary Model
@JsonSerializable()
class SessionsSummaryModel {
  @JsonKey(name: 'total_sessions')
  final int totalSessions;

  @JsonKey(name: 'active_sessions')
  final int activeSessions;

  @JsonKey(name: 'completed_sessions')
  final int completedSessions;

  @JsonKey(name: 'total_duration')
  final String totalDuration;

  @JsonKey(name: 'total_hours')
  final double totalHours;

  SessionsSummaryModel({
    required this.totalSessions,
    required this.activeSessions,
    required this.completedSessions,
    required this.totalDuration,
    required this.totalHours,
  });

  factory SessionsSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$SessionsSummaryModelFromJson(json);

  Map<String, dynamic> toJson() => _$SessionsSummaryModelToJson(this);

  /// Get formatted total hours
  String get formattedHours => '${totalHours.toStringAsFixed(1)}h';
}

/// Today Sessions Data Model
@JsonSerializable()
class TodaySessionsDataModel {
  final List<AttendanceSessionModel> sessions;
  final SessionsSummaryModel summary;

  TodaySessionsDataModel({
    required this.sessions,
    required this.summary,
  });

  factory TodaySessionsDataModel.fromJson(Map<String, dynamic> json) =>
      _$TodaySessionsDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$TodaySessionsDataModelToJson(this);

  /// Get active session if exists
  AttendanceSessionModel? get activeSession {
    try {
      return sessions.firstWhere((s) => s.active);
    } catch (e) {
      return null;
    }
  }

  /// Check if has active session
  bool get hasActiveSession => activeSession != null;

  /// Get completed sessions
  List<AttendanceSessionModel> get completedSessions =>
      sessions.where((s) => !s.active).toList();
}

/// Today Sessions Response Model
@JsonSerializable()
class TodaySessionsResponseModel {
  final TodaySessionsDataModel data;
  final String? message;
  final int status;

  TodaySessionsResponseModel({
    required this.data,
    this.message,
    required this.status,
  });

  factory TodaySessionsResponseModel.fromJson(Map<String, dynamic> json) =>
      _$TodaySessionsResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$TodaySessionsResponseModelToJson(this);
}
