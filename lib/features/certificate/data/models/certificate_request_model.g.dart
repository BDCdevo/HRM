// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'certificate_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CertificateRequestModel _$CertificateRequestModelFromJson(
  Map<String, dynamic> json,
) => CertificateRequestModel(
  id: (json['id'] as num?)?.toInt(),
  employeeId: (json['employee_id'] as num?)?.toInt(),
  requestType: json['request_type'] as String? ?? 'certificate',
  status: json['status'] as String? ?? 'pending',
  reason: json['reason'] as String,
  certificateType: json['certificate_type'] as String,
  certificatePurpose: json['certificate_purpose'] as String,
  certificateLanguage: json['certificate_language'] as String,
  certificateCopies: (json['certificate_copies'] as num?)?.toInt() ?? 1,
  certificateDeliveryMethod: json['certificate_delivery_method'] as String?,
  certificateNeededDate: json['certificate_needed_date'] as String?,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$CertificateRequestModelToJson(
  CertificateRequestModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'employee_id': instance.employeeId,
  'request_type': instance.requestType,
  'status': instance.status,
  'reason': instance.reason,
  'certificate_type': instance.certificateType,
  'certificate_purpose': instance.certificatePurpose,
  'certificate_language': instance.certificateLanguage,
  'certificate_copies': instance.certificateCopies,
  'certificate_delivery_method': instance.certificateDeliveryMethod,
  'certificate_needed_date': instance.certificateNeededDate,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};
