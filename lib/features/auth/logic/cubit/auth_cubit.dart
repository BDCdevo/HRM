import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/login_response_model.dart';
import '../../data/models/user_model.dart';
import '../../data/repo/auth_repo.dart';
import 'auth_state.dart';
import '../../../../core/constants/error_messages.dart';
import '../../../../core/services/session_service.dart';

/// Auth Cubit
///
/// Manages authentication state and business logic
/// Uses AuthRepo for API calls
class AuthCubit extends Cubit<AuthState> {
  final AuthRepo _authRepo;
  final SessionService _sessionService = SessionService();

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

      // Start session tracking
      final sessionId = await _sessionService.startSession(
        userId: loginResponse.data.id,
        userType: 'employee',
        loginMethod: 'unified',
      );

      if (sessionId != null) {
        print('📊 Session started: $sessionId');
      } else {
        print('⚠️ Failed to start session tracking');
      }

      emit(AuthAuthenticated(loginResponse.data));
    } on DioException catch (e) {
      print('❌ Login DioException: ${e.message}');
      _handleDioError(e);
    } catch (e) {
      print('❌ Login Exception: $e');
      emit(const AuthError(message: ErrorMessages.unexpectedError));
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

      // Start session tracking
      final sessionId = await _sessionService.startSession(
        userId: loginResponse.data.id,
        userType: 'admin',
        loginMethod: 'admin',
      );

      if (sessionId != null) {
        print('📊 Admin session started: $sessionId');
      } else {
        print('⚠️ Failed to start admin session tracking');
      }

      emit(AuthAuthenticated(loginResponse.data));
    } on DioException catch (e) {
      print('❌ Admin Login DioException: ${e.message}');
      _handleDioError(e);
    } catch (e) {
      print('❌ Admin Login Exception: $e');
      emit(const AuthError(message: ErrorMessages.unexpectedError));
    }
  }

  /// Register
  ///
  /// Creates a new user account
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
  }) async {
    try {
      emit(const AuthLoading());

      print('📝 Attempting registration for: $email');

      final registerResponse = await _authRepo.register(
        name: name,
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
      emit(const AuthError(message: ErrorMessages.registrationFailed));
    }
  }

  /// Logout
  ///
  /// Logs out the current user
  Future<void> logout() async {
    try {
      emit(const AuthLoading());

      print('🔓 Attempting logout');

      // End session tracking
      final sessionEnded = await _sessionService.endSession();
      if (sessionEnded) {
        print('📊 Session ended successfully');
      } else {
        print('⚠️ Failed to end session tracking');
      }

      await _authRepo.logout();

      print('✅ Logout successful');
      emit(const AuthUnauthenticated());
    } on DioException catch (e) {
      print('❌ Logout DioException: ${e.message}');
      // Even if logout API fails, clear local state and session
      await _sessionService.clearSessionData();
      emit(const AuthUnauthenticated());
    } catch (e) {
      print('❌ Logout Exception: $e');
      // Even if logout fails, clear local state and session
      await _sessionService.clearSessionData();
      emit(const AuthUnauthenticated());
    }
  }

  /// Check Auth Status
  ///
  /// Checks if user is already logged in with valid token
  /// Called on app startup
  ///
  /// Optimized flow:
  /// 1. Check if token exists
  /// 2. Load cached user data (instant UI)
  /// 3. Verify token with backend (background)
  /// 4. Update UI if needed
  Future<void> checkAuthStatus() async {
    try {
      print('🔍 Checking auth status...');

      final isLoggedIn = await _authRepo.isLoggedIn();

      if (isLoggedIn) {
        print('✅ User has token');

        // Try to load cached user data first (instant)
        final cachedUser = await _authRepo.getStoredUserData();

        if (cachedUser != null) {
          print('📦 Loaded cached user data: ${cachedUser.email}');
          // Emit cached data immediately for fast UI
          emit(AuthAuthenticated(cachedUser));

          // Verify token in background and refresh data
          try {
            final user = await _authRepo.getProfile();
            print('✅ Profile verified and refreshed: ${user.email}');

            // Update with fresh data
            await _authRepo.saveUserData(user);
            emit(AuthAuthenticated(user));
          } catch (e) {
            print('⚠️ Failed to refresh profile (using cached data): $e');
            // Token might be expired, but keep user logged in with cached data
            // They'll get error when making API calls
          }
        } else {
          // No cached data, must fetch from API
          print('📡 No cached data, fetching profile from API...');
          try {
            final user = await _authRepo.getProfile();
            print('✅ Profile fetched successfully: ${user.email}');

            // Save for next time
            await _authRepo.saveUserData(user);
            emit(AuthAuthenticated(user));
          } catch (e) {
            print('❌ Failed to fetch profile (token may be expired): $e');
            // Token exists but is invalid/expired, clear it
            await _authRepo.clearAuthData();
            await _sessionService.clearSessionData();
            emit(const AuthUnauthenticated());
          }
        }
      } else {
        print('❌ User is not logged in (no token)');
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
      emit(const AuthError(message: ErrorMessages.unexpectedError));
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
      emit(const AuthError(message: ErrorMessages.passwordChangeFailed));
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
  /// Parses DioException and emits appropriate error state with user-friendly messages
  void _handleDioError(DioException error) {
    String errorMessage = ErrorMessages.unexpectedError;

    if (error.response?.data != null) {
      try {
        final errorResponse = ErrorResponseModel.fromJson(error.response!.data);

        // Check for specific error messages and provide localized versions
        String apiMessage = errorResponse.message.toLowerCase();

        if (apiMessage.contains('invalid credentials') ||
            apiMessage.contains('unauthorized') ||
            apiMessage.contains('incorrect password') ||
            apiMessage.contains('wrong password')) {
          errorMessage = ErrorMessages.invalidCredentials;
        } else if (apiMessage.contains('not found') ||
                   apiMessage.contains('does not exist')) {
          errorMessage = ErrorMessages.accountNotFound;
        } else if (apiMessage.contains('disabled') ||
                   apiMessage.contains('suspended')) {
          errorMessage = ErrorMessages.accountDisabled;
        } else if (apiMessage.contains('too many attempts') ||
                   apiMessage.contains('rate limit')) {
          errorMessage = ErrorMessages.tooManyAttempts;
        } else if (apiMessage.contains('email') && apiMessage.contains('taken')) {
          errorMessage = ErrorMessages.emailAlreadyExists;
        } else {
          // Use the API message if it's clear enough, otherwise use generic error
          errorMessage = errorResponse.message.isNotEmpty
              ? errorResponse.message
              : ErrorMessages.unexpectedError;
        }

        emit(AuthError(
          message: errorMessage,
          firstError: errorResponse.firstError,
        ));
      } catch (e) {
        emit(AuthError(
          message: error.response?.data['message'] ?? ErrorMessages.unexpectedError,
        ));
      }
    } else if (error.type == DioExceptionType.connectionTimeout) {
      emit(const AuthError(message: ErrorMessages.connectionTimeout));
    } else if (error.type == DioExceptionType.receiveTimeout) {
      emit(const AuthError(message: ErrorMessages.connectionTimeout));
    } else if (error.type == DioExceptionType.connectionError) {
      emit(const AuthError(message: ErrorMessages.noInternetConnection));
    } else {
      emit(AuthError(
        message: ErrorMessages.getDioErrorMessage(error.message),
      ));
    }
  }

  /// Reset to Initial State
  ///
  /// Useful for clearing error states
  void resetState() {
    emit(const AuthInitial());
  }
}
