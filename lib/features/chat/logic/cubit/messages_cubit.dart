import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repo/chat_repository.dart';
import '../../data/models/message_model.dart';
import 'messages_state.dart';

/// Messages Cubit
///
/// Manages messages state for a specific conversation
/// Uses in-memory cache to show messages instantly on re-entry
class MessagesCubit extends Cubit<MessagesState> {
  final ChatRepository _repository;
  List<MessageModel> _currentMessages = [];

  /// Static cache for messages per conversation
  /// Key: conversationId, Value: cached messages
  static final Map<int, List<MessageModel>> _messagesCache = {};

  /// Cache expiry time (5 minutes)
  static final Map<int, DateTime> _cacheTimestamps = {};
  static const _cacheValidDuration = Duration(minutes: 5);

  MessagesCubit(this._repository) : super(const MessagesInitial());

  /// Fetch Messages
  ///
  /// Loads all messages for a specific conversation
  /// Shows cached data immediately, then refreshes in background
  Future<void> fetchMessages({
    required int conversationId,
    required int companyId,
  }) async {
    try {
      if (isClosed) return;

      // Check if we have valid cached messages
      final cachedMessages = _messagesCache[conversationId];
      final cacheTime = _cacheTimestamps[conversationId];
      final isCacheValid = cacheTime != null &&
          DateTime.now().difference(cacheTime) < _cacheValidDuration;

      if (cachedMessages != null && cachedMessages.isNotEmpty) {
        // Show cached messages immediately (no loading!)
        _currentMessages = cachedMessages;
        emit(MessagesLoaded(cachedMessages));

        // If cache is still valid, just refresh silently in background
        if (isCacheValid) {
          _refreshInBackground(conversationId, companyId);
          return;
        }
      } else {
        // No cache - show loading
        emit(const MessagesLoading());
      }

      // Fetch fresh messages
      final messages = await _repository.getMessages(
        conversationId: conversationId,
        companyId: companyId,
      );

      if (isClosed) return;

      // Update cache
      _messagesCache[conversationId] = messages;
      _cacheTimestamps[conversationId] = DateTime.now();

      _currentMessages = messages;
      emit(MessagesLoaded(messages));
    } catch (e) {
      print('❌ MessagesCubit - Fetch Messages Error: $e');

      if (!isClosed) {
        // If we have cached data, show it instead of error
        final cachedMessages = _messagesCache[conversationId];
        if (cachedMessages != null && cachedMessages.isNotEmpty) {
          _currentMessages = cachedMessages;
          emit(MessagesLoaded(cachedMessages));
        } else {
          emit(MessagesError(e.toString()));
        }
      }
    }
  }

  /// Refresh messages in background without showing loading
  Future<void> _refreshInBackground(int conversationId, int companyId) async {
    try {
      final messages = await _repository.getMessages(
        conversationId: conversationId,
        companyId: companyId,
      );

      if (isClosed) return;

      // Update cache
      _messagesCache[conversationId] = messages;
      _cacheTimestamps[conversationId] = DateTime.now();

      _currentMessages = messages;
      emit(MessagesLoaded(messages));
    } catch (e) {
      // Silent fail - keep showing cached data
      print('⚠️ Background refresh failed: $e');
    }
  }

  /// Refresh Messages
  ///
  /// Refreshes messages list (used with pull-to-refresh or polling)
  /// Shows existing messages while refreshing
  Future<void> refreshMessages({
    required int conversationId,
    required int companyId,
  }) async {
    try {
      // Keep showing current messages while refreshing
      if (!isClosed && state is MessagesLoaded) {
        final currentMessages = (state as MessagesLoaded).messages;
        emit(MessagesRefreshing(currentMessages));
      }

      final messages = await _repository.getMessages(
        conversationId: conversationId,
        companyId: companyId,
      );

      // Update cache
      _messagesCache[conversationId] = messages;
      _cacheTimestamps[conversationId] = DateTime.now();

      _currentMessages = messages;

      // Check if cubit is still open before emitting
      if (!isClosed) {
        emit(MessagesLoaded(messages));
      }
    } catch (e) {
      print('❌ MessagesCubit - Refresh Messages Error: $e');

      // Check if cubit is still open before emitting
      if (isClosed) return;

      // If refresh fails, keep showing old messages
      if (state is MessagesRefreshing) {
        final currentMessages = (state as MessagesRefreshing).messages;
        emit(MessagesLoaded(currentMessages));
      } else {
        emit(MessagesError(e.toString(), messages: _currentMessages));
      }
    }
  }

  /// Send Message
  ///
  /// Sends a text message or message with attachment
  Future<void> sendMessage({
    required int conversationId,
    required int companyId,
    String? message,
    File? attachment,
    String? attachmentType,
    int? replyToMessageId,
  }) async {
    try {
      // Check if cubit is still open
      if (isClosed) return;

      // Show sending state with current messages
      emit(MessageSending(_currentMessages));

      final sentMessage = await _repository.sendMessage(
        conversationId: conversationId,
        companyId: companyId,
        message: message,
        attachment: attachment,
        attachmentType: attachmentType,
        replyToMessageId: replyToMessageId,
      );

      // Check if cubit is still open before updating state
      if (isClosed) return;

      // Add new message to the list
      final updatedMessages = [..._currentMessages, sentMessage];
      _currentMessages = updatedMessages;

      // Update cache immediately
      _messagesCache[conversationId] = updatedMessages;
      _cacheTimestamps[conversationId] = DateTime.now();

      emit(MessageSent(updatedMessages));

      // Immediately refresh to get all messages from server
      // This ensures both sender and receiver see all messages
      await refreshMessages(
        conversationId: conversationId,
        companyId: companyId,
      );
    } catch (e) {
      print('❌ MessagesCubit - Send Message Error: $e');

      // Check if cubit is still open before emitting error
      if (!isClosed) {
        emit(MessageSendError(e.toString(), _currentMessages));
      }
    }
  }

  /// Optimistic Message Add
  ///
  /// Adds a message optimistically (before API confirmation)
  /// Useful for instant UI feedback and WebSocket messages
  void addOptimisticMessage(MessageModel message, {int? conversationId}) {
    if (isClosed) return;

    // Avoid duplicate messages
    if (_currentMessages.any((m) => m.id == message.id)) {
      return;
    }

    final updatedMessages = [..._currentMessages, message];
    _currentMessages = updatedMessages;

    // Update cache if conversationId provided
    if (conversationId != null) {
      _messagesCache[conversationId] = updatedMessages;
      _cacheTimestamps[conversationId] = DateTime.now();
    }

    emit(MessagesLoaded(updatedMessages));
  }

  /// Reset to initial state
  void reset() {
    if (isClosed) return;

    _currentMessages = [];
    emit(const MessagesInitial());
  }

  /// Clear cache for a specific conversation
  static void clearCache(int conversationId) {
    _messagesCache.remove(conversationId);
    _cacheTimestamps.remove(conversationId);
  }

  /// Clear all cached messages
  static void clearAllCache() {
    _messagesCache.clear();
    _cacheTimestamps.clear();
  }

  /// Get current messages list
  List<MessageModel> get currentMessages => _currentMessages;

  /// Remove message by ID (used for real-time deletion from WebSocket)
  void removeMessageById(int messageId) {
    if (isClosed) return;

    final updatedMessages = _currentMessages.where((m) => m.id != messageId).toList();

    if (updatedMessages.length != _currentMessages.length) {
      _currentMessages = updatedMessages;
      emit(MessagesLoaded(updatedMessages));
      print('🗑️ Message $messageId removed from state');
    }
  }

  /// Delete Message
  ///
  /// Deletes a message and updates the list
  Future<void> deleteMessage({
    required int conversationId,
    required int companyId,
    required int messageId,
  }) async {
    try {
      if (isClosed) return;

      print('🗑️ Attempting to delete message $messageId');

      // Optimistically remove from UI
      final updatedMessages = _currentMessages.where((m) => m.id != messageId).toList();
      _currentMessages = updatedMessages;
      emit(MessagesLoaded(updatedMessages));

      print('🗑️ Optimistic delete done, calling API...');

      // Delete from server
      final success = await _repository.deleteMessage(
        conversationId: conversationId,
        messageId: messageId,
        companyId: companyId,
      );

      print('🗑️ API response: $success');

      // Update cache
      _messagesCache[conversationId] = updatedMessages;
      _cacheTimestamps[conversationId] = DateTime.now();

      print('✅ Message $messageId deleted successfully');
    } catch (e, stackTrace) {
      print('❌ MessagesCubit - Delete Message Error: $e');
      print('❌ Stack trace: $stackTrace');

      // Don't revert - keep the message deleted from UI
      // The server might have deleted it successfully
      // Just log the error
    }
  }
}
