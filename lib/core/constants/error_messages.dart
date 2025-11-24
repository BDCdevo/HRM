/// Error Messages
///
/// Centralized error messages for better UX
/// Provides clear, user-friendly error messages in English
class ErrorMessages {
  // ==================== Authentication Errors ====================

  /// Login errors
  static const String invalidCredentials =
      'Email or password is incorrect';

  static const String emailRequired =
      'Please enter your email';

  static const String passwordRequired =
      'Please enter your password';

  static const String invalidEmailFormat =
      'Invalid email format';

  static const String passwordTooShort =
      'Password must be at least 6 characters';

  static const String accountNotFound =
      'Account not found. Please check your email';

  static const String accountDisabled =
      'This account has been disabled. Please contact administration';

  static const String tooManyAttempts =
      'Too many login attempts. Please try again later';

  // ==================== Registration Errors ====================

  static const String emailAlreadyExists =
      'Email is already registered';

  static const String passwordMismatch =
      'Passwords do not match';

  static const String registrationFailed =
      'Registration failed. Please try again';

  // ==================== Attendance Errors ====================

  static const String locationPermissionDenied =
      'Location permission is required to record attendance';

  static const String locationServiceDisabled =
      'Location service is disabled. Please enable it in settings';

  static const String noBranchAssigned =
      'No branch assigned to you. Please contact HR department';

  static const String outsideBranchArea =
      'You are outside the allowed branch area. Please go to the branch';

  static const String alreadyCheckedIn =
      'You already have an active attendance session';

  static const String noActiveSession =
      'No active attendance session to check out';

  static const String checkInFailed =
      'Check-in failed. Please try again';

  static const String checkOutFailed =
      'Check-out failed. Please try again';

  static const String locationAccuracyLow =
      'Location accuracy is low. Please move to an open area';

  // ==================== Leave Request Errors ====================

  static const String noLeaveTypes =
      'No leave types available. Please contact HR';

  static const String insufficientBalance =
      'Insufficient leave balance for this type';

  static const String invalidDateRange =
      'Invalid date range. Please check the dates';

  static const String startDateRequired =
      'Please select start date';

  static const String endDateRequired =
      'Please select end date';

  static const String reasonRequired =
      'Please enter leave reason';

  static const String leaveRequestFailed =
      'Failed to submit leave request. Please try again';

  static const String overlappingLeave =
      'You have another leave in the same period';

  // ==================== Network Errors ====================

  static const String noInternetConnection =
      'No internet connection. Please check your network';

  static const String connectionTimeout =
      'Connection timeout. Please try again';

  static const String serverError =
      'Server error. Please try again later';

  static const String serviceUnavailable =
      'Service unavailable. Please try again later';

  // ==================== Chat Errors ====================

  static const String messageSendFailed =
      'Failed to send message. Please try again';

  static const String fileUploadFailed =
      'Failed to upload file. Please check file size and try again';

  static const String fileTooLarge =
      'File is too large. Maximum size is 10MB';

  static const String recordingFailed =
      'Failed to record audio. Please check microphone permission';

  // ==================== Profile Errors ====================

  static const String profileUpdateFailed =
      'Failed to update profile. Please try again';

  static const String passwordChangeFailed =
      'Failed to change password. Please check your current password';

  static const String oldPasswordIncorrect =
      'Current password is incorrect';

  static const String imageUploadFailed =
      'Failed to upload image. Please choose a smaller image';

  // ==================== General Errors ====================

  static const String unexpectedError =
      'An unexpected error occurred. Please try again';

  static const String operationFailed =
      'Operation failed. Please try again';

  static const String dataNotFound =
      'Data not found';

  static const String unauthorized =
      'Session expired. Please login again';

  static const String forbidden =
      'You do not have permission to perform this action';

  // ==================== Validation Errors ====================

  static const String fieldRequired =
      'This field is required';

  static const String invalidInput =
      'Invalid input';

  static const String phoneNumberInvalid =
      'Invalid phone number';

  // ==================== Helper Methods ====================

  /// Get localized error message based on error code
  static String getErrorMessage(String? errorCode) {
    if (errorCode == null || errorCode.isEmpty) {
      return unexpectedError;
    }

    // Map common error codes to messages
    switch (errorCode.toLowerCase()) {
      case 'invalid_credentials':
      case 'unauthorized':
      case '401':
        return invalidCredentials;

      case 'email_not_found':
      case 'account_not_found':
        return accountNotFound;

      case 'email_already_exists':
      case 'email_taken':
        return emailAlreadyExists;

      case 'no_internet':
      case 'network_error':
        return noInternetConnection;

      case 'timeout':
      case 'connection_timeout':
        return connectionTimeout;

      case 'server_error':
      case '500':
      case '502':
      case '503':
        return serverError;

      case 'no_branch':
      case 'branch_not_assigned':
        return noBranchAssigned;

      case 'outside_range':
      case 'location_mismatch':
        return outsideBranchArea;

      case 'insufficient_balance':
        return insufficientBalance;

      default:
        return unexpectedError;
    }
  }

  /// Get user-friendly error message from DioException
  static String getDioErrorMessage(dynamic error) {
    if (error.toString().contains('SocketException') ||
        error.toString().contains('Failed host lookup')) {
      return noInternetConnection;
    }

    if (error.toString().contains('Connection timeout') ||
        error.toString().contains('Receiving data timeout')) {
      return connectionTimeout;
    }

    return unexpectedError;
  }
}
