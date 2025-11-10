import 'package:equatable/equatable.dart';

/// Employee Attendance Model
///
/// Represents an employee's attendance record for a specific day
class EmployeeAttendanceModel extends Equatable {
  final int employeeId;
  final String employeeName;
  final String? role;
  final String? department;
  final String? avatarUrl;
  final String? avatarInitial;
  final bool isOnline;
  final String? checkInTime;
  final String? checkOutTime;
  final String? duration;
  final String status; // 'present', 'absent', 'late', 'checked_out'
  final bool hasLocation;
  final double? checkInLatitude;
  final double? checkInLongitude;
  final String? lateReason;

  const EmployeeAttendanceModel({
    required this.employeeId,
    required this.employeeName,
    this.role,
    this.department,
    this.avatarUrl,
    this.avatarInitial,
    this.isOnline = false,
    this.checkInTime,
    this.checkOutTime,
    this.duration,
    this.status = 'absent',
    this.hasLocation = false,
    this.checkInLatitude,
    this.checkInLongitude,
    this.lateReason,
  });

  /// Check if employee is late
  bool get isLate => status == 'late';

  /// Check if employee is present
  bool get isPresent => status == 'present' || status == 'late';

  /// Check if employee is absent
  bool get isAbsent => status == 'absent';

  /// Check if employee has checked out
  bool get hasCheckedOut => checkOutTime != null && checkOutTime!.isNotEmpty;

  /// Get formatted location
  String? get formattedLocation {
    if (checkInLatitude != null && checkInLongitude != null) {
      return '${checkInLatitude!.toStringAsFixed(6)}, ${checkInLongitude!.toStringAsFixed(6)}';
    }
    return null;
  }

  /// From JSON
  factory EmployeeAttendanceModel.fromJson(Map<String, dynamic> json) {
    return EmployeeAttendanceModel(
      employeeId: json['employee_id'] as int,
      employeeName: json['employee_name'] as String,
      role: json['role'] as String?,
      department: json['department'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      avatarInitial: json['avatar_initial'] as String?,
      isOnline: json['is_online'] as bool? ?? false,
      checkInTime: json['check_in_time'] as String?,
      checkOutTime: json['check_out_time'] as String?,
      duration: json['duration'] as String?,
      status: json['status'] as String? ?? 'absent',
      hasLocation: json['has_location'] as bool? ?? false,
      checkInLatitude: json['check_in_latitude'] != null
          ? (json['check_in_latitude'] is num
              ? (json['check_in_latitude'] as num).toDouble()
              : double.tryParse(json['check_in_latitude'].toString()))
          : null,
      checkInLongitude: json['check_in_longitude'] != null
          ? (json['check_in_longitude'] is num
              ? (json['check_in_longitude'] as num).toDouble()
              : double.tryParse(json['check_in_longitude'].toString()))
          : null,
      lateReason: json['late_reason'] as String?,
    );
  }

  /// To JSON
  Map<String, dynamic> toJson() {
    return {
      'employee_id': employeeId,
      'employee_name': employeeName,
      'role': role,
      'department': department,
      'avatar_url': avatarUrl,
      'avatar_initial': avatarInitial,
      'is_online': isOnline,
      'check_in_time': checkInTime,
      'check_out_time': checkOutTime,
      'duration': duration,
      'status': status,
      'has_location': hasLocation,
      'check_in_latitude': checkInLatitude,
      'check_in_longitude': checkInLongitude,
      'late_reason': lateReason,
    };
  }

  @override
  List<Object?> get props => [
        employeeId,
        employeeName,
        role,
        department,
        avatarUrl,
        avatarInitial,
        isOnline,
        checkInTime,
        checkOutTime,
        duration,
        status,
        hasLocation,
        checkInLatitude,
        checkInLongitude,
        lateReason,
      ];
}

/// Attendance Summary Model
class AttendanceSummaryModel extends Equatable {
  final String date;
  final int totalEmployees;
  final int checkedIn;
  final int absent;
  final List<EmployeeAttendanceModel> employees;

  const AttendanceSummaryModel({
    required this.date,
    required this.totalEmployees,
    required this.checkedIn,
    required this.absent,
    required this.employees,
  });

  /// From JSON
  factory AttendanceSummaryModel.fromJson(Map<String, dynamic> json) {
    return AttendanceSummaryModel(
      date: json['date'] as String,
      totalEmployees: json['total_employees'] as int,
      checkedIn: json['checked_in'] as int,
      absent: json['absent'] as int,
      employees: (json['employees'] as List)
          .map((e) => EmployeeAttendanceModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// To JSON
  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'total_employees': totalEmployees,
      'checked_in': checkedIn,
      'absent': absent,
      'employees': employees.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
        date,
        totalEmployees,
        checkedIn,
        absent,
        employees,
      ];
}
