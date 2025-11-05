// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_session_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AttendanceSessionModel _$AttendanceSessionModelFromJson(
  Map<String, dynamic> json,
) => AttendanceSessionModel(
  id: (json['id'] as num).toInt(),
  attendanceId: (json['attendance_id'] as num?)?.toInt(),
  date: json['date'] as String,
  checkInTime: json['check_in_time'] as String,
  checkOutTime: json['check_out_time'] as String?,
  durationHours: (json['duration_hours'] as num?)?.toDouble(),
  durationLabel: json['duration_label'] as String?,
  sessionType: json['session_type'] as String?,
  notes: json['notes'] as String?,
  isActive: json['is_active'] as bool?,
);

Map<String, dynamic> _$AttendanceSessionModelToJson(
  AttendanceSessionModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'attendance_id': instance.attendanceId,
  'date': instance.date,
  'check_in_time': instance.checkInTime,
  'check_out_time': instance.checkOutTime,
  'duration_hours': instance.durationHours,
  'duration_label': instance.durationLabel,
  'session_type': instance.sessionType,
  'notes': instance.notes,
  'is_active': instance.isActive,
};

SessionsSummaryModel _$SessionsSummaryModelFromJson(
  Map<String, dynamic> json,
) => SessionsSummaryModel(
  totalSessions: (json['total_sessions'] as num).toInt(),
  activeSessions: (json['active_sessions'] as num).toInt(),
  completedSessions: (json['completed_sessions'] as num).toInt(),
  totalDuration: json['total_duration'] as String,
  totalHours: (json['total_hours'] as num).toDouble(),
);

Map<String, dynamic> _$SessionsSummaryModelToJson(
  SessionsSummaryModel instance,
) => <String, dynamic>{
  'total_sessions': instance.totalSessions,
  'active_sessions': instance.activeSessions,
  'completed_sessions': instance.completedSessions,
  'total_duration': instance.totalDuration,
  'total_hours': instance.totalHours,
};

TodaySessionsDataModel _$TodaySessionsDataModelFromJson(
  Map<String, dynamic> json,
) => TodaySessionsDataModel(
  sessions: (json['sessions'] as List<dynamic>)
      .map((e) => AttendanceSessionModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  summary: SessionsSummaryModel.fromJson(json['summary'] as Map<String, dynamic>),
);

Map<String, dynamic> _$TodaySessionsDataModelToJson(
  TodaySessionsDataModel instance,
) => <String, dynamic>{
  'sessions': instance.sessions,
  'summary': instance.summary,
};

TodaySessionsResponseModel _$TodaySessionsResponseModelFromJson(
  Map<String, dynamic> json,
) => TodaySessionsResponseModel(
  data: TodaySessionsDataModel.fromJson(json['data'] as Map<String, dynamic>),
  message: json['message'] as String?,
  status: (json['status'] as num).toInt(),
);

Map<String, dynamic> _$TodaySessionsResponseModelToJson(
  TodaySessionsResponseModel instance,
) => <String, dynamic>{
  'data': instance.data,
  'message': instance.message,
  'status': instance.status,
};
