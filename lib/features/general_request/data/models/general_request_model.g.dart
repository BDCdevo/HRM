// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'general_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GeneralRequestModel _$GeneralRequestModelFromJson(Map<String, dynamic> json) =>
    GeneralRequestModel(
      id: (json['id'] as num?)?.toInt(),
      employeeId: (json['employee_id'] as num?)?.toInt(),
      requestType: json['request_type'] as String? ?? 'general',
      generalCategory: json['general_category'] as String,
      generalSubject: json['general_subject'] as String,
      generalDescription: json['general_description'] as String,
      generalPriority: json['general_priority'] as String? ?? 'medium',
      reason: json['reason'] as String,
      status: json['status'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$GeneralRequestModelToJson(
  GeneralRequestModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'employee_id': instance.employeeId,
  'request_type': instance.requestType,
  'general_category': instance.generalCategory,
  'general_subject': instance.generalSubject,
  'general_description': instance.generalDescription,
  'general_priority': instance.generalPriority,
  'reason': instance.reason,
  'status': instance.status,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};
