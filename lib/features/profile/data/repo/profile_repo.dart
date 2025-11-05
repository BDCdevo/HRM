import '../../../../core/networking/dio_client.dart';
import '../../../../core/config/api_config.dart';
import '../models/profile_model.dart';
import '../models/profile_response_model.dart';
import '../models/update_profile_request_model.dart';
import '../models/change_password_request_model.dart';

/// Profile Repository
///
/// Handles all profile-related API calls
/// Communicates with Laravel backend profile endpoints
class ProfileRepo {
  final DioClient _dioClient = DioClient.getInstance();

  /// Get User Profile
  ///
  /// Fetches the authenticated user's profile information
  /// GET /api/v1/profile/
  Future<ProfileModel> getProfile() async {
    try {
      final response = await _dioClient.get(
        ApiConfig.profile,
      );

      final profileResponse = ProfileResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );

      return profileResponse.data;
    } catch (e) {
      rethrow;
    }
  }

  /// Update User Profile
  ///
  /// Updates the authenticated user's profile information
  /// PUT /api/v1/profile/
  Future<ProfileModel> updateProfile(UpdateProfileRequestModel request) async {
    try {
      final response = await _dioClient.put(
        ApiConfig.profile,
        data: request.toJson(),
      );

      final profileResponse = ProfileResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );

      return profileResponse.data;
    } catch (e) {
      rethrow;
    }
  }

  /// Change Password
  ///
  /// Changes the authenticated user's password
  /// POST /api/v1/profile/change-password
  Future<String> changePassword(ChangePasswordRequestModel request) async {
    try {
      final response = await _dioClient.post(
        ApiConfig.changePassword,
        data: request.toJson(),
      );

      final successResponse = SuccessResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );

      return successResponse.message;
    } catch (e) {
      rethrow;
    }
  }

  /// Delete Account
  ///
  /// Deletes the authenticated user's account
  /// DELETE /api/v1/profile/
  Future<String> deleteAccount() async {
    try {
      final response = await _dioClient.delete(
        ApiConfig.profile,
      );

      final successResponse = SuccessResponseModel.fromJson(
        response.data as Map<String, dynamic>,
      );

      return successResponse.message;
    } catch (e) {
      rethrow;
    }
  }
}
