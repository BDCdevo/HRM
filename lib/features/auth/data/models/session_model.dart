import 'package:json_annotation/json_annotation.dart';

part 'session_model.g.dart';

/// Session Model
///
/// Represents a login session with all tracking information
@JsonSerializable()
class SessionModel {
  final int id;

  @JsonKey(name: 'user_id')
  final int userId;

  @JsonKey(name: 'user_type')
  final String userType;

  @JsonKey(name: 'company_id')
  final int? companyId;

  // Session Info
  @JsonKey(name: 'session_token')
  final String? sessionToken;

  @JsonKey(name: 'login_time')
  final String loginTime;

  @JsonKey(name: 'logout_time')
  final String? logoutTime;

  @JsonKey(name: 'session_duration')
  final int? sessionDuration; // in seconds

  final String status; // active, logged_out, expired, forced_logout

  // Device Info
  @JsonKey(name: 'device_type')
  final String? deviceType;

  @JsonKey(name: 'device_model')
  final String? deviceModel;

  @JsonKey(name: 'device_id')
  final String? deviceId;

  @JsonKey(name: 'os_version')
  final String? osVersion;

  @JsonKey(name: 'app_version')
  final String? appVersion;

  // Network Info
  @JsonKey(name: 'ip_address')
  final String? ipAddress;

  @JsonKey(name: 'user_agent')
  final String? userAgent;

  // Location Info
  @JsonKey(name: 'login_latitude')
  final double? loginLatitude;

  @JsonKey(name: 'login_longitude')
  final double? loginLongitude;

  @JsonKey(name: 'login_method')
  final String? loginMethod;

  final String? notes;

  @JsonKey(name: 'created_at')
  final String? createdAt;

  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  SessionModel({
    required this.id,
    required this.userId,
    required this.userType,
    this.companyId,
    this.sessionToken,
    required this.loginTime,
    this.logoutTime,
    this.sessionDuration,
    required this.status,
    this.deviceType,
    this.deviceModel,
    this.deviceId,
    this.osVersion,
    this.appVersion,
    this.ipAddress,
    this.userAgent,
    this.loginLatitude,
    this.loginLongitude,
    this.loginMethod,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) =>
      _$SessionModelFromJson(json);

  Map<String, dynamic> toJson() => _$SessionModelToJson(this);

  /// Get formatted session duration
  String get durationFormatted {
    if (sessionDuration == null || sessionDuration == 0) {
      return status == 'active' ? 'Active' : '--';
    }

    final hours = sessionDuration! ~/ 3600;
    final minutes = (sessionDuration! % 3600) ~/ 60;

    if (hours > 0) {
      return '$hours ساعة و $minutes دقيقة';
    } else if (minutes > 0) {
      return '$minutes دقيقة';
    } else {
      return 'أقل من دقيقة';
    }
  }

  /// Get status in Arabic
  String get statusArabic {
    switch (status) {
      case 'active':
        return 'نشط';
      case 'logged_out':
        return 'تم الخروج';
      case 'expired':
        return 'منتهي';
      case 'forced_logout':
        return 'خروج إجباري';
      default:
        return status;
    }
  }

  /// Get device icon based on type
  String get deviceIcon {
    switch (deviceType?.toLowerCase()) {
      case 'android':
        return '🤖';
      case 'ios':
        return '🍎';
      case 'web':
        return '🌐';
      default:
        return '📱';
    }
  }

  /// Check if session is active
  bool get isActive => status == 'active';

  /// Get login date formatted
  String get loginDateFormatted {
    try {
      final date = DateTime.parse(loginTime);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
          '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return loginTime;
    }
  }

  /// Get logout date formatted
  String? get logoutDateFormatted {
    if (logoutTime == null) return null;

    try {
      final date = DateTime.parse(logoutTime!);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
          '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return logoutTime;
    }
  }

  @override
  String toString() {
    return 'SessionModel(id: $id, userId: $userId, status: $status, loginTime: $loginTime)';
  }
}
