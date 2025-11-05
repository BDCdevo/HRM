import 'package:equatable/equatable.dart';

/// Change Password Request Model
///
/// Model for changing user password
/// Matches the UpdatePasswordRequest validation rules from Laravel backend
class ChangePasswordRequestModel extends Equatable {
  final String oldPassword;
  final String password;

  const ChangePasswordRequestModel({
    required this.oldPassword,
    required this.password,
  });

  /// To JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'old_password': oldPassword,
      'password': password,
    };
  }

  /// Copy With
  ChangePasswordRequestModel copyWith({
    String? oldPassword,
    String? password,
  }) {
    return ChangePasswordRequestModel(
      oldPassword: oldPassword ?? this.oldPassword,
      password: password ?? this.password,
    );
  }

  @override
  List<Object?> get props => [oldPassword, password];
}
