import 'package:json_annotation/json_annotation.dart';

part 'weekly_stats_model.g.dart';

/// Weekly Stats Model
///
/// Represents employee's weekly attendance statistics
@JsonSerializable()
class WeeklyStatsModel {
  /// Total hours worked this week
  @JsonKey(name: 'total_hours')
  final double totalHours;

  /// Target hours for the week (e.g., 48)
  @JsonKey(name: 'target_hours')
  final double targetHours;

  /// Number of days worked this week
  @JsonKey(name: 'days_worked')
  final int daysWorked;

  /// Number of days remaining in the week
  @JsonKey(name: 'days_remaining')
  final int daysRemaining;

  /// Week start date (Saturday)
  @JsonKey(name: 'week_start')
  final String weekStart;

  /// Week end date (Thursday)
  @JsonKey(name: 'week_end')
  final String weekEnd;

  /// Average daily hours
  @JsonKey(name: 'average_daily_hours')
  final double averageDailyHours;

  /// Progress percentage (0-100)
  @JsonKey(name: 'progress_percentage')
  final double progressPercentage;

  const WeeklyStatsModel({
    required this.totalHours,
    required this.targetHours,
    required this.daysWorked,
    required this.daysRemaining,
    required this.weekStart,
    required this.weekEnd,
    required this.averageDailyHours,
    required this.progressPercentage,
  });

  factory WeeklyStatsModel.fromJson(Map<String, dynamic> json) =>
      _$WeeklyStatsModelFromJson(json);

  Map<String, dynamic> toJson() => _$WeeklyStatsModelToJson(this);

  /// Create empty/default stats
  factory WeeklyStatsModel.empty() => const WeeklyStatsModel(
        totalHours: 0.0,
        targetHours: 48.0,
        daysWorked: 0,
        daysRemaining: 6,
        weekStart: '',
        weekEnd: '',
        averageDailyHours: 0.0,
        progressPercentage: 0.0,
      );

  /// Calculate progress (0.0 - 1.0)
  double get progress => (totalHours / targetHours).clamp(0.0, 1.0);

  /// Formatted total hours (e.g., "24.5h")
  String get formattedTotalHours => '${totalHours.toStringAsFixed(1)}h';

  /// Formatted target hours (e.g., "48h")
  String get formattedTargetHours => '${targetHours.toInt()}h';

  /// Hours remaining to reach target
  double get hoursRemaining => (targetHours - totalHours).clamp(0.0, targetHours);

  /// Formatted hours remaining
  String get formattedHoursRemaining => '${hoursRemaining.toStringAsFixed(1)}h';
}
