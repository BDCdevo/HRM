import 'package:equatable/equatable.dart';
import 'attendance_model.dart';

/// Pagination Model
///
/// Represents pagination info from API
class PaginationModel extends Equatable {
  final int total;
  final int count;
  final int perPage;
  final int currentPage;
  final int totalPages;

  const PaginationModel({
    required this.total,
    required this.count,
    required this.perPage,
    required this.currentPage,
    required this.totalPages,
  });

  /// Has more pages
  bool get hasMore => currentPage < totalPages;

  /// Is first page
  bool get isFirstPage => currentPage == 1;

  /// Is last page
  bool get isLastPage => currentPage >= totalPages;

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      total: json['total'] as int,
      count: json['count'] as int,
      perPage: json['per_page'] as int,
      currentPage: json['current_page'] as int,
      totalPages: json['total_pages'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'count': count,
      'per_page': perPage,
      'current_page': currentPage,
      'total_pages': totalPages,
    };
  }

  @override
  List<Object?> get props => [
        total,
        count,
        perPage,
        currentPage,
        totalPages,
      ];
}

/// Attendance History Item Model
///
/// Individual attendance record in history
class AttendanceHistoryItemModel extends Equatable {
  final int id;
  final String date;
  final String dayName;
  final String? checkInTime;
  final String? checkOutTime;
  final double workingHours;
  final String workingHoursLabel;
  final double missingHours;
  final String missingHoursLabel;
  final int lateMinutes;
  final String lateLabel;
  final bool isManual;
  final String? notes;
  final WorkPlanModel? workPlan;

  const AttendanceHistoryItemModel({
    required this.id,
    required this.date,
    required this.dayName,
    this.checkInTime,
    this.checkOutTime,
    required this.workingHours,
    required this.workingHoursLabel,
    required this.missingHours,
    required this.missingHoursLabel,
    required this.lateMinutes,
    required this.lateLabel,
    this.isManual = false,
    this.notes,
    this.workPlan,
  });

  /// Check if checked in
  bool get hasCheckedIn => checkInTime != null;

  /// Check if checked out
  bool get hasCheckedOut => checkOutTime != null;

  /// Is completed (both check-in and check-out)
  bool get isCompleted => hasCheckedIn && hasCheckedOut;

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

  factory AttendanceHistoryItemModel.fromJson(Map<String, dynamic> json) {
    return AttendanceHistoryItemModel(
      id: json['id'] as int,
      date: json['date'] as String,
      dayName: json['day_name'] as String,
      checkInTime: json['check_in_time'] as String?,
      checkOutTime: json['check_out_time'] as String?,
      workingHours: json['working_hours'] != null
          ? (json['working_hours'] is String
              ? double.tryParse(json['working_hours'] as String) ?? 0.0
              : (json['working_hours'] is int
                  ? (json['working_hours'] as int).toDouble()
                  : (json['working_hours'] as num).toDouble()))
          : 0.0,
      workingHoursLabel: json['working_hours_label'] as String? ?? '0.0h',
      missingHours: json['missing_hours'] != null
          ? (json['missing_hours'] is String
              ? double.tryParse(json['missing_hours'] as String) ?? 0.0
              : (json['missing_hours'] is int
                  ? (json['missing_hours'] as int).toDouble()
                  : (json['missing_hours'] as num).toDouble()))
          : 0.0,
      missingHoursLabel: json['missing_hours_label'] as String? ?? '0.0h',
      lateMinutes: json['late_minutes'] as int? ?? 0,
      lateLabel: json['late_label'] as String? ?? 'On time',
      isManual: json['is_manual'] as bool? ?? false,
      notes: json['notes'] as String?,
      workPlan: json['work_plan'] != null
          ? WorkPlanModel.fromJson(json['work_plan'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'day_name': dayName,
      'check_in_time': checkInTime,
      'check_out_time': checkOutTime,
      'working_hours': workingHours,
      'working_hours_label': workingHoursLabel,
      'missing_hours': missingHours,
      'missing_hours_label': missingHoursLabel,
      'late_minutes': lateMinutes,
      'late_label': lateLabel,
      'is_manual': isManual,
      'notes': notes,
      'work_plan': workPlan?.toJson(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        date,
        dayName,
        checkInTime,
        checkOutTime,
        workingHours,
        workingHoursLabel,
        missingHours,
        missingHoursLabel,
        lateMinutes,
        lateLabel,
        isManual,
        notes,
        workPlan,
      ];
}

/// Attendance History Response Model
///
/// Represents paginated attendance history response from API
class AttendanceHistoryModel extends Equatable {
  final List<AttendanceHistoryItemModel> items;
  final PaginationModel pagination;

  const AttendanceHistoryModel({
    required this.items,
    required this.pagination,
  });

  /// Has more pages
  bool get hasMore => pagination.hasMore;

  /// Is first page
  bool get isFirstPage => pagination.isFirstPage;

  /// Is last page
  bool get isLastPage => pagination.isLastPage;

  /// Total pages
  int get totalPages => pagination.totalPages;

  /// Current page
  int get currentPage => pagination.currentPage;

  factory AttendanceHistoryModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;

    return AttendanceHistoryModel(
      items: (data['items'] as List)
          .map((item) =>
              AttendanceHistoryItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      pagination: PaginationModel.fromJson(
          data['pagination'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': {
        'items': items.map((r) => r.toJson()).toList(),
        'pagination': pagination.toJson(),
      },
    };
  }

  @override
  List<Object?> get props => [items, pagination];
}
