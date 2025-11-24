// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'holiday_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HolidayModel _$HolidayModelFromJson(Map<String, dynamic> json) => HolidayModel(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  description: json['description'] as String?,
  startDate: json['start_date'] as String,
  endDate: json['end_date'] as String,
  duration: (json['duration'] as num).toInt(),
  type: json['type'] as String,
  isRecurring: json['is_recurring'] as bool,
  recurrenceType: json['recurrence_type'] as String?,
  isPaid: json['is_paid'] as bool,
  color: json['color'] as String,
  isCurrent: json['is_current'] as bool,
  isUpcoming: json['is_upcoming'] as bool,
  isPast: json['is_past'] as bool,
  formattedDateRange: json['formatted_date_range'] as String,
);

Map<String, dynamic> _$HolidayModelToJson(HolidayModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'start_date': instance.startDate,
      'end_date': instance.endDate,
      'duration': instance.duration,
      'type': instance.type,
      'is_recurring': instance.isRecurring,
      'recurrence_type': instance.recurrenceType,
      'is_paid': instance.isPaid,
      'color': instance.color,
      'is_current': instance.isCurrent,
      'is_upcoming': instance.isUpcoming,
      'is_past': instance.isPast,
      'formatted_date_range': instance.formattedDateRange,
    };
