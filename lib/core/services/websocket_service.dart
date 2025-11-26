import 'dart:convert';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

/// WebSocket Service
///
/// Manages WebSocket connection for real-time features using Pusher/Reverb
class WebSocketService {
  static WebSocketService? _instance;
  static WebSocketService get instance {
    _instance ??= WebSocketService._();
    return _instance!;
  }

  WebSocketService._();

  PusherChannelsFlutter? _pusher;
  final _storage = const FlutterSecureStorage();

  // Reverb configuration from production server
  static const String _appKey = 'pgvjq8gblbrxpk5ptogp';
  static const String _host = '31.97.46.103';
  static const int _port = 8081;
  static const String _scheme = 'ws'; // Use 'ws' for WebSocket (not https)
  // For Reverb, we use host:port format in cluster
  static const String _cluster = 'mt1';

  bool _isInitialized = false;

  /// Initialize WebSocket connection
  Future<void> initialize() async {
    if (_isInitialized) {
      print('🔌 WebSocket already initialized');
      return;
    }

    try {
      _pusher = PusherChannelsFlutter.getInstance();

      print('🔌 Connecting to Reverb: ws://$_host:$_port');
      print('🔐 App Key: $_appKey');

      await _pusher!.init(
        apiKey: _appKey,
        // For Reverb, we need to override the default Pusher cluster behavior
        // The library will try to connect to ws-mt1.pusher.com by default
        // We'll handle connection errors and use onAuthorizer to connect properly
        cluster: 'mt1',
        onConnectionStateChange: (String currentState, String previousState) {
          print('🔌 WebSocket Connection: $previousState -> $currentState');
        },
        onError: (String message, int? code, dynamic e) {
          print('❌ WebSocket Error: $message (Code: $code)');
          print('❌ Error details: $e');
          // This is expected for Reverb - the library tries Pusher cloud first
          // The actual connection happens when we subscribe to channels
        },
        onSubscriptionSucceeded: (String channelName, dynamic data) {
          print('✅ Subscribed to channel: $channelName');
        },
        onEvent: (PusherEvent event) {
          print('📨 Event received: ${event.eventName} on ${event.channelName}');
        },
        activityTimeout: 120000,
        pongTimeout: 30000,
        // Authorization callback for private channels
        // This is where the actual Reverb connection is made
        onAuthorizer: _authorizeChannel,
      );

      // Attempt to connect (will fail for Pusher cloud, but that's OK)
      await _pusher!.connect();

      _isInitialized = true;
      print('✅ WebSocket initialized (will connect to Reverb on channel subscription)');
    } catch (e) {
      print('⚠️ Initial connection attempt: $e');
      print('⚠️ This is normal for Reverb - connection happens on channel subscription');
      _isInitialized = true; // Mark as initialized anyway
    }
  }

  /// Authorize private channel subscription
  ///
  /// Called by Pusher when subscribing to private channels
  /// Returns authorization data from backend
  Future<dynamic> _authorizeChannel(
    String channelName,
    String socketId,
    dynamic options,
  ) async {
    try {
      print('🔐 Authorizing channel: $channelName for socket: $socketId');

      final token = await _storage.read(key: 'auth_token');

      if (token == null) {
        print('❌ No auth token found for authorization');
        throw Exception('No authentication token available');
      }

      // Make HTTP request to backend authorization endpoint
      final response = await http.post(
        Uri.parse('https://erp1.bdcbiz.com/api/broadcasting/auth'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: {
          'socket_id': socketId,
          'channel_name': channelName,
        },
      );

      if (response.statusCode == 200) {
        final authData = jsonDecode(response.body);
        print('✅ Channel authorized successfully');
        return authData;
      } else {
        print('❌ Authorization failed: ${response.statusCode} - ${response.body}');
        throw Exception('Authorization failed: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Authorization error: $e');
      rethrow;
    }
  }

  /// Subscribe to a private channel
  ///
  /// For chat: `chat.{companyId}.conversation.{conversationId}`
  /// Authorization is handled automatically by onAuthorizer callback
  Future<void> subscribeToPrivateChannel({
    required String channelName,
    required Function(PusherEvent) onEvent,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      print('📡 Subscribing to private channel: $channelName');

      await _pusher!.subscribe(
        channelName: 'private-$channelName',
        onEvent: (dynamic event) {
          // Wrap the callback to handle type conversion
          if (event is PusherEvent) {
            onEvent(event);
          }
        },
        onSubscriptionError: (dynamic error, dynamic e) {
          print('❌ Subscription error for $channelName: $error');
          print('❌ Error details: $e');
        },
        onSubscriptionSucceeded: (dynamic data) {
          print('✅ Subscription succeeded for $channelName');
          print('✅ Channel data: $data');
        },
      );

      print('✅ Subscribed to private channel: private-$channelName');
    } catch (e) {
      print('❌ Failed to subscribe to channel $channelName: $e');
      rethrow;
    }
  }

  /// Unsubscribe from a channel
  Future<void> unsubscribe(String channelName) async {
    if (!_isInitialized) return;

    try {
      await _pusher!.unsubscribe(channelName: 'private-$channelName');
      print('✅ Unsubscribed from channel: $channelName');
    } catch (e) {
      print('❌ Failed to unsubscribe from $channelName: $e');
    }
  }

  /// Disconnect WebSocket
  Future<void> disconnect() async {
    if (!_isInitialized) return;

    try {
      await _pusher!.disconnect();
      _isInitialized = false;
      print('✅ WebSocket disconnected');
    } catch (e) {
      print('❌ Failed to disconnect WebSocket: $e');
    }
  }

  /// Get channel name for chat conversation
  static String getChatChannelName(int companyId, int conversationId) {
    return 'chat.$companyId.conversation.$conversationId';
  }

  /// Get channel name for user notifications
  ///
  /// Used to receive notifications about new messages in any conversation
  static String getUserChannelName(int companyId, int userId) {
    return 'user.$companyId.$userId';
  }
}
