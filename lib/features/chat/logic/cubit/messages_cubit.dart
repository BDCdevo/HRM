import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repo/chat_repository.dart';
import '../../data/models/message_model.dart';
import 'messages_state.dart';

/// Messages Cubit
///
/// Manages messages state for a specific conversation
class MessagesCubit extends Cubit<MessagesState> {
  final ChatRepository _repository;
  List<MessageModel> _currentMessages = [];

  MessagesCubit(this._repository) : super(const MessagesInitial());

  /// Fetch Messages
  ///
  /// Loads all messages for a specific conversation
  Future<void> fetchMessages({
    required int conversationId,
    required int companyId,
  }) async {
    try {
      if (isClosed) return;

      emit(const MessagesLoading());

      final messages = await _repository.getMessages(
        conversationId: conversationId,
        companyId: companyId,
      );

      if (isClosed) return;

      _currentMessages = messages;
      emit(MessagesLoaded(messages));
    } catch (e) {
      print('❌ MessagesCubit - Fetch Messages Error: $e');

      if (!isClosed) {
        emit(MessagesError(e.toString()));
      }
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

      print('📊 MessagesCubit.refreshMessages - Received ${messages.length} messages');
      if (messages.isNotEmpty) {
        print('📊 MessagesCubit.refreshMessages - IDs: ${messages.map((m) => m.id).toList()}');
      }

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
      );

      // Check if cubit is still open before updating state
      if (isClosed) return;

      // Add new message to the list
      final updatedMessages = [..._currentMessages, sentMessage];
      _currentMessages = updatedMessages;

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
  /// Useful for instant UI feedback
  void addOptimisticMessage(MessageModel message) {
    if (isClosed) return;

    final updatedMessages = [..._currentMessages, message];
    _currentMessages = updatedMessages;
    emit(MessagesLoaded(updatedMessages));
  }

  /// Reset to initial state
  void reset() {
    if (isClosed) return;

    _currentMessages = [];
    emit(const MessagesInitial());
  }

  /// Get current messages list
  List<MessageModel> get currentMessages => _currentMessages;
}
