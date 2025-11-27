import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../data/repo/profile_repo.dart';
import '../../data/models/update_profile_request_model.dart';
import '../../data/models/change_password_request_model.dart';
import 'profile_state.dart';

/// Profile Cubit
///
/// Manages profile state and handles profile operations
class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepo _profileRepo = ProfileRepo();

  ProfileCubit() : super(const ProfileInitial());

  /// Fetch User Profile
  ///
  /// Gets the authenticated user's profile information
  /// Emits:
  /// - [ProfileLoading] while fetching
  /// - [ProfileLoaded] on success
  /// - [ProfileError] on failure
  Future<void> fetchProfile() async {
    try {
      if (isClosed) return;
      emit(const ProfileLoading());

      final profile = await _profileRepo.getProfile();

      if (isClosed) return;
      emit(ProfileLoaded(profile: profile));
    } on DioException catch (e) {
      if (isClosed) return;
      _handleDioException(e);
    } catch (e) {
      if (isClosed) return;
      emit(ProfileError(
        message: 'An unexpected error occurred: ${e.toString()}',
      ));
    }
  }

  /// Update Profile
  ///
  /// Updates the user's profile information
  /// Emits:
  /// - [ProfileLoading] while updating
  /// - [ProfileUpdated] on success
  /// - [ProfileError] on failure
  Future<void> updateProfile(UpdateProfileRequestModel request) async {
    try {
      if (isClosed) return;
      emit(const ProfileLoading());

      final profile = await _profileRepo.updateProfile(request);

      if (isClosed) return;
      emit(ProfileUpdated(profile: profile));

      // Refresh profile to get latest data
      await fetchProfile();
    } on DioException catch (e) {
      if (isClosed) return;
      _handleDioException(e);
    } catch (e) {
      if (isClosed) return;
      emit(ProfileError(
        message: 'An unexpected error occurred: ${e.toString()}',
      ));
    }
  }

  /// Change Password
  ///
  /// Changes the user's password
  /// Emits:
  /// - [ProfileLoading] while processing
  /// - [PasswordChanged] on success
  /// - [ProfileError] on failure
  Future<void> changePassword(ChangePasswordRequestModel request) async {
    try {
      if (isClosed) return;
      emit(const ProfileLoading());

      final message = await _profileRepo.changePassword(request);

      if (isClosed) return;
      emit(PasswordChanged(message: message));
    } on DioException catch (e) {
      if (isClosed) return;
      _handleDioException(e);
    } catch (e) {
      if (isClosed) return;
      emit(ProfileError(
        message: 'An unexpected error occurred: ${e.toString()}',
      ));
    }
  }

  /// Delete Account
  ///
  /// Deletes the user's account
  /// Emits:
  /// - [ProfileLoading] while processing
  /// - [AccountDeleted] on success
  /// - [ProfileError] on failure
  Future<void> deleteAccount() async {
    try {
      if (isClosed) return;
      emit(const ProfileLoading());

      final message = await _profileRepo.deleteAccount();

      if (isClosed) return;
      emit(AccountDeleted(message: message));
    } on DioException catch (e) {
      if (isClosed) return;
      _handleDioException(e);
    } catch (e) {
      if (isClosed) return;
      emit(ProfileError(
        message: 'An unexpected error occurred: ${e.toString()}',
      ));
    }
  }

  /// Upload Profile Image
  ///
  /// Uploads a new profile image
  /// Emits:
  /// - [ProfileLoading] while uploading
  /// - [ProfileImageUploaded] on success
  /// - [ProfileError] on failure
  Future<void> uploadProfileImage(File imageFile) async {
    try {
      if (isClosed) return;
      emit(const ProfileLoading());

      final profile = await _profileRepo.uploadProfileImage(imageFile);

      if (isClosed) return;
      emit(ProfileImageUploaded(profile: profile));

      // Refresh profile to get latest data
      await fetchProfile();
    } on DioException catch (e) {
      if (isClosed) return;
      _handleDioException(e);
    } catch (e) {
      if (isClosed) return;
      emit(ProfileError(
        message: 'An unexpected error occurred: ${e.toString()}',
      ));
    }
  }

  /// Handle Dio Exception
  void _handleDioException(DioException e) {
    if (isClosed) return;

    if (e.response != null) {
      // Server responded with error
      final statusCode = e.response?.statusCode;
      final errorMessage = e.response?.data?['message'] ?? 'Operation failed';

      emit(ProfileError(
        message: '[$statusCode] $errorMessage',
        errorDetails: e.response?.data?.toString(),
      ));
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      // Timeout error
      emit(const ProfileError(
        message: 'Request timeout. Please try again.',
      ));
    } else if (e.type == DioExceptionType.unknown) {
      // Network error (no internet connection)
      emit(const ProfileError(
        message: 'Network error. Please check your internet connection.',
      ));
    } else {
      // Other Dio errors
      emit(ProfileError(
        message: e.message ?? 'An unexpected error occurred',
      ));
    }
  }
}
