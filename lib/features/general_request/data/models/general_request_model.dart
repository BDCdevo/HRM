import 'package:json_annotation/json_annotation.dart';

part 'general_request_model.g.dart';

@JsonSerializable()
class GeneralRequestModel {
  final int? id;

  @JsonKey(name: 'employee_id')
  final int? employeeId;

  @JsonKey(name: 'request_type')
  final String requestType;

  @JsonKey(name: 'general_category')
  final String generalCategory;

  @JsonKey(name: 'general_subject')
  final String generalSubject;

  @JsonKey(name: 'general_description')
  final String generalDescription;

  @JsonKey(name: 'general_priority')
  final String generalPriority;

  final String reason;
  final String? status;

  @JsonKey(name: 'created_at')
  final String? createdAt;

  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  GeneralRequestModel({
    this.id,
    this.employeeId,
    this.requestType = 'general',
    required this.generalCategory,
    required this.generalSubject,
    required this.generalDescription,
    this.generalPriority = 'medium',
    required this.reason,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory GeneralRequestModel.fromJson(Map<String, dynamic> json) =>
      _$GeneralRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$GeneralRequestModelToJson(this);

  // Helper getters for Arabic labels
  String get categoryLabel {
    switch (generalCategory) {
      case 'hr':
        return 'الموارد البشرية';
      case 'it':
        return 'تقنية المعلومات';
      case 'finance':
        return 'الشؤون المالية';
      case 'admin':
        return 'الشؤون الإدارية';
      case 'facilities':
        return 'المرافق والصيانة';
      case 'other':
        return 'أخرى';
      default:
        return generalCategory;
    }
  }

  String get priorityLabel {
    switch (generalPriority) {
      case 'low':
        return 'منخفضة';
      case 'medium':
        return 'متوسطة';
      case 'high':
        return 'عالية';
      case 'urgent':
        return 'عاجلة';
      default:
        return generalPriority;
    }
  }

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'قيد المراجعة';
      case 'approved':
        return 'موافق عليه';
      case 'rejected':
        return 'مرفوض';
      default:
        return status ?? 'غير معروف';
    }
  }
}
