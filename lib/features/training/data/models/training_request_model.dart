import 'package:json_annotation/json_annotation.dart';

part 'training_request_model.g.dart';

@JsonSerializable()
class TrainingRequestModel {
  final int? id;

  @JsonKey(name: 'employee_id')
  final int? employeeId;

  @JsonKey(name: 'request_type')
  final String requestType;

  @JsonKey(name: 'training_type')
  final String trainingType;

  @JsonKey(name: 'training_name')
  final String trainingName;

  @JsonKey(name: 'training_provider')
  final String? trainingProvider;

  @JsonKey(name: 'training_location')
  final String? trainingLocation;

  @JsonKey(name: 'training_start_date')
  final String? trainingStartDate;

  @JsonKey(name: 'training_end_date')
  final String? trainingEndDate;

  @JsonKey(name: 'training_cost')
  final double? trainingCost;

  @JsonKey(name: 'training_cost_coverage')
  final String? trainingCostCoverage;

  @JsonKey(name: 'training_justification')
  final String? trainingJustification;

  @JsonKey(name: 'training_expected_benefit')
  final String? trainingExpectedBenefit;

  final String reason;
  final String? status;

  @JsonKey(name: 'created_at')
  final String? createdAt;

  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  TrainingRequestModel({
    this.id,
    this.employeeId,
    this.requestType = 'training',
    required this.trainingType,
    required this.trainingName,
    this.trainingProvider,
    this.trainingLocation,
    this.trainingStartDate,
    this.trainingEndDate,
    this.trainingCost,
    this.trainingCostCoverage,
    this.trainingJustification,
    this.trainingExpectedBenefit,
    required this.reason,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory TrainingRequestModel.fromJson(Map<String, dynamic> json) =>
      _$TrainingRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$TrainingRequestModelToJson(this);

  // Helper getters for labels
  String get trainingTypeLabel {
    switch (trainingType) {
      case 'technical':
        return 'Technical Training';
      case 'soft_skills':
        return 'Soft Skills';
      case 'management':
        return 'Management & Leadership';
      case 'language':
        return 'Languages';
      case 'certification':
        return 'Professional Certification';
      case 'other':
        return 'Other';
      default:
        return trainingType;
    }
  }

  String get costCoverageLabel {
    switch (trainingCostCoverage) {
      case 'full':
        return 'Full Company Coverage';
      case 'partial':
        return 'Partial Company Coverage';
      case 'none':
        return 'No Coverage (Self-funded)';
      default:
        return trainingCostCoverage ?? '';
    }
  }

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'Under Review';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      default:
        return status ?? 'Unknown';
    }
  }
}
