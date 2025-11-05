import 'package:equatable/equatable.dart';

/// Update Profile Request Model
///
/// Model for updating user profile information
/// Matches the UpdateProfileRequest validation rules from Laravel backend
class UpdateProfileRequestModel extends Equatable {
  final String? firstName;
  final String? lastName;
  final String? bio;
  final String? birthdate;
  final String? image; // Base64 encoded image or file path
  final int? nationalityId;
  final List<int>? languages;

  const UpdateProfileRequestModel({
    this.firstName,
    this.lastName,
    this.bio,
    this.birthdate,
    this.image,
    this.nationalityId,
    this.languages,
  });

  /// To JSON for API request
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (firstName != null) data['first_name'] = firstName;
    if (lastName != null) data['last_name'] = lastName;
    if (bio != null) data['bio'] = bio;
    if (birthdate != null) data['birthdate'] = birthdate;
    if (image != null) data['image'] = image;
    if (nationalityId != null) data['nationality_id'] = nationalityId;
    if (languages != null) data['languages'] = languages;

    return data;
  }

  /// Copy With
  UpdateProfileRequestModel copyWith({
    String? firstName,
    String? lastName,
    String? bio,
    String? birthdate,
    String? image,
    int? nationalityId,
    List<int>? languages,
  }) {
    return UpdateProfileRequestModel(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      bio: bio ?? this.bio,
      birthdate: birthdate ?? this.birthdate,
      image: image ?? this.image,
      nationalityId: nationalityId ?? this.nationalityId,
      languages: languages ?? this.languages,
    );
  }

  @override
  List<Object?> get props => [
        firstName,
        lastName,
        bio,
        birthdate,
        image,
        nationalityId,
        languages,
      ];
}
