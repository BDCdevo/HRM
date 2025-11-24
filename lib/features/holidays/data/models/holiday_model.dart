import 'package:json_annotation/json_annotation.dart';

part 'holiday_model.g.dart';

@JsonSerializable()
class HolidayModel {
  final int id;
  final String name;
  final String? description;
  @JsonKey(name: 'start_date')
  final String startDate;
  @JsonKey(name: 'end_date')
  final String endDate;
  final int duration;
  final String type;
  @JsonKey(name: 'is_recurring')
  final bool isRecurring;
  @JsonKey(name: 'recurrence_type')
  final String? recurrenceType;
  @JsonKey(name: 'is_paid')
  final bool isPaid;
  final String color;
  @JsonKey(name: 'is_current')
  final bool isCurrent;
  @JsonKey(name: 'is_upcoming')
  final bool isUpcoming;
  @JsonKey(name: 'is_past')
  final bool isPast;
  @JsonKey(name: 'formatted_date_range')
  final String formattedDateRange;

  HolidayModel({
    required this.id,
    required this.name,
    this.description,
    required this.startDate,
    required this.endDate,
    required this.duration,
    required this.type,
    required this.isRecurring,
    this.recurrenceType,
    required this.isPaid,
    required this.color,
    required this.isCurrent,
    required this.isUpcoming,
    required this.isPast,
    required this.formattedDateRange,
  });

  factory HolidayModel.fromJson(Map<String, dynamic> json) =>
      _$HolidayModelFromJson(json);

  Map<String, dynamic> toJson() => _$HolidayModelToJson(this);

  String get typeLabel {
    switch (type) {
      case 'public':
        return 'عامة';
      case 'religious':
        return 'دينية';
      case 'national':
        return 'وطنية';
      case 'company':
        return 'خاصة بالشركة';
      default:
        return type;
    }
  }

  String get statusLabel {
    if (isCurrent) return 'جارية الآن';
    if (isUpcoming) return 'قادمة';
    if (isPast) return 'منتهية';
    return '';
  }
}
