import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../networking/dio_client.dart';
import '../../features/auth/data/models/session_model.dart';

/// Session Service
///
/// Manages login session tracking and monitoring
class SessionService {
  static const String _sessionIdKey = 'current_session_id';
  static const String _sessionTokenKey = 'current_session_token';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final DioClient _dioClient = DioClient.getInstance();

  /// Singleton pattern
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  SessionService._internal();

  /// Start a new session after successful login
  Future<String?> startSession({
    required int userId,
    required String userType,
    String? loginMethod,
    double? latitude,
    double? longitude,
  }) async {
    try {
      print('🟢 SessionService: Starting session for user $userId');

      // Get device and app info
      final deviceInfo = await _getDeviceInfo();
      print('📱 Device Info: $deviceInfo');

      // Prepare request data
      final requestData = {
        'user_id': userId,
        'user_type': userType,
        'device_info': deviceInfo,
        'login_method': loginMethod ?? 'unified',
      };

      // Add location if available
      if (latitude != null && longitude != null) {
        requestData['location'] = {
          'latitude': latitude,
          'longitude': longitude,
        };
      }

      print('📤 Sending session start request...');

      // Call API
      final response = await _dioClient.post(
        '/sessions/start',
        data: requestData,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final sessionId = data['session_id'].toString();
        final sessionToken = data['session_token'];

        // Save session info
        await _storage.write(key: _sessionIdKey, value: sessionId);
        await _storage.write(key: _sessionTokenKey, value: sessionToken);

        print('✅ Session started successfully: $sessionId');
        return sessionId;
      } else {
        print('❌ Session start failed: ${response.data}');
      }
    } catch (e) {
      print('❌ Error starting session: $e');
    }

    return null;
  }

  /// End the current session on logout
  Future<bool> endSession() async {
    try {
      final sessionId = await _storage.read(key: _sessionIdKey);

      if (sessionId == null) {
        print('⚠️ No active session to end');
        return true; // Consider this success
      }

      print('🟡 SessionService: Ending session $sessionId');

      // Call API
      final response = await _dioClient.put(
        '/sessions/$sessionId/end',
      );

      if (response.statusCode == 200) {
        // Clear stored session info
        await _storage.delete(key: _sessionIdKey);
        await _storage.delete(key: _sessionTokenKey);

        print('✅ Session ended successfully');
        return true;
      } else {
        print('❌ Session end failed: ${response.data}');
      }
    } catch (e) {
      print('❌ Error ending session: $e');
      // Still clear local session data even if API call fails
      await _storage.delete(key: _sessionIdKey);
      await _storage.delete(key: _sessionTokenKey);
    }

    return false;
  }

  /// Get current session ID
  Future<String?> getCurrentSessionId() async {
    return await _storage.read(key: _sessionIdKey);
  }

  /// Get current session token
  Future<String?> getCurrentSessionToken() async {
    return await _storage.read(key: _sessionTokenKey);
  }

  /// Get user's session history
  Future<List<SessionModel>> getMySessions() async {
    try {
      print('📥 Fetching user sessions...');

      final response = await _dioClient.get('/sessions/my-sessions');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List data = response.data['data'];
        final sessions = data.map((json) => SessionModel.fromJson(json)).toList();

        print('✅ Fetched ${sessions.length} sessions');
        return sessions;
      } else {
        print('❌ Failed to fetch sessions: ${response.data}');
      }
    } catch (e) {
      print('❌ Error fetching sessions: $e');
    }

    return [];
  }

  /// Get active sessions
  Future<List<SessionModel>> getActiveSessions() async {
    try {
      print('📥 Fetching active sessions...');

      final response = await _dioClient.get('/sessions/active');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List data = response.data['data'];
        final sessions = data.map((json) => SessionModel.fromJson(json)).toList();

        print('✅ Found ${sessions.length} active sessions');
        return sessions;
      } else {
        print('❌ Failed to fetch active sessions: ${response.data}');
      }
    } catch (e) {
      print('❌ Error fetching active sessions: $e');
    }

    return [];
  }

  /// Force logout from a specific session
  Future<bool> forceLogout(int sessionId) async {
    try {
      print('🔴 Force logout from session $sessionId');

      final response = await _dioClient.delete('/sessions/$sessionId/force-logout');

      if (response.statusCode == 200) {
        print('✅ Session $sessionId terminated');
        return true;
      } else {
        print('❌ Failed to terminate session: ${response.data}');
      }
    } catch (e) {
      print('❌ Error force logging out: $e');
    }

    return false;
  }

  /// Get device information
  Future<Map<String, dynamic>> _getDeviceInfo() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    PackageInfo? packageInfo;

    try {
      packageInfo = await PackageInfo.fromPlatform();
    } catch (e) {
      print('⚠️ Could not get package info: $e');
    }

    if (Platform.isAndroid) {
      try {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        return {
          'type': 'Android',
          'model': androidInfo.model,
          'device_id': androidInfo.id, // Unique device ID
          'os_version': 'Android ${androidInfo.version.release} (SDK ${androidInfo.version.sdkInt})',
          'app_version': packageInfo?.version ?? 'unknown',
        };
      } catch (e) {
        print('⚠️ Error getting Android info: $e');
        return {
          'type': 'Android',
          'model': 'Unknown',
          'os_version': 'Unknown',
          'app_version': packageInfo?.version ?? 'unknown',
        };
      }
    } else if (Platform.isIOS) {
      try {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        return {
          'type': 'iOS',
          'model': iosInfo.model,
          'device_id': iosInfo.identifierForVendor, // Unique device ID
          'os_version': '${iosInfo.systemName} ${iosInfo.systemVersion}',
          'app_version': packageInfo?.version ?? 'unknown',
        };
      } catch (e) {
        print('⚠️ Error getting iOS info: $e');
        return {
          'type': 'iOS',
          'model': 'Unknown',
          'os_version': 'Unknown',
          'app_version': packageInfo?.version ?? 'unknown',
        };
      }
    } else {
      return {
        'type': 'Unknown',
        'model': 'Unknown',
        'os_version': 'Unknown',
        'app_version': packageInfo?.version ?? 'unknown',
      };
    }
  }

  /// Clear all session data (for logout)
  Future<void> clearSessionData() async {
    await _storage.delete(key: _sessionIdKey);
    await _storage.delete(key: _sessionTokenKey);
    print('🗑️ Session data cleared');
  }

  /// Check if session exists (has session ID stored)
  Future<bool> hasActiveSession() async {
    final sessionId = await getCurrentSessionId();
    return sessionId != null && sessionId.isNotEmpty;
  }

  /// Restore Session on App Start
  ///
  /// Checks if there's a stored session and validates it with backend
  /// Returns session info if valid, null otherwise
  Future<SessionModel?> restoreSession() async {
    try {
      final sessionId = await getCurrentSessionId();

      if (sessionId == null) {
        print('⚠️ No session to restore');
        return null;
      }

      print('🔄 Restoring session: $sessionId');

      // Verify session with backend
      final response = await _dioClient.get('/sessions/$sessionId/verify');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final session = SessionModel.fromJson(response.data['data']);

        if (session.isActive) {
          print('✅ Session restored successfully');
          return session;
        } else {
          print('⚠️ Session is no longer active: ${session.status}');
          // Clear inactive session
          await clearSessionData();
          return null;
        }
      } else {
        print('❌ Session verification failed');
        await clearSessionData();
        return null;
      }
    } catch (e) {
      print('❌ Error restoring session: $e');
      // Don't clear session data on network error
      // User might be offline
      return null;
    }
  }

  /// Update Session Activity (heartbeat)
  ///
  /// Sends periodic heartbeat to keep session alive
  /// Call this every 5-10 minutes when app is active
  Future<bool> updateSessionActivity() async {
    try {
      final sessionId = await getCurrentSessionId();

      if (sessionId == null) {
        print('⚠️ No active session to update');
        return false;
      }

      final response = await _dioClient.put('/sessions/$sessionId/heartbeat');

      if (response.statusCode == 200) {
        print('💓 Session activity updated');
        return true;
      }
    } catch (e) {
      print('❌ Error updating session activity: $e');
    }

    return false;
  }
}
