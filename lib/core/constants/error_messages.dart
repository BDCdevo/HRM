/// Error Messages
///
/// Centralized error messages for better UX
/// Provides clear, user-friendly error messages in Arabic and English
class ErrorMessages {
  // ==================== Authentication Errors ====================

  /// Login errors
  static const String invalidCredentials =
      'البريد الإلكتروني أو كلمة المرور غير صحيحة';

  static const String invalidCredentialsEn =
      'Email or password is incorrect';

  static const String emailRequired =
      'يرجى إدخال البريد الإلكتروني';

  static const String emailRequiredEn =
      'Please enter your email';

  static const String passwordRequired =
      'يرجى إدخال كلمة المرور';

  static const String passwordRequiredEn =
      'Please enter your password';

  static const String invalidEmailFormat =
      'صيغة البريد الإلكتروني غير صحيحة';

  static const String invalidEmailFormatEn =
      'Invalid email format';

  static const String passwordTooShort =
      'كلمة المرور يجب أن تكون 6 أحرف على الأقل';

  static const String passwordTooShortEn =
      'Password must be at least 6 characters';

  static const String accountNotFound =
      'الحساب غير موجود. يرجى التأكد من البريد الإلكتروني';

  static const String accountNotFoundEn =
      'Account not found. Please check your email';

  static const String accountDisabled =
      'تم تعطيل هذا الحساب. يرجى التواصل مع الإدارة';

  static const String accountDisabledEn =
      'This account has been disabled. Please contact administration';

  static const String tooManyAttempts =
      'محاولات تسجيل دخول كثيرة جداً. يرجى المحاولة لاحقاً';

  static const String tooManyAttemptsEn =
      'Too many login attempts. Please try again later';

  // ==================== Registration Errors ====================

  static const String emailAlreadyExists =
      'البريد الإلكتروني مسجل مسبقاً';

  static const String emailAlreadyExistsEn =
      'Email is already registered';

  static const String passwordMismatch =
      'كلمة المرور غير متطابقة';

  static const String passwordMismatchEn =
      'Passwords do not match';

  static const String registrationFailed =
      'فشل التسجيل. يرجى المحاولة مرة أخرى';

  static const String registrationFailedEn =
      'Registration failed. Please try again';

  // ==================== Attendance Errors ====================

  static const String locationPermissionDenied =
      'يجب السماح بالوصول للموقع لتسجيل الحضور';

  static const String locationPermissionDeniedEn =
      'Location permission is required to record attendance';

  static const String locationServiceDisabled =
      'خدمة تحديد الموقع معطلة. يرجى تفعيلها من الإعدادات';

  static const String locationServiceDisabledEn =
      'Location service is disabled. Please enable it in settings';

  static const String noBranchAssigned =
      'لم يتم تعيين فرع لك. يرجى التواصل مع قسم الموارد البشرية';

  static const String noBranchAssignedEn =
      'No branch assigned to you. Please contact HR department';

  static const String outsideBranchArea =
      'أنت خارج نطاق الفرع المسموح. يرجى التوجه للفرع';

  static const String outsideBranchAreaEn =
      'You are outside the allowed branch area. Please go to the branch';

  static const String alreadyCheckedIn =
      'لديك جلسة حضور نشطة بالفعل';

  static const String alreadyCheckedInEn =
      'You already have an active attendance session';

  static const String noActiveSession =
      'لا توجد جلسة حضور نشطة لتسجيل الانصراف';

  static const String noActiveSessionEn =
      'No active attendance session to check out';

  static const String checkInFailed =
      'فشل تسجيل الحضور. يرجى المحاولة مرة أخرى';

  static const String checkInFailedEn =
      'Check-in failed. Please try again';

  static const String checkOutFailed =
      'فشل تسجيل الانصراف. يرجى المحاولة مرة أخرى';

  static const String checkOutFailedEn =
      'Check-out failed. Please try again';

  static const String locationAccuracyLow =
      'دقة الموقع منخفضة. يرجى الانتقال لمكان مفتوح';

  static const String locationAccuracyLowEn =
      'Location accuracy is low. Please move to an open area';

  // ==================== Leave Request Errors ====================

  static const String noLeaveTypes =
      'لا توجد أنواع إجازات متاحة. يرجى التواصل مع الموارد البشرية';

  static const String noLeaveTypesEn =
      'No leave types available. Please contact HR';

  static const String insufficientBalance =
      'رصيد الإجازات غير كافٍ لهذا النوع';

  static const String insufficientBalanceEn =
      'Insufficient leave balance for this type';

  static const String invalidDateRange =
      'نطاق التاريخ غير صحيح. يرجى التحقق من التواريخ';

  static const String invalidDateRangeEn =
      'Invalid date range. Please check the dates';

  static const String startDateRequired =
      'يرجى تحديد تاريخ البداية';

  static const String startDateRequiredEn =
      'Please select start date';

  static const String endDateRequired =
      'يرجى تحديد تاريخ النهاية';

  static const String endDateRequiredEn =
      'Please select end date';

  static const String reasonRequired =
      'يرجى إدخال سبب الإجازة';

  static const String reasonRequiredEn =
      'Please enter leave reason';

  static const String leaveRequestFailed =
      'فشل تقديم طلب الإجازة. يرجى المحاولة مرة أخرى';

  static const String leaveRequestFailedEn =
      'Failed to submit leave request. Please try again';

  static const String overlappingLeave =
      'لديك إجازة أخرى في نفس الفترة';

  static const String overlappingLeaveEn =
      'You have another leave in the same period';

  // ==================== Network Errors ====================

  static const String noInternetConnection =
      'لا يوجد اتصال بالإنترنت. يرجى التحقق من الشبكة';

  static const String noInternetConnectionEn =
      'No internet connection. Please check your network';

  static const String connectionTimeout =
      'انتهت مهلة الاتصال. يرجى المحاولة مرة أخرى';

  static const String connectionTimeoutEn =
      'Connection timeout. Please try again';

  static const String serverError =
      'خطأ في الخادم. يرجى المحاولة لاحقاً';

  static const String serverErrorEn =
      'Server error. Please try again later';

  static const String serviceUnavailable =
      'الخدمة غير متاحة حالياً. يرجى المحاولة لاحقاً';

  static const String serviceUnavailableEn =
      'Service unavailable. Please try again later';

  // ==================== Chat Errors ====================

  static const String messageSendFailed =
      'فشل إرسال الرسالة. يرجى المحاولة مرة أخرى';

  static const String messageSendFailedEn =
      'Failed to send message. Please try again';

  static const String fileUploadFailed =
      'فشل رفع الملف. يرجى التحقق من حجم الملف والمحاولة مرة أخرى';

  static const String fileUploadFailedEn =
      'Failed to upload file. Please check file size and try again';

  static const String fileTooLarge =
      'حجم الملف كبير جداً. الحد الأقصى 10 ميجابايت';

  static const String fileTooLargeEn =
      'File is too large. Maximum size is 10MB';

  static const String recordingFailed =
      'فشل تسجيل الصوت. يرجى التحقق من صلاحيات الميكروفون';

  static const String recordingFailedEn =
      'Failed to record audio. Please check microphone permission';

  // ==================== Profile Errors ====================

  static const String profileUpdateFailed =
      'فشل تحديث الملف الشخصي. يرجى المحاولة مرة أخرى';

  static const String profileUpdateFailedEn =
      'Failed to update profile. Please try again';

  static const String passwordChangeFailed =
      'فشل تغيير كلمة المرور. يرجى التحقق من كلمة المرور الحالية';

  static const String passwordChangeFailedEn =
      'Failed to change password. Please check your current password';

  static const String oldPasswordIncorrect =
      'كلمة المرور الحالية غير صحيحة';

  static const String oldPasswordIncorrectEn =
      'Current password is incorrect';

  static const String imageUploadFailed =
      'فشل رفع الصورة. يرجى اختيار صورة أصغر حجماً';

  static const String imageUploadFailedEn =
      'Failed to upload image. Please choose a smaller image';

  // ==================== General Errors ====================

  static const String unexpectedError =
      'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى';

  static const String unexpectedErrorEn =
      'An unexpected error occurred. Please try again';

  static const String operationFailed =
      'فشلت العملية. يرجى المحاولة مرة أخرى';

  static const String operationFailedEn =
      'Operation failed. Please try again';

  static const String dataNotFound =
      'لم يتم العثور على البيانات';

  static const String dataNotFoundEn =
      'Data not found';

  static const String unauthorized =
      'انتهت صلاحية الجلسة. يرجى تسجيل الدخول مرة أخرى';

  static const String unauthorizedEn =
      'Session expired. Please login again';

  static const String forbidden =
      'ليس لديك صلاحية لتنفيذ هذا الإجراء';

  static const String forbiddenEn =
      'You do not have permission to perform this action';

  // ==================== Validation Errors ====================

  static const String fieldRequired =
      'هذا الحقل مطلوب';

  static const String fieldRequiredEn =
      'This field is required';

  static const String invalidInput =
      'المدخل غير صحيح';

  static const String invalidInputEn =
      'Invalid input';

  static const String phoneNumberInvalid =
      'رقم الهاتف غير صحيح';

  static const String phoneNumberInvalidEn =
      'Invalid phone number';

  // ==================== Helper Methods ====================

  /// Get localized error message based on error code
  static String getErrorMessage(String? errorCode, {bool isArabic = true}) {
    if (errorCode == null || errorCode.isEmpty) {
      return isArabic ? unexpectedError : unexpectedErrorEn;
    }

    // Map common error codes to messages
    switch (errorCode.toLowerCase()) {
      case 'invalid_credentials':
      case 'unauthorized':
      case '401':
        return isArabic ? invalidCredentials : invalidCredentialsEn;

      case 'email_not_found':
      case 'account_not_found':
        return isArabic ? accountNotFound : accountNotFoundEn;

      case 'email_already_exists':
      case 'email_taken':
        return isArabic ? emailAlreadyExists : emailAlreadyExistsEn;

      case 'no_internet':
      case 'network_error':
        return isArabic ? noInternetConnection : noInternetConnectionEn;

      case 'timeout':
      case 'connection_timeout':
        return isArabic ? connectionTimeout : connectionTimeoutEn;

      case 'server_error':
      case '500':
      case '502':
      case '503':
        return isArabic ? serverError : serverErrorEn;

      case 'no_branch':
      case 'branch_not_assigned':
        return isArabic ? noBranchAssigned : noBranchAssignedEn;

      case 'outside_range':
      case 'location_mismatch':
        return isArabic ? outsideBranchArea : outsideBranchAreaEn;

      case 'insufficient_balance':
        return isArabic ? insufficientBalance : insufficientBalanceEn;

      default:
        return isArabic ? unexpectedError : unexpectedErrorEn;
    }
  }

  /// Get user-friendly error message from DioException
  static String getDioErrorMessage(dynamic error, {bool isArabic = true}) {
    if (error.toString().contains('SocketException') ||
        error.toString().contains('Failed host lookup')) {
      return isArabic ? noInternetConnection : noInternetConnectionEn;
    }

    if (error.toString().contains('Connection timeout') ||
        error.toString().contains('Receiving data timeout')) {
      return isArabic ? connectionTimeout : connectionTimeoutEn;
    }

    return isArabic ? unexpectedError : unexpectedErrorEn;
  }
}
