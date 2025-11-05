import 'package:json_annotation/json_annotation.dart';

part 'branch_model.g.dart';

@JsonSerializable()
class BranchModel {
  final int id;
  final String name;
  final String? code;
  final String? address;
  final double? latitude;
  final double? longitude;
  final int radius;
  final String? phone;
  final String? email;
  @JsonKey(name: 'employees_count')
  final int? employeesCount;

  BranchModel({
    required this.id,
    required this.name,
    this.code,
    this.address,
    this.latitude,
    this.longitude,
    required this.radius,
    this.phone,
    this.email,
    this.employeesCount,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) =>
      _$BranchModelFromJson(json);

  Map<String, dynamic> toJson() => _$BranchModelToJson(this);

  /// Check if branch has GPS coordinates set
  bool get hasLocation => latitude != null && longitude != null;

  /// Get formatted radius for display
  String get radiusText => '$radius meters';
}
