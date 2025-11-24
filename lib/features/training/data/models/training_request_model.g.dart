// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrainingRequestModel _$TrainingRequestModelFromJson(
  Map<String, dynamic> json,
) => TrainingRequestModel(
  id: (json['id'] as num?)?.toInt(),
  employeeId: (json['employee_id'] as num?)?.toInt(),
  requestType: json['request_type'] as String? ?? 'training',
  trainingType: json['training_type'] as String,
  trainingName: json['training_name'] as String,
  trainingProvider: json['training_provider'] as String?,
  trainingLocation: json['training_location'] as String?,
  trainingStartDate: json['training_start_date'] as String?,
  trainingEndDate: json['training_end_date'] as String?,
  trainingCost: (json['training_cost'] as num?)?.toDouble(),
  trainingCostCoverage: json['training_cost_coverage'] as String?,
  trainingJustification: json['training_justification'] as String?,
  trainingExpectedBenefit: json['training_expected_benefit'] as String?,
  reason: json['reason'] as String,
  status: json['status'] as String?,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$TrainingRequestModelToJson(
  TrainingRequestModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'employee_id': instance.employeeId,
  'request_type': instance.requestType,
  'training_type': instance.trainingType,
  'training_name': instance.trainingName,
  'training_provider': instance.trainingProvider,
  'training_location': instance.trainingLocation,
  'training_start_date': instance.trainingStartDate,
  'training_end_date': instance.trainingEndDate,
  'training_cost': instance.trainingCost,
  'training_cost_coverage': instance.trainingCostCoverage,
  'training_justification': instance.trainingJustification,
  'training_expected_benefit': instance.trainingExpectedBenefit,
  'reason': instance.reason,
  'status': instance.status,
  'created_at': instance.createdAt,
  'updated_at': instance.updatedAt,
};
