import 'package:equatable/equatable.dart';
import 'user_model.dart';

/// Login Response Model
///
/// Wraps the API response for login endpoint
/// Follows the DataResponse pattern from Laravel backend
class LoginResponseModel extends Equatable {
  final UserModel data;
  final String? message;

  const LoginResponseModel({
    required this.data,
    this.message,
  });

  /// Check if login was successful (always true if data exists)
  bool get isSuccess => true;

  /// From JSON
  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    final dataMap = json['data'] as Map<String, dynamic>;

    // Handle different response structures
    // Employee login: data contains user fields directly
    // Admin login: data.user contains user fields, data.access_token at top level
    Map<String, dynamic> userData;
    String? accessToken;

    if (dataMap.containsKey('user') && dataMap['user'] is Map) {
      // Admin response structure
      userData = dataMap['user'] as Map<String, dynamic>;
      accessToken = dataMap['access_token'] as String?;
    } else {
      // Employee response structure (user fields directly in data)
      userData = dataMap;
      accessToken = dataMap['access_token'] as String?;
    }

    // Add access_token to userData for UserModel parsing
    if (accessToken != null) {
      userData = {...userData, 'access_token': accessToken};
    }

    return LoginResponseModel(
      data: UserModel.fromJson(userData),
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

/// Error Response Model
///
/// Handles API error responses
class ErrorResponseModel extends Equatable {
  final String message;
  final Map<String, dynamic>? errors;
  final int status;

  const ErrorResponseModel({
    required this.message,
    this.errors,
    required this.status,
  });

  factory ErrorResponseModel.fromJson(Map<String, dynamic> json) {
    return ErrorResponseModel(
      message: json['message'] as String? ?? 'Unknown error occurred',
      errors: json['errors'] as Map<String, dynamic>?,
      status: json['status'] as int? ?? 500,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'errors': errors,
      'status': status,
    };
  }

  /// Get first error message from validation errors
  String? get firstError {
    if (errors == null || errors!.isEmpty) return null;

    final firstKey = errors!.keys.first;
    final errorList = errors![firstKey];

    if (errorList is List && errorList.isNotEmpty) {
      return errorList.first.toString();
    }

    return errorList.toString();
  }

  @override
  List<Object?> get props => [message, errors, status];
}
