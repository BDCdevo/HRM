import 'package:equatable/equatable.dart';
import 'attendance_model.dart';

/// Attendance Response Model
///
/// Wraps the attendance data from the API (with session support)
class AttendanceResponseModel extends Equatable {
  final bool success;
  final String message;
  final AttendanceModel data;
  final Map<String, dynamic>? session;

  const AttendanceResponseModel({
    required this.success,
    required this.message,
    required this.data,
    this.session,
  });

  factory AttendanceResponseModel.fromJson(Map<String, dynamic> json) {
    // Handle both old format and new session-based format
    final dataField = json['data'] as Map<String, dynamic>;

    // New format: data contains 'attendance' and 'session'
    if (dataField.containsKey('attendance')) {
      return AttendanceResponseModel(
        success: json['status'] == 'success' || json['success'] == true,
        message: json['message'] as String? ?? '',
        data: AttendanceModel.fromJson(dataField['attendance'] as Map<String, dynamic>),
        session: dataField['session'] as Map<String, dynamic>?,
      );
    }

    // Old format: data contains attendance directly
    return AttendanceResponseModel(
      success: json['status'] == 'success' || json['success'] == true,
      message: json['message'] as String? ?? '',
      data: AttendanceModel.fromJson(dataField),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.toJson(),
      if (session != null) 'session': session,
    };
  }

  @override
  List<Object?> get props => [success, message, data, session];
}

/// Attendance Status Response Model
///
/// Wraps the attendance status data from the API
class AttendanceStatusResponseModel extends Equatable {
  final bool success;
  final String message;
  final AttendanceStatusModel data;

  const AttendanceStatusResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory AttendanceStatusResponseModel.fromJson(Map<String, dynamic> json) {
    return AttendanceStatusResponseModel(
      success: json['status'] == 'success' || json['success'] == true,
      message: json['message'] as String? ?? '',
      data: AttendanceStatusModel.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.toJson(),
    };
  }

  @override
  List<Object?> get props => [success, message, data];
}
