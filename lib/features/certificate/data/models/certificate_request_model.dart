import 'package:json_annotation/json_annotation.dart';

part 'certificate_request_model.g.dart';

/// Certificate Request Model
///
/// Model for certificate requests with all required fields
@JsonSerializable()
class CertificateRequestModel {
  final int? id;
  @JsonKey(name: 'employee_id')
  final int? employeeId;
  @JsonKey(name: 'request_type')
  final String requestType;
  final String status;
  final String reason;
  @JsonKey(name: 'certificate_type')
  final String certificateType;
  @JsonKey(name: 'certificate_purpose')
  final String certificatePurpose;
  @JsonKey(name: 'certificate_language')
  final String certificateLanguage;
  @JsonKey(name: 'certificate_copies')
  final int certificateCopies;
  @JsonKey(name: 'certificate_delivery_method')
  final String? certificateDeliveryMethod;
  @JsonKey(name: 'certificate_needed_date')
  final String? certificateNeededDate;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  CertificateRequestModel({
    this.id,
    this.employeeId,
    this.requestType = 'certificate',
    this.status = 'pending',
    required this.reason,
    required this.certificateType,
    required this.certificatePurpose,
    required this.certificateLanguage,
    this.certificateCopies = 1,
    this.certificateDeliveryMethod,
    this.certificateNeededDate,
    this.createdAt,
    this.updatedAt,
  });

  factory CertificateRequestModel.fromJson(Map<String, dynamic> json) =>
      _$CertificateRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$CertificateRequestModelToJson(this);

  /// Get certificate type label in Arabic
  String get certificateTypeLabel {
    switch (certificateType) {
      case 'salary':
        return 'شهادة راتب';
      case 'experience':
        return 'شهادة خبرة';
      case 'employment':
        return 'شهادة عمل';
      case 'to_whom_it_may_concern':
        return 'إلى من يهمه الأمر';
      default:
        return certificateType;
    }
  }

  /// Get language label in Arabic
  String get languageLabel {
    switch (certificateLanguage) {
      case 'arabic':
        return 'عربي';
      case 'english':
        return 'إنجليزي';
      case 'both':
        return 'عربي وإنجليزي';
      default:
        return certificateLanguage;
    }
  }

  /// Get delivery method label in Arabic
  String get deliveryMethodLabel {
    switch (certificateDeliveryMethod) {
      case 'pickup':
        return 'استلام من المكتب';
      case 'email':
        return 'إرسال عبر البريد الإلكتروني';
      case 'mail':
        return 'إرسال بالبريد';
      default:
        return certificateDeliveryMethod ?? '';
    }
  }

  /// Get status label in Arabic
  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'قيد الانتظار';
      case 'approved':
        return 'موافق عليه';
      case 'rejected':
        return 'مرفوض';
      default:
        return status;
    }
  }
}
