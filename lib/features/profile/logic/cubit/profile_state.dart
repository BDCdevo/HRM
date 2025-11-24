import 'package:equatable/equatable.dart';
import '../../data/models/profile_model.dart';

/// Profile State
///
/// Represents different states of profile operations
abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];

  /// Display message for UI
  String get displayMessage {
    if (this is ProfileError) {
      return (this as ProfileError).message;
    }
    return '';
  }
}

/// Initial State
class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

/// Loading State
class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

/// Profile Loaded State
class ProfileLoaded extends ProfileState {
  final ProfileModel profile;

  const ProfileLoaded({required this.profile});

  @override
  List<Object?> get props => [profile];
}

/// Profile Updated State
class ProfileUpdated extends ProfileState {
  final ProfileModel profile;
  final String message;

  const ProfileUpdated({
    required this.profile,
    this.message = 'Profile updated successfully',
  });

  @override
  List<Object?> get props => [profile, message];
}

/// Password Changed State
class PasswordChanged extends ProfileState {
  final String message;

  const PasswordChanged({
    this.message = 'Password changed successfully',
  });

  @override
  List<Object?> get props => [message];
}

/// Profile Image Uploaded State
class ProfileImageUploaded extends ProfileState {
  final ProfileModel profile;
  final String message;

  const ProfileImageUploaded({
    required this.profile,
    this.message = 'Profile image uploaded successfully',
  });

  @override
  List<Object?> get props => [profile, message];
}

/// Account Deleted State
class AccountDeleted extends ProfileState {
  final String message;

  const AccountDeleted({
    this.message = 'Account deleted successfully',
  });

  @override
  List<Object?> get props => [message];
}

/// Error State
class ProfileError extends ProfileState {
  final String message;
  final String? errorDetails;

  const ProfileError({
    required this.message,
    this.errorDetails,
  });

  @override
  List<Object?> get props => [message, errorDetails];
}
