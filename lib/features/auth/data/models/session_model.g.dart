// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SessionModel _$SessionModelFromJson(Map<String, dynamic> json) => SessionModel(
  id: (json['id'] as num).toInt(),
  userId: (json['user_id'] as num).toInt(),
  userType: json['user_type'] as String,
  companyId: (json['company_id'] as num?)?.toInt(),
  sessionToken: json['session_token'] as String?,
  loginTime: json['login_time'] as String,
  logoutTime: json['logout_time'] as String?,
  sessionDuration: (json['session_duration'] as num?)?.toInt(),
  status: json['status'] as String,
  deviceType: json['device_type'] as String?,
  deviceModel: json['device_model'] as String?,
  deviceId: json['device_id'] as String?,
  osVersion: json['os_version'] as String?,
  appVersion: json['app_version'] as String?,
  ipAddress: json['ip_address'] as String?,
  userAgent: json['user_agent'] as String?,
  loginLatitude: (json['login_latitude'] as num?)?.toDouble(),
  loginLongitude: (json['login_longitude'] as num?)?.toDouble(),
  loginMethod: json['login_method'] as String?,
  notes: json['notes'] as String?,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$SessionModelToJson(SessionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'user_type': instance.userType,
      'company_id': instance.companyId,
      'session_token': instance.sessionToken,
      'login_time': instance.loginTime,
      'logout_time': instance.logoutTime,
      'session_duration': instance.sessionDuration,
      'status': instance.status,
      'device_type': instance.deviceType,
      'device_model': instance.deviceModel,
      'device_id': instance.deviceId,
      'os_version': instance.osVersion,
      'app_version': instance.appVersion,
      'ip_address': instance.ipAddress,
      'user_agent': instance.userAgent,
      'login_latitude': instance.loginLatitude,
      'login_longitude': instance.loginLongitude,
      'login_method': instance.loginMethod,
      'notes': instance.notes,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
