import 'package:equatable/equatable.dart';

/// Update Profile Request Model
///
/// Model for updating user profile information
/// Matches the UpdateProfileRequest validation rules from Laravel backend
class UpdateProfileRequestModel extends Equatable {
  final String? name;
  final String? username;
  final String? bio;
  final String? birthdate;
  final int? experienceYears;
  final String? image; // Base64 encoded image or file path
  final int? nationalityId;
  final List<int>? languages;

  // Employee-specific fields
  final String? phone;
  final String? address;
  final String? gender;
  final String? dateOfBirth;
  final String? nationalId;

  const UpdateProfileRequestModel({
    this.name,
    this.username,
    this.bio,
    this.birthdate,
    this.experienceYears,
    this.image,
    this.nationalityId,
    this.languages,
    this.phone,
    this.address,
    this.gender,
    this.dateOfBirth,
    this.nationalId,
  });

  /// To JSON for API request
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (name != null) data['name'] = name;
    if (username != null) data['username'] = username;
    if (bio != null) data['bio'] = bio;
    if (birthdate != null) data['birthdate'] = birthdate;
    if (experienceYears != null) data['experience_years'] = experienceYears;
    if (image != null) data['image'] = image;
    if (nationalityId != null) data['nationality_id'] = nationalityId;
    if (languages != null) data['languages'] = languages;
    if (phone != null) data['phone'] = phone;
    if (address != null) data['address'] = address;
    if (gender != null) data['gender'] = gender;
    if (dateOfBirth != null) data['date_of_birth'] = dateOfBirth;
    if (nationalId != null) data['national_id'] = nationalId;

    return data;
  }

  /// Copy With
  UpdateProfileRequestModel copyWith({
    String? name,
    String? username,
    String? bio,
    String? birthdate,
    int? experienceYears,
    String? image,
    int? nationalityId,
    List<int>? languages,
    String? phone,
    String? address,
    String? gender,
    String? dateOfBirth,
    String? nationalId,
  }) {
    return UpdateProfileRequestModel(
      name: name ?? this.name,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      birthdate: birthdate ?? this.birthdate,
      experienceYears: experienceYears ?? this.experienceYears,
      image: image ?? this.image,
      nationalityId: nationalityId ?? this.nationalityId,
      languages: languages ?? this.languages,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      nationalId: nationalId ?? this.nationalId,
    );
  }

  @override
  List<Object?> get props => [
        name,
        username,
        bio,
        birthdate,
        experienceYears,
        image,
        nationalityId,
        languages,
        phone,
        address,
        gender,
        dateOfBirth,
        nationalId,
      ];
}
