import 'package:json_annotation/json_annotation.dart';

part 'branch_model.g.dart';

@JsonSerializable()
class BranchModel {
  final int id;
  final String name;
  final String? code;
  final String? address;
  @JsonKey(fromJson: _latitudeFromJson)
  final double? latitude;
  @JsonKey(fromJson: _longitudeFromJson)
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

  /// Custom JSON converter for latitude (handles String or num)
  static double? _latitudeFromJson(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Custom JSON converter for longitude (handles String or num)
  static double? _longitudeFromJson(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  factory BranchModel.fromJson(Map<String, dynamic> json) =>
      _$BranchModelFromJson(json);

  Map<String, dynamic> toJson() => _$BranchModelToJson(this);

  /// Check if branch has GPS coordinates set
  bool get hasLocation => latitude != null && longitude != null;

  /// Get formatted radius for display
  String get radiusText => '$radius meters';
}
