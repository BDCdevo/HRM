import 'package:equatable/equatable.dart';

/// Vacation Type Model
///
/// Represents a type of vacation/leave available to employees
class VacationTypeModel extends Equatable {
  final int id;
  final String name;
  final String? description;
  final int balance;
  final int unlockAfterMonths;
  final int requiredDaysBefore;
  final bool requiresApproval;
  final bool isAvailable;

  const VacationTypeModel({
    required this.id,
    required this.name,
    this.description,
    this.balance = 0,
    this.unlockAfterMonths = 0,
    this.requiredDaysBefore = 0,
    this.requiresApproval = true,
    this.isAvailable = true,
  });

  factory VacationTypeModel.fromJson(Map<String, dynamic> json) {
    return VacationTypeModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      balance: json['balance'] as int? ?? json['total_days'] as int? ?? 0,
      unlockAfterMonths: json['unlock_after_months'] as int? ?? 0,
      requiredDaysBefore: json['required_days_before'] as int? ?? 0,
      requiresApproval: json['requires_approval'] as bool? ?? true,
      isAvailable: json['is_available'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'balance': balance,
      'unlock_after_months': unlockAfterMonths,
      'required_days_before': requiredDaysBefore,
      'requires_approval': requiresApproval,
      'is_available': isAvailable,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        balance,
        unlockAfterMonths,
        requiredDaysBefore,
        requiresApproval,
        isAvailable,
      ];

  /// Helper getters
  String get balanceFormatted => '$balance days';

  String get noticeRequired => requiredDaysBefore > 0
      ? '$requiredDaysBefore days notice required'
      : 'No notice required';

  String get availabilityInfo {
    if (!isAvailable) {
      return unlockAfterMonths > 0
          ? 'Available after $unlockAfterMonths months'
          : 'Not available';
    }
    return 'Available';
  }
}
