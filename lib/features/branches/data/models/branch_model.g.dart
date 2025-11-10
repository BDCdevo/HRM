// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'branch_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BranchModel _$BranchModelFromJson(Map<String, dynamic> json) => BranchModel(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  code: json['code'] as String?,
  address: json['address'] as String?,
  latitude: BranchModel._latitudeFromJson(json['latitude']),
  longitude: BranchModel._longitudeFromJson(json['longitude']),
  radius: (json['radius'] as num).toInt(),
  phone: json['phone'] as String?,
  email: json['email'] as String?,
  employeesCount: (json['employees_count'] as num?)?.toInt(),
);

Map<String, dynamic> _$BranchModelToJson(BranchModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'code': instance.code,
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'radius': instance.radius,
      'phone': instance.phone,
      'email': instance.email,
      'employees_count': instance.employeesCount,
    };
