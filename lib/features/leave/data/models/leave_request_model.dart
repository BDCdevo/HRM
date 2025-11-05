import 'package:equatable/equatable.dart';

/// Leave Request Model
///
/// Represents an employee's leave/vacation request
class LeaveRequestModel extends Equatable {
  final int id;
  final VacationTypeInfo? vacationType;
  final String? startDate;
  final String? endDate;
  final int? totalDays;
  final String status;
  final String? reason;
  final String? adminNotes;
  final String? requestDate;
  final String? approvedAt;
  final String? approverName;
  final bool canCancel;

  const LeaveRequestModel({
    required this.id,
    this.vacationType,
    this.startDate,
    this.endDate,
    this.totalDays,
    required this.status,
    this.reason,
    this.adminNotes,
    this.requestDate,
    this.approvedAt,
    this.approverName,
    required this.canCancel,
  });

  factory LeaveRequestModel.fromJson(Map<String, dynamic> json) {
    // Handle vacation_type as either String or Object
    VacationTypeInfo? vacationType;
    if (json['vacation_type'] != null) {
      if (json['vacation_type'] is Map) {
        vacationType = VacationTypeInfo.fromJson(json['vacation_type']);
      } else if (json['vacation_type'] is String) {
        // Create a simple VacationTypeInfo from string name
        vacationType = VacationTypeInfo(
          id: 0,
          name: json['vacation_type'] as String,
          description: null,
        );
      }
    }

    // Handle both total_days and duration_days
    final totalDays = (json['total_days'] as int?) ?? (json['duration_days'] as int?);

    // Handle both admin_notes and notes
    final notes = (json['admin_notes'] as String?) ?? (json['notes'] as String?);

    // Handle both request_date and created_at
    final requestDate = (json['request_date'] as String?) ?? (json['created_at'] as String?);

    // Determine if can cancel (pending/approved and not started)
    bool canCancel = json['can_cancel'] as bool? ?? false;
    if (!canCancel && json['status'] != null) {
      final status = json['status'] as String;
      final startDate = json['start_date'] as String?;
      if ((status == 'pending' || status == 'approved') && startDate != null) {
        try {
          final startDateTime = DateTime.parse(startDate);
          canCancel = startDateTime.isAfter(DateTime.now());
        } catch (e) {
          canCancel = false;
        }
      }
    }

    return LeaveRequestModel(
      id: json['id'] as int,
      vacationType: vacationType,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      totalDays: totalDays,
      status: json['status'] as String,
      reason: json['reason'] as String?,
      adminNotes: notes,
      requestDate: requestDate,
      approvedAt: json['approved_at'] as String?,
      approverName: json['approver_name'] as String?,
      canCancel: canCancel,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vacation_type': vacationType?.toJson(),
      'start_date': startDate,
      'end_date': endDate,
      'total_days': totalDays,
      'status': status,
      'reason': reason,
      'admin_notes': adminNotes,
      'request_date': requestDate,
      'approved_at': approvedAt,
      'approver_name': approverName,
      'can_cancel': canCancel,
    };
  }

  @override
  List<Object?> get props => [
        id,
        vacationType,
        startDate,
        endDate,
        totalDays,
        status,
        reason,
        adminNotes,
        requestDate,
        approvedAt,
        approverName,
        canCancel,
      ];

  /// Helper getters
  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
  bool get isCancelled => status == 'cancelled';

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  String get statusText => statusLabel;

  // Import flutter material for Color
  dynamic get statusColor {
    // Using dynamic to avoid importing material package in model
    // Will be properly typed in UI layer
    switch (status) {
      case 'approved':
        return 'success'; // Green
      case 'pending':
        return 'warning'; // Orange
      case 'rejected':
        return 'error'; // Red
      case 'cancelled':
        return 'secondary'; // Gray
      default:
        return 'secondary';
    }
  }

  dynamic get statusIcon {
    // Using dynamic to avoid importing material package in model
    switch (status) {
      case 'approved':
        return 'check_circle';
      case 'pending':
        return 'access_time';
      case 'rejected':
        return 'cancel';
      case 'cancelled':
        return 'block';
      default:
        return 'help';
    }
  }

  String? get vacationTypeName => vacationType?.name;
  String? get notes => adminNotes;

  String get durationFormatted {
    if (totalDays == null) return '-';
    return totalDays == 1 ? '1 day' : '$totalDays days';
  }

  String get dateRangeFormatted {
    if (startDate == null || endDate == null) return '-';
    if (startDate == endDate) return _formatDate(startDate!);
    return '${_formatDate(startDate!)} - ${_formatDate(endDate!)}';
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}

/// Vacation Type Info (nested in LeaveRequestModel)
class VacationTypeInfo extends Equatable {
  final int id;
  final String name;
  final String? description;

  const VacationTypeInfo({
    required this.id,
    required this.name,
    this.description,
  });

  factory VacationTypeInfo.fromJson(Map<String, dynamic> json) {
    return VacationTypeInfo(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }

  @override
  List<Object?> get props => [id, name, description];
}
