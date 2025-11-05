import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/networking/dio_client.dart';
import '../models/login_response_model.dart';
import '../models/user_model.dart';

/// Authentication Repository
///
/// Handles all authentication-related API calls
/// Uses DioClient for HTTP requests and FlutterSecureStorage for token management
class AuthRepo {
  final DioClient _dioClient;
  final FlutterSecureStorage _storage;

  AuthRepo({
    DioClient? dioClient,
    FlutterSecureStorage? storage,
  })  : _dioClient = dioClient ?? DioClient.getInstance(),
        _storage = storage ?? const FlutterSecureStorage();

  /// Login
  ///
  /// Authenticates user with email and password
  /// Returns LoginResponseModel on success
  /// Throws DioException on failure
  Future<LoginResponseModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dioClient.post(
        ApiConfig.login,
        data: {
          'identifier': email, // Can be email or username
          'password': password,
        },
      );

      print('✅ Login Response Status: ${response.statusCode}');
      print('📦 Login Response Data: ${response.data}');

      // Parse response
      final loginResponse = LoginResponseModel.fromJson(response.data);

      // Save token to secure storage
      if (loginResponse.data.hasToken) {
        await _storage.write(
          key: 'auth_token',
          value: loginResponse.data.accessToken,
        );
        print('🔐 Token saved successfully');
      }

      return loginResponse;
    } on DioException catch (e) {
      print('❌ Login Error: ${e.message}');

      // Parse error response
      if (e.response?.data != null) {
        final errorResponse = ErrorResponseModel.fromJson(e.response!.data);
        print('⚠️ Error Message: ${errorResponse.message}');
        print('⚠️ First Error: ${errorResponse.firstError}');
      }

      rethrow;
    }
  }

  /// Admin Login
  ///
  /// Authenticates admin with email and password
  /// Returns LoginResponseModel on success
  /// Throws DioException on failure
  Future<LoginResponseModel> loginAdmin({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dioClient.post(
        ApiConfig.adminLogin,
        data: {
          'email': email,
          'password': password,
        },
      );

      print('✅ Admin Login Response Status: ${response.statusCode}');
      print('📦 Admin Login Response Data: ${response.data}');

      // Parse response
      final loginResponse = LoginResponseModel.fromJson(response.data);

      // Save token to secure storage
      if (loginResponse.data.hasToken) {
        await _storage.write(
          key: 'auth_token',
          value: loginResponse.data.accessToken,
        );
        print('🔐 Admin token saved successfully');
      }

      return loginResponse;
    } on DioException catch (e) {
      print('❌ Admin Login Error: ${e.message}');

      // Parse error response
      if (e.response?.data != null) {
        final errorResponse = ErrorResponseModel.fromJson(e.response!.data);
        print('⚠️ Error Message: ${errorResponse.message}');
        print('⚠️ First Error: ${errorResponse.firstError}');
      }

      rethrow;
    }
  }

  /// Register
  ///
  /// Creates a new user account
  /// Returns LoginResponseModel on success (auto-login after registration)
  /// Throws DioException on failure
  Future<LoginResponseModel> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
  }) async {
    try {
      final response = await _dioClient.post(
        ApiConfig.register,
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
          if (phone != null) 'phone': phone,
        },
      );

      print('✅ Register Response Status: ${response.statusCode}');

      // Parse response
      final registerResponse = LoginResponseModel.fromJson(response.data);

      // Save token to secure storage
      if (registerResponse.data.hasToken) {
        await _storage.write(
          key: 'auth_token',
          value: registerResponse.data.accessToken,
        );
        print('🔐 Token saved successfully after registration');
      }

      return registerResponse;
    } on DioException catch (e) {
      print('❌ Register Error: ${e.message}');

      if (e.response?.data != null) {
        final errorResponse = ErrorResponseModel.fromJson(e.response!.data);
        print('⚠️ Error Message: ${errorResponse.message}');
        print('⚠️ Validation Errors: ${errorResponse.errors}');
      }

      rethrow;
    }
  }

  /// Logout
  ///
  /// Logs out the current user and clears stored token
  /// Returns true on success
  /// Throws DioException on failure
  Future<bool> logout() async {
    try {
      final response = await _dioClient.post(ApiConfig.logout);

      print('✅ Logout Response Status: ${response.statusCode}');

      // Clear token from secure storage
      await _storage.delete(key: 'auth_token');
      print('🔓 Token cleared successfully');

      return true;
    } on DioException catch (e) {
      print('❌ Logout Error: ${e.message}');

      // Even if logout fails, clear local token
      await _storage.delete(key: 'auth_token');
      print('🔓 Token cleared locally');

      rethrow;
    }
  }

  /// Check User
  ///
  /// Verifies if a user with given email exists
  /// Returns user data if found
  /// Throws DioException if not found
  Future<UserModel> checkUser(String email) async {
    try {
      final response = await _dioClient.post(
        ApiConfig.checkUser,
        data: {'email': email},
      );

      print('✅ Check User Response Status: ${response.statusCode}');

      // Parse user from response
      return UserModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      print('❌ Check User Error: ${e.message}');
      rethrow;
    }
  }

  /// Forgot Password
  ///
  /// Sends password reset link to user's email
  /// Returns success message
  /// Throws DioException on failure
  Future<String> forgotPassword(String email) async {
    try {
      final response = await _dioClient.post(
        ApiConfig.forgotPassword,
        data: {'email': email},
      );

      print('✅ Forgot Password Response Status: ${response.statusCode}');

      return response.data['message'] ?? 'Password reset link sent to email';
    } on DioException catch (e) {
      print('❌ Forgot Password Error: ${e.message}');
      rethrow;
    }
  }

  /// Reset Password
  ///
  /// Resets user password using token from email
  /// Returns success message
  /// Throws DioException on failure
  Future<String> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await _dioClient.post(
        ApiConfig.resetPassword,
        data: {
          'email': email,
          'token': token,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );

      print('✅ Reset Password Response Status: ${response.statusCode}');

      return response.data['message'] ?? 'Password reset successfully';
    } on DioException catch (e) {
      print('❌ Reset Password Error: ${e.message}');
      rethrow;
    }
  }

  /// Get Stored Token
  ///
  /// Retrieves the saved auth token from secure storage
  /// Returns token if exists, null otherwise
  Future<String?> getStoredToken() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      return token;
    } catch (e) {
      print('❌ Error reading stored token: $e');
      return null;
    }
  }

  /// Is Logged In
  ///
  /// Checks if user has a valid token stored
  /// Returns true if token exists, false otherwise
  Future<bool> isLoggedIn() async {
    final token = await getStoredToken();
    return token != null && token.isNotEmpty;
  }

  /// Clear All Auth Data
  ///
  /// Clears all authentication data from storage
  /// Useful for logout or account deletion
  Future<void> clearAuthData() async {
    try {
      await _storage.delete(key: 'auth_token');
      print('🔓 All auth data cleared');
    } catch (e) {
      print('❌ Error clearing auth data: $e');
    }
  }
}
