import 'package:equatable/equatable.dart';
import '../../../auth/data/models/user_model.dart';

/// Profile Model
///
/// Comprehensive profile model that matches the ProfileResource from Laravel backend
/// Contains all user profile information including bio, birthdate, nationality, etc.
class ProfileModel extends Equatable {
  final int id;
  final String firstName;
  final String lastName;
  final String? username;
  final String? bio;
  final String email;
  final bool isFavorite;
  final bool isVerified;
  final int? completeProfileStep;
  final bool isCompletedProfile;
  final String? birthdate;
  final String? userType;
  final List<int>? languages;
  final String? accessToken;
  final MediaModel? image;
  final int? nationalityId;
  final int? experienceYears;
  final int sessionCount;
  final double earnings;
  final double availableBalance;

  const ProfileModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.username,
    this.bio,
    required this.email,
    this.isFavorite = false,
    this.isVerified = false,
    this.completeProfileStep,
    this.isCompletedProfile = false,
    this.birthdate,
    this.userType,
    this.languages,
    this.accessToken,
    this.image,
    this.nationalityId,
    this.experienceYears,
    this.sessionCount = 0,
    this.earnings = 0.0,
    this.availableBalance = 0.0,
  });

  /// Full name getter
  String get fullName => '$firstName $lastName'.trim();

  /// Has profile image getter
  bool get hasImage => image != null && image!.url.isNotEmpty;

  /// Display name (username or full name)
  String get displayName => username?.isNotEmpty == true ? username! : fullName;

  /// From JSON
  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as int,
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      username: json['username'] as String?,
      bio: json['bio'] as String?,
      email: json['email'] as String,
      isFavorite: json['is_favorite'] as bool? ?? false,
      isVerified: json['is_verified'] as bool? ?? false,
      completeProfileStep: json['complete_profile_step'] as int?,
      isCompletedProfile: json['is_completed_profile'] as bool? ?? false,
      birthdate: json['birthdate'] as String?,
      userType: json['user_type'] as String?,
      languages: json['languages'] != null
          ? (json['languages'] as List).map((e) => e as int).toList()
          : null,
      accessToken: json['access_token'] as String?,
      image: json['image'] != null && json['image'] is Map
          ? MediaModel.fromJson(json['image'] as Map<String, dynamic>)
          : null,
      nationalityId: json['nationality_id'] as int?,
      experienceYears: json['experience_years'] as int?,
      sessionCount: json['session_count'] as int? ?? 0,
      earnings: (json['earnings'] as num?)?.toDouble() ?? 0.0,
      availableBalance: (json['available_balance'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'username': username,
      'bio': bio,
      'email': email,
      'is_favorite': isFavorite,
      'is_verified': isVerified,
      'complete_profile_step': completeProfileStep,
      'is_completed_profile': isCompletedProfile,
      'birthdate': birthdate,
      'user_type': userType,
      'languages': languages,
      'access_token': accessToken,
      'image': image?.toJson(),
      'nationality_id': nationalityId,
      'experience_years': experienceYears,
      'session_count': sessionCount,
      'earnings': earnings,
      'available_balance': availableBalance,
    };
  }

  /// Copy With
  ProfileModel copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? username,
    String? bio,
    String? email,
    bool? isFavorite,
    bool? isVerified,
    int? completeProfileStep,
    bool? isCompletedProfile,
    String? birthdate,
    String? userType,
    List<int>? languages,
    String? accessToken,
    MediaModel? image,
    int? nationalityId,
    int? experienceYears,
    int? sessionCount,
    double? earnings,
    double? availableBalance,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      email: email ?? this.email,
      isFavorite: isFavorite ?? this.isFavorite,
      isVerified: isVerified ?? this.isVerified,
      completeProfileStep: completeProfileStep ?? this.completeProfileStep,
      isCompletedProfile: isCompletedProfile ?? this.isCompletedProfile,
      birthdate: birthdate ?? this.birthdate,
      userType: userType ?? this.userType,
      languages: languages ?? this.languages,
      accessToken: accessToken ?? this.accessToken,
      image: image ?? this.image,
      nationalityId: nationalityId ?? this.nationalityId,
      experienceYears: experienceYears ?? this.experienceYears,
      sessionCount: sessionCount ?? this.sessionCount,
      earnings: earnings ?? this.earnings,
      availableBalance: availableBalance ?? this.availableBalance,
    );
  }

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        username,
        bio,
        email,
        isFavorite,
        isVerified,
        completeProfileStep,
        isCompletedProfile,
        birthdate,
        userType,
        languages,
        accessToken,
        image,
        nationalityId,
        experienceYears,
        sessionCount,
        earnings,
        availableBalance,
      ];
}
