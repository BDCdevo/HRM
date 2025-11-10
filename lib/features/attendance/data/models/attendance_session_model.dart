import 'package:json_annotation/json_annotation.dart';

part 'attendance_session_model.g.dart';

/// Custom converter for duration_hours that handles both String and num
class DurationHoursConverter implements JsonConverter<double?, dynamic> {
  const DurationHoursConverter();

  @override
  double? fromJson(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  @override
  dynamic toJson(double? value) => value;
}

/// Attendance Session Model
///
/// Represents a single check-in/check-out session within a day
@JsonSerializable()
class AttendanceSessionModel {
  @JsonKey(defaultValue: 0)
  final int id;

  @JsonKey(name: 'attendance_id')
  final int? attendanceId;

  @JsonKey(defaultValue: '')
  final String date;

  @JsonKey(name: 'check_in_time', defaultValue: '')
  final String checkInTime;

  @JsonKey(name: 'check_out_time')
  final String? checkOutTime;

  @JsonKey(name: 'duration_hours')
  @DurationHoursConverter()
  final double? durationHours;

  @JsonKey(name: 'duration_label')
  final String? durationLabel;

  @JsonKey(name: 'session_type')
  final String? sessionType;

  final String? notes;

  @JsonKey(name: 'is_active')
  final bool? isActive;

  AttendanceSessionModel({
    this.id = 0,
    this.attendanceId,
    this.date = '',
    this.checkInTime = '',
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
  @JsonKey(name: 'total_sessions', defaultValue: 0)
  final int totalSessions;

  @JsonKey(name: 'active_sessions', defaultValue: 0)
  final int activeSessions;

  @JsonKey(name: 'completed_sessions', defaultValue: 0)
  final int completedSessions;

  @JsonKey(name: 'total_duration', defaultValue: '0h 0m')
  final String totalDuration;

  @JsonKey(name: 'total_hours')
  @DurationHoursConverter()
  final double? totalHours;  // Made nullable to handle null from API

  SessionsSummaryModel({
    this.totalSessions = 0,
    this.activeSessions = 0,
    this.completedSessions = 0,
    this.totalDuration = '0h 0m',
    this.totalHours,
  });

  factory SessionsSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$SessionsSummaryModelFromJson(json);

  Map<String, dynamic> toJson() => _$SessionsSummaryModelToJson(this);

  /// Get formatted total hours
  String get formattedHours => '${(totalHours ?? 0.0).toStringAsFixed(1)}h';
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
  @JsonKey(defaultValue: 200)
  final int status;

  TodaySessionsResponseModel({
    required this.data,
    this.message,
    this.status = 200,
  });

  factory TodaySessionsResponseModel.fromJson(Map<String, dynamic> json) =>
      _$TodaySessionsResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$TodaySessionsResponseModelToJson(this);
}
