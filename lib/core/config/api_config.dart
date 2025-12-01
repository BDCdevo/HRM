/// API Configuration for HRM Backend
///
/// This file contains all API endpoints and configuration for connecting
/// to the Laravel backend server.
///
/// Backend Documentation: See API_DOCUMENTATION.md in backend project
class ApiConfig {
  // Base URL Configuration
  // =====================================================

  /// For Android Emulator
  static const String baseUrlEmulator = 'http://10.0.2.2:8000/api/v1';

  /// For iOS Simulator / Web
  static const String baseUrlSimulator = 'http://localhost:8000/api/v1';

  /// For Real Device (Replace with your computer's IP)
  static const String baseUrlRealDevice = 'http://192.168.1.X:8000/api/v1';

  /// Production Server
  static const String baseUrlProduction = 'https://erp1.bdcbiz.com/api/v1';

  /// Current Environment Base URL
  /// Change this based on your testing environment
  /// Options: baseUrlEmulator, baseUrlSimulator, baseUrlRealDevice, baseUrlProduction
  static const String baseUrl = baseUrlProduction;

  // API Endpoints
  // =====================================================

  /// Authentication Endpoints
  static const String unifiedLogin = '/auth/unified-login'; // Auto-detect Admin/Employee
  static const String unifiedLogout = '/auth/unified-logout';
  static const String login = '/auth/login'; // Legacy employee login
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String checkUser = '/auth/check-user';

  /// Admin Authentication Endpoints (Legacy)
  static const String adminLogin = '/admin/auth/login';
  static const String adminLogout = '/admin/auth/logout';
  static const String adminProfile = '/admin/auth/profile';

  /// Profile Endpoints
  static const String profile = '/profile';
  static const String updateProfile = '/profile';
  static const String uploadProfileImage = '/profile/upload-image';
  static const String changePassword = '/profile/change-password';
  static const String deleteAccount = '/profile';

  /// Dashboard Endpoints
  static const String dashboardStats = '/dashboard/stats';

  /// Departments Endpoints
  static const String departments = '/departments';
  static String departmentPositions(int departmentId) => '/departments/$departmentId/positions';

  /// Branches Endpoints
  static const String branches = '/branches';
  static String branchDetails(int id) => '/branches/$id';

  /// Attendance Endpoints
  static const String checkIn = '/employee/attendance/check-in';
  static const String checkOut = '/employee/attendance/check-out';
  static const String todayStatus = '/employee/attendance/status';
  static const String todaySession = '/employee/attendance/sessions';
  static const String attendanceDuration = '/employee/attendance/duration';
  static const String attendanceHistory = '/employee/attendance/history';
  static const String attendanceSummary = '/attendance/summary';
  static const String attendanceSummaryToday = '/attendance/summary/today';

  /// Notifications Endpoints
  static const String notifications = '/notifications';
  static String markNotificationAsRead(String id) => '/notifications/$id/read';
  static const String markAllNotificationsAsRead = '/notifications/read-all';
  static String deleteNotification(String id) => '/notifications/$id';

  /// Leave Management Endpoints
  static const String vacationTypes = '/leaves/types';
  static const String applyLeave = '/leaves';
  static const String leaveHistory = '/leaves';
  static const String leaveBalance = '/leaves/balance';
  static String leaveDetails(int id) => '/leaves/$id';
  static String cancelLeave(int id) => '/leaves/$id';

  /// Work Schedule Endpoints
  static const String workSchedule = '/work-schedule';

  /// Reports Endpoints
  static const String monthlyReport = '/reports/monthly';
  static const String monthlyReportAllEmployees = '/reports/monthly/all-employees';
  static const String weeklyStats = '/employee/attendance/weekly-stats';

  /// Request Management Endpoints
  static const String requests = '/requests';
  static const String requestStatistics = '/requests/statistics';
  static String requestDetails(int id) => '/requests/$id';

  /// Utility Endpoints
  static const String upload = '/upload';
  static const String contactUs = '/contact-us';
  static const String updateFcmToken = '/fcm-token';

  /// Chat Endpoints
  static const String conversations = '/conversations';
  static const String users = '/users'; // Get users for starting new chat
  static String conversationMessages(int conversationId) => '/conversations/$conversationId/messages';
  static String sendMessage(int conversationId) => '/conversations/$conversationId/messages';
  static String sendTypingIndicator(int conversationId) => '/conversations/$conversationId/typing';
  static String deleteMessage(int conversationId, int messageId) => '/conversations/$conversationId/messages/$messageId';
  static String createConversation = '/conversations';

  // HTTP Headers
  // =====================================================

  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Timeout Configuration
  // =====================================================

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 60); // Increased for file downloads
  static const Duration sendTimeout = Duration(seconds: 120); // Increased for file uploads (images, voice, documents)

  // Helper Methods
  // =====================================================

  /// Get full URL for an endpoint
  static String getFullUrl(String endpoint) {
    return baseUrl + endpoint;
  }

  /// Check if using emulator
  static bool get isEmulator => baseUrl == baseUrlEmulator;

  /// Check if using real device
  static bool get isRealDevice => baseUrl == baseUrlRealDevice;

  /// Check if using production
  static bool get isProduction => baseUrl == baseUrlProduction;

  /// Get current environment name
  static String get environmentName {
    if (isProduction) return 'Production';
    if (isEmulator) return 'Emulator';
    if (isRealDevice) return 'Real Device';
    return 'Simulator';
  }
}
