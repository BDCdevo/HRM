import 'package:equatable/equatable.dart';
import 'profile_model.dart';

/// Profile Response Model
///
/// Wraps the API response for profile endpoints
/// Matches the DataResponse structure from Laravel backend
class ProfileResponseModel extends Equatable {
  final ProfileModel data;
  final String? message;

  const ProfileResponseModel({
    required this.data,
    this.message,
  });

  /// From JSON
  factory ProfileResponseModel.fromJson(Map<String, dynamic> json) {
    return ProfileResponseModel(
      data: ProfileModel.fromJson(json['data'] as Map<String, dynamic>),
      message: json['message'] as String?,
    );
  }

  /// To JSON
  Map<String, dynamic> toJson() {
    return {
      'data': data.toJson(),
      'message': message,
    };
  }

  @override
  List<Object?> get props => [data, message];
}

/// Generic Success Response Model
///
/// For endpoints that return success message without data (e.g., changePassword, deleteAccount)
class SuccessResponseModel extends Equatable {
  final String message;

  const SuccessResponseModel({
    required this.message,
  });

  /// From JSON
  factory SuccessResponseModel.fromJson(Map<String, dynamic> json) {
    return SuccessResponseModel(
      message: json['message'] as String? ?? 'Success',
    );
  }

  /// To JSON
  Map<String, dynamic> toJson() {
    return {
      'message': message,
    };
  }

  @override
  List<Object?> get props => [message];
}
