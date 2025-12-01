// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weekly_stats_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeeklyStatsModel _$WeeklyStatsModelFromJson(Map<String, dynamic> json) =>
    WeeklyStatsModel(
      totalHours: (json['total_hours'] as num).toDouble(),
      targetHours: (json['target_hours'] as num).toDouble(),
      daysWorked: (json['days_worked'] as num).toInt(),
      daysRemaining: (json['days_remaining'] as num).toInt(),
      weekStart: json['week_start'] as String,
      weekEnd: json['week_end'] as String,
      averageDailyHours: (json['average_daily_hours'] as num).toDouble(),
      progressPercentage: (json['progress_percentage'] as num).toDouble(),
    );

Map<String, dynamic> _$WeeklyStatsModelToJson(WeeklyStatsModel instance) =>
    <String, dynamic>{
      'total_hours': instance.totalHours,
      'target_hours': instance.targetHours,
      'days_worked': instance.daysWorked,
      'days_remaining': instance.daysRemaining,
      'week_start': instance.weekStart,
      'week_end': instance.weekEnd,
      'average_daily_hours': instance.averageDailyHours,
      'progress_percentage': instance.progressPercentage,
    };
