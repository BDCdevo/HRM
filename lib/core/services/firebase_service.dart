import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Firebase Service
///
/// Centralized Firebase configuration and initialization
/// Handles Crashlytics and Analytics setup
class FirebaseService {
  // Singleton pattern
  static FirebaseService? _instance;
  static FirebaseService get instance {
    _instance ??= FirebaseService._();
    return _instance!;
  }

  FirebaseService._();

  // Firebase Analytics instance
  late FirebaseAnalytics analytics;
  late FirebaseAnalyticsObserver analyticsObserver;

  /// Initialize Firebase Services
  ///
  /// Call this in main.dart before runApp()
  /// Initializes Crashlytics and Analytics
  Future<void> initialize() async {
    try {
      // Initialize Firebase
      await Firebase.initializeApp(
        // TODO: Add your Firebase options here
        // Get from Firebase Console > Project Settings > Your apps
        // Download google-services.json (Android) and GoogleService-Info.plist (iOS)
        // options: DefaultFirebaseOptions.currentPlatform,
      );

      // Initialize Crashlytics
      await _initializeCrashlytics();

      // Initialize Analytics
      await _initializeAnalytics();

      if (kDebugMode) {
        debugPrint('✅ Firebase initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Firebase initialization failed: $e');
      }
      // Don't rethrow - app should work without Firebase
    }
  }

  /// Initialize Crashlytics
  Future<void> _initializeCrashlytics() async {
    // Pass all uncaught errors to Crashlytics
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };

    // Pass all uncaught asynchronous errors to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    // Enable Crashlytics collection
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

    if (kDebugMode) {
      debugPrint('✅ Crashlytics initialized');
    }
  }

  /// Initialize Analytics
  Future<void> _initializeAnalytics() async {
    analytics = FirebaseAnalytics.instance;
    analyticsObserver = FirebaseAnalyticsObserver(analytics: analytics);

    // Set analytics collection enabled
    await analytics.setAnalyticsCollectionEnabled(true);

    if (kDebugMode) {
      debugPrint('✅ Analytics initialized');
    }
  }

  /// Log custom event
  ///
  /// Example:
  /// ```dart
  /// FirebaseService.instance.logEvent(
  ///   name: 'check_in_success',
  ///   parameters: {'location': 'Office A'},
  /// );
  /// ```
  Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await analytics.logEvent(
        name: name,
        parameters: parameters,
      );

      if (kDebugMode) {
        debugPrint('📊 Analytics Event: $name ${parameters ?? ""}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Analytics event failed: $e');
      }
    }
  }

  /// Log screen view
  ///
  /// Example:
  /// ```dart
  /// FirebaseService.instance.logScreenView(
  ///   screenName: 'Dashboard',
  ///   screenClass: 'DashboardScreen',
  /// );
  /// ```
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    try {
      await analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass ?? screenName,
      );

      if (kDebugMode) {
        debugPrint('📊 Screen View: $screenName');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Screen view logging failed: $e');
      }
    }
  }

  /// Set user ID for analytics
  ///
  /// Call this after successful login
  Future<void> setUserId(String userId) async {
    try {
      await analytics.setUserId(id: userId);

      if (kDebugMode) {
        debugPrint('📊 User ID set: $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Set user ID failed: $e');
      }
    }
  }

  /// Set user properties
  ///
  /// Example:
  /// ```dart
  /// FirebaseService.instance.setUserProperty(
  ///   name: 'user_type',
  ///   value: 'employee',
  /// );
  /// ```
  Future<void> setUserProperty({
    required String name,
    required String value,
  }) async {
    try {
      await analytics.setUserProperty(name: name, value: value);

      if (kDebugMode) {
        debugPrint('📊 User Property: $name = $value');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Set user property failed: $e');
      }
    }
  }

  /// Log non-fatal error to Crashlytics
  ///
  /// Use for handled errors that you want to track
  Future<void> logError(
    dynamic error,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  }) async {
    try {
      await FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: reason,
        fatal: fatal,
      );

      if (kDebugMode) {
        debugPrint('🔥 Crashlytics Error: $error');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Crashlytics logging failed: $e');
      }
    }
  }

  /// Set custom key for crash reports
  ///
  /// Adds context to crash reports
  Future<void> setCustomKey(String key, dynamic value) async {
    try {
      await FirebaseCrashlytics.instance.setCustomKey(key, value);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Set custom key failed: $e');
      }
    }
  }

  /// Set user identifier for crash reports
  Future<void> setCrashlyticsUserId(String userId) async {
    try {
      await FirebaseCrashlytics.instance.setUserIdentifier(userId);

      if (kDebugMode) {
        debugPrint('🔥 Crashlytics User ID: $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Set Crashlytics user ID failed: $e');
      }
    }
  }

  /// Log message to Crashlytics
  Future<void> log(String message) async {
    try {
      await FirebaseCrashlytics.instance.log(message);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Crashlytics log failed: $e');
      }
    }
  }

  // ==================== Pre-defined Analytics Events ====================

  /// Log login event
  Future<void> logLogin({required String method}) async {
    await logEvent(
      name: 'login',
      parameters: {'method': method},
    );
  }

  /// Log sign up event
  Future<void> logSignUp({required String method}) async {
    await logEvent(
      name: 'sign_up',
      parameters: {'method': method},
    );
  }

  /// Log check-in event
  Future<void> logCheckIn({
    required String branchName,
    required double latitude,
    required double longitude,
  }) async {
    await logEvent(
      name: 'check_in',
      parameters: {
        'branch': branchName,
        'latitude': latitude,
        'longitude': longitude,
      },
    );
  }

  /// Log check-out event
  Future<void> logCheckOut({
    required String branchName,
    required double workingHours,
  }) async {
    await logEvent(
      name: 'check_out',
      parameters: {
        'branch': branchName,
        'working_hours': workingHours,
      },
    );
  }

  /// Log leave request event
  Future<void> logLeaveRequest({
    required String leaveType,
    required int days,
  }) async {
    await logEvent(
      name: 'leave_request',
      parameters: {
        'leave_type': leaveType,
        'days': days,
      },
    );
  }

  /// Log chat message sent
  Future<void> logChatMessageSent({
    required String messageType, // text, image, file, voice
  }) async {
    await logEvent(
      name: 'chat_message_sent',
      parameters: {
        'message_type': messageType,
      },
    );
  }

  /// Log profile update
  Future<void> logProfileUpdate() async {
    await logEvent(name: 'profile_update');
  }

  /// Log password change
  Future<void> logPasswordChange() async {
    await logEvent(name: 'password_change');
  }

  /// Log app open
  Future<void> logAppOpen() async {
    await logEvent(name: 'app_open');
  }
}
