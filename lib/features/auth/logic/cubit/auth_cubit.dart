import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/login_response_model.dart';
import '../../data/models/user_model.dart';
import '../../data/repo/auth_repo.dart';
import 'auth_state.dart';

/// Auth Cubit
///
/// Manages authentication state and business logic
/// Uses AuthRepo for API calls
class AuthCubit extends Cubit<AuthState> {
  final AuthRepo _authRepo;

  AuthCubit({AuthRepo? authRepo})
      : _authRepo = authRepo ?? AuthRepo(),
        super(const AuthInitial());

  /// Login (Employee)
  ///
  /// Authenticates employee with email and password
  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      emit(const AuthLoading());

      print('🔐 Attempting employee login for: $email');

      final loginResponse = await _authRepo.login(
        email: email,
        password: password,
      );

      print('✅ Login successful for: ${loginResponse.data.email}');
      print('🎭 Roles: ${loginResponse.data.roles}');
      emit(AuthAuthenticated(loginResponse.data));
    } on DioException catch (e) {
      print('❌ Login DioException: ${e.message}');
      _handleDioError(e);
    } catch (e) {
      print('❌ Login Exception: $e');
      emit(AuthError(message: 'An unexpected error occurred'));
    }
  }

  /// Login Admin
  ///
  /// Authenticates admin with email and password
  Future<void> loginAdmin({
    required String email,
    required String password,
  }) async {
    try {
      emit(const AuthLoading());

      print('🔐 Attempting admin login for: $email');

      final loginResponse = await _authRepo.loginAdmin(
        email: email,
        password: password,
      );

      print('✅ Admin login successful for: ${loginResponse.data.email}');
      emit(AuthAuthenticated(loginResponse.data));
    } on DioException catch (e) {
      print('❌ Admin Login DioException: ${e.message}');
      _handleDioError(e);
    } catch (e) {
      print('❌ Admin Login Exception: $e');
      emit(AuthError(message: 'An unexpected error occurred'));
    }
  }

  /// Register
  ///
  /// Creates a new user account
  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
  }) async {
    try {
      emit(const AuthLoading());

      print('📝 Attempting registration for: $email');

      final registerResponse = await _authRepo.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
        phone: phone,
      );

      print('✅ Registration successful for: ${registerResponse.data.email}');
      emit(AuthAuthenticated(registerResponse.data));
    } on DioException catch (e) {
      print('❌ Register DioException: ${e.message}');
      _handleDioError(e);
    } catch (e) {
      print('❌ Register Exception: $e');
      emit(AuthError(message: 'An unexpected error occurred'));
    }
  }

  /// Logout
  ///
  /// Logs out the current user
  Future<void> logout() async {
    try {
      emit(const AuthLoading());

      print('🔓 Attempting logout');

      await _authRepo.logout();

      print('✅ Logout successful');
      emit(const AuthUnauthenticated());
    } on DioException catch (e) {
      print('❌ Logout DioException: ${e.message}');
      // Even if logout API fails, clear local state
      emit(const AuthUnauthenticated());
    } catch (e) {
      print('❌ Logout Exception: $e');
      // Even if logout fails, clear local state
      emit(const AuthUnauthenticated());
    }
  }

  /// Check Auth Status
  ///
  /// Checks if user is already logged in with valid token
  /// Called on app startup
  Future<void> checkAuthStatus() async {
    try {
      print('🔍 Checking auth status...');

      final isLoggedIn = await _authRepo.isLoggedIn();

      if (isLoggedIn) {
        print('✅ User is logged in');
        // TODO: Optionally fetch user profile here
        // For now, emit unauthenticated to redirect to login
        // In production, you should fetch user data first
        emit(const AuthUnauthenticated());
      } else {
        print('❌ User is not logged in');
        emit(const AuthUnauthenticated());
      }
    } catch (e) {
      print('❌ Check auth status error: $e');
      emit(const AuthUnauthenticated());
    }
  }

  /// Forgot Password
  ///
  /// Sends password reset link to email
  Future<void> forgotPassword(String email) async {
    try {
      emit(const AuthLoading());

      print('📧 Sending password reset email to: $email');

      final message = await _authRepo.forgotPassword(email);

      print('✅ Password reset email sent');
      emit(AuthSuccess(message));
    } on DioException catch (e) {
      print('❌ Forgot password DioException: ${e.message}');
      _handleDioError(e);
    } catch (e) {
      print('❌ Forgot password Exception: $e');
      emit(AuthError(message: 'An unexpected error occurred'));
    }
  }

  /// Reset Password
  ///
  /// Resets password using token from email
  Future<void> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      emit(const AuthLoading());

      print('🔑 Resetting password for: $email');

      final message = await _authRepo.resetPassword(
        email: email,
        token: token,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      print('✅ Password reset successful');
      emit(AuthSuccess(message));
    } on DioException catch (e) {
      print('❌ Reset password DioException: ${e.message}');
      _handleDioError(e);
    } catch (e) {
      print('❌ Reset password Exception: $e');
      emit(AuthError(message: 'An unexpected error occurred'));
    }
  }

  /// Check User Exists
  ///
  /// Checks if user with email exists
  Future<UserModel?> checkUser(String email) async {
    try {
      print('🔍 Checking if user exists: $email');

      final user = await _authRepo.checkUser(email);

      print('✅ User found: ${user.email}');
      return user;
    } on DioException catch (e) {
      print('❌ Check user DioException: ${e.message}');
      return null;
    } catch (e) {
      print('❌ Check user Exception: $e');
      return null;
    }
  }

  /// Handle Dio Errors
  ///
  /// Parses DioException and emits appropriate error state
  void _handleDioError(DioException error) {
    if (error.response?.data != null) {
      try {
        final errorResponse = ErrorResponseModel.fromJson(error.response!.data);
        emit(AuthError(
          message: errorResponse.message,
          firstError: errorResponse.firstError,
        ));
      } catch (e) {
        emit(AuthError(
          message: error.response?.data['message'] ?? 'An error occurred',
        ));
      }
    } else if (error.type == DioExceptionType.connectionTimeout) {
      emit(const AuthError(message: 'Connection timeout. Please try again.'));
    } else if (error.type == DioExceptionType.receiveTimeout) {
      emit(const AuthError(message: 'Server response timeout. Please try again.'));
    } else if (error.type == DioExceptionType.connectionError) {
      emit(const AuthError(
        message: 'No internet connection. Please check your network.',
      ));
    } else {
      emit(AuthError(message: error.message ?? 'An error occurred'));
    }
  }

  /// Reset to Initial State
  ///
  /// Useful for clearing error states
  void resetState() {
    emit(const AuthInitial());
  }
}
