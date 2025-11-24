import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Biometric Authentication Service
///
/// Handles fingerprint and face ID authentication
/// Provides secure and convenient login method
class BiometricService {
  // Singleton pattern
  static BiometricService? _instance;
  static BiometricService get instance {
    _instance ??= BiometricService._();
    return _instance!;
  }

  BiometricService._();

  final LocalAuthentication _auth = LocalAuthentication();

  // SharedPreferences keys
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _biometricUserIdKey = 'biometric_user_id';

  /// Check if device supports biometric authentication
  Future<bool> canCheckBiometrics() async {
    try {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await _auth.isDeviceSupported();

      if (kDebugMode) {
        debugPrint('📱 Biometric available: $canAuthenticate');
      }

      return canAuthenticate;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Biometric check failed: $e');
      }
      return false;
    }
  }

  /// Get list of available biometric types
  ///
  /// Returns list like: [BiometricType.face, BiometricType.fingerprint]
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Get biometrics failed: $e');
      }
      return [];
    }
  }

  /// Authenticate with biometrics
  ///
  /// Shows system biometric prompt and returns authentication result
  ///
  /// Parameters:
  /// - [localizedReason]: Message shown to user (e.g., "Please authenticate to login")
  /// - [useErrorDialogs]: Show error dialogs if authentication fails (default: true)
  /// - [stickyAuth]: Keep biometric dialog on screen if user switches apps (default: false)
  ///
  /// Returns: true if authentication successful, false otherwise
  Future<bool> authenticate({
    required String localizedReason,
    bool useErrorDialogs = true,
    bool stickyAuth = false,
  }) async {
    try {
      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: localizedReason,
        options: AuthenticationOptions(
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyAuth,
          biometricOnly: true, // Don't allow PIN/Pattern as fallback
        ),
      );

      if (kDebugMode) {
        debugPrint('🔐 Biometric auth: ${didAuthenticate ? "Success" : "Failed"}');
      }

      return didAuthenticate;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Biometric auth error: ${e.code} - ${e.message}');
      }

      // Handle specific errors
      if (e.code == 'NotAvailable') {
        // Biometrics not available on this device
        return false;
      } else if (e.code == 'LockedOut') {
        // Too many failed attempts, biometrics locked
        return false;
      } else if (e.code == 'PermanentlyLockedOut') {
        // Device needs to be unlocked with PIN/password
        return false;
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Unexpected biometric error: $e');
      }
      return false;
    }
  }

  /// Check if biometric is enabled for this app
  Future<bool> isBiometricEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_biometricEnabledKey) ?? false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Check biometric enabled failed: $e');
      }
      return false;
    }
  }

  /// Enable biometric authentication
  ///
  /// Saves user preference and user ID
  /// Call this after successful password login
  Future<void> enableBiometric(int userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_biometricEnabledKey, true);
      await prefs.setInt(_biometricUserIdKey, userId);

      if (kDebugMode) {
        debugPrint('✅ Biometric enabled for user: $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Enable biometric failed: $e');
      }
    }
  }

  /// Disable biometric authentication
  ///
  /// Removes saved preferences
  Future<void> disableBiometric() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_biometricEnabledKey);
      await prefs.remove(_biometricUserIdKey);

      if (kDebugMode) {
        debugPrint('✅ Biometric disabled');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Disable biometric failed: $e');
      }
    }
  }

  /// Get saved biometric user ID
  ///
  /// Returns null if biometric not enabled
  Future<int?> getSavedUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_biometricUserIdKey);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Get saved user ID failed: $e');
      }
      return null;
    }
  }

  /// Get user-friendly biometric type name
  ///
  /// Converts BiometricType enum to readable string
  String getBiometricTypeName(BiometricType type) {
    switch (type) {
      case BiometricType.face:
        return 'Face ID';
      case BiometricType.fingerprint:
        return 'Fingerprint';
      case BiometricType.iris:
        return 'Iris Scan';
      case BiometricType.strong:
        return 'Strong Biometric';
      case BiometricType.weak:
        return 'Weak Biometric';
    }
  }

  /// Get all available biometric names as comma-separated string
  ///
  /// Example: "Face ID, Fingerprint"
  Future<String> getAvailableBiometricsString() async {
    final types = await getAvailableBiometrics();
    if (types.isEmpty) {
      return 'None';
    }

    return types.map((type) => getBiometricTypeName(type)).join(', ');
  }

  /// Stop biometric authentication
  ///
  /// Cancels any ongoing authentication
  Future<void> stopAuthentication() async {
    try {
      await _auth.stopAuthentication();

      if (kDebugMode) {
        debugPrint('🛑 Biometric authentication stopped');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Stop authentication failed: $e');
      }
    }
  }

  /// Check if should show biometric prompt
  ///
  /// Returns true if:
  /// - Biometric is enabled
  /// - Device supports biometrics
  /// - User has enrolled biometrics
  Future<bool> shouldShowBiometricPrompt() async {
    final isEnabled = await isBiometricEnabled();
    if (!isEnabled) return false;

    final canCheck = await canCheckBiometrics();
    if (!canCheck) return false;

    final types = await getAvailableBiometrics();
    return types.isNotEmpty;
  }
}
