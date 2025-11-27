import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/conversation_model.dart';
import '../../data/models/message_model.dart';
import '../../data/repo/chat_repository.dart';
import 'chat_state.dart';
import 'messages_cubit.dart';

/// Chat Cubit
///
/// Manages chat/conversations list state
class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _repository;

  /// Track locally deleted conversation IDs to filter them out on refresh
  /// Static so it persists across cubit instances
  static Set<int> _deletedConversationIds = <int>{};

  ChatCubit(this._repository) : super(const ChatInitial());

  /// Fetch Conversations
  ///
  /// Loads all conversations for the current user in a specific company
  ///
  /// Important: Pass currentUserId to extract participant info correctly
  /// Set [silent] to true for background refresh (no loading indicator)
  Future<void> fetchConversations({
    required int companyId,
    required int currentUserId,
    bool silent = false,
  }) async {
    try {
      // Only show loading on first load, not on silent refresh
      if (!silent && state is! ChatLoaded) {
        emit(const ChatLoading());
      }

      final conversations = await _repository.getConversations(
        companyId: companyId,
        currentUserId: currentUserId,
      );

      // Filter out locally deleted conversations
      print('🔍 [fetchConversations] Filtering. Deleted IDs: $_deletedConversationIds');
      print('🔍 [fetchConversations] Before filter: ${conversations.length} conversations');
      final filteredConversations = _deletedConversationIds.isEmpty
          ? conversations
          : conversations.where((c) => !_deletedConversationIds.contains(c.id)).toList();
      print('🔍 [fetchConversations] After filter: ${filteredConversations.length} conversations');

      emit(ChatLoaded(filteredConversations));
    } catch (e) {
      print('❌ ChatCubit - Fetch Conversations Error: $e');
      // On silent refresh, don't show error - keep existing data
      if (!silent || state is! ChatLoaded) {
        emit(ChatError(e.toString()));
      }
    }
  }

  /// Refresh Conversations
  ///
  /// Refreshes conversations list (used with pull-to-refresh)
  /// Shows existing conversations while refreshing
  ///
  /// Important: Pass currentUserId to extract participant info correctly
  Future<void> refreshConversations({
    required int companyId,
    required int currentUserId,
  }) async {
    try {
      // Keep showing current conversations while refreshing
      if (state is ChatLoaded) {
        final currentConversations = (state as ChatLoaded).conversations;
        emit(ChatRefreshing(currentConversations));
      }

      final conversations = await _repository.getConversations(
        companyId: companyId,
        currentUserId: currentUserId,
      );

      // Filter out locally deleted conversations
      print('🔍 [refreshConversations] Filtering. Deleted IDs: $_deletedConversationIds');
      print('🔍 [refreshConversations] Before filter: ${conversations.length} conversations');
      final filteredConversations = _deletedConversationIds.isEmpty
          ? conversations
          : conversations.where((c) => !_deletedConversationIds.contains(c.id)).toList();
      print('🔍 [refreshConversations] After filter: ${filteredConversations.length} conversations');

      emit(ChatLoaded(filteredConversations));
    } catch (e) {
      print('❌ ChatCubit - Refresh Conversations Error: $e');

      // If refresh fails, keep showing old conversations with error message
      if (state is ChatRefreshing) {
        final currentConversations = (state as ChatRefreshing).conversations;
        emit(ChatLoaded(currentConversations));
        // You can show a snackbar here via BlocListener
      } else {
        emit(ChatError(e.toString()));
      }
    }
  }

  /// Create Conversation
  ///
  /// Creates a new conversation with selected users
  /// Returns existing conversation if it already exists (for private chats)
  Future<void> createConversation({
    required int companyId,
    required List<int> userIds,
    String? type,
    String? name,
    String? participantName, // Name of the other participant (for UI)
  }) async {
    try {
      emit(const ConversationCreating());

      final conversationId = await _repository.createConversation(
        companyId: companyId,
        userIds: userIds,
        type: type,
        name: name,
      );

      emit(ConversationCreated(conversationId, participantName: participantName));

      // Optionally refresh conversations after creating new one
      // Commented out to avoid automatic navigation issues
      // await fetchConversations(companyId);
    } catch (e) {
      print('❌ ChatCubit - Create Conversation Error: $e');
      emit(ConversationCreateError(e.toString()));
    }
  }

  /// Reset to initial state
  void reset() {
    emit(const ChatInitial());
  }

  /// Increment unread count for a conversation
  ///
  /// Called when a new message is received via WebSocket
  void incrementUnreadCount(int conversationId) {
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;
      final updatedConversations = currentState.conversations.map((conv) {
        if (conv.id == conversationId) {
          return conv.copyWith(unreadCount: conv.unreadCount + 1);
        }
        return conv;
      }).toList();

      emit(ChatLoaded(updatedConversations));
    }
  }

  /// Handle new message notification
  ///
  /// Updates conversation locally (moves to top, updates last message, increments unread)
  /// Then fetches from API in background to ensure data consistency
  void handleNewMessage({
    required int conversationId,
    required String senderName,
    required String messagePreview,
    required int companyId,
    required int currentUserId,
  }) {
    // Ignore messages for deleted conversations
    if (_deletedConversationIds.contains(conversationId)) {
      print('⚠️ Ignoring message for deleted conversation $conversationId');
      return;
    }

    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;
      final conversations = List<ConversationModel>.from(currentState.conversations);

      // Find the conversation
      final index = conversations.indexWhere((c) => c.id == conversationId);

      if (index != -1) {
        // Update the conversation
        final conversation = conversations[index];
        final updatedConversation = conversation.copyWith(
          unreadCount: conversation.unreadCount + 1,
          updatedAt: DateTime.now().toIso8601String(),
          lastMessage: MessageModel(
            id: 0,
            conversationId: conversationId,
            senderId: 0,
            senderName: senderName,
            message: messagePreview,
            messageType: 'text',
            isRead: false,
            isMine: false,
            createdAt: DateTime.now().toIso8601String(),
            updatedAt: DateTime.now().toIso8601String(),
          ),
        );

        // Remove from current position and add to top
        conversations.removeAt(index);
        conversations.insert(0, updatedConversation);

        // Emit updated state immediately
        emit(ChatLoaded(conversations));

        print('✅ Conversation $conversationId moved to top with new message');
      }

      // Also fetch from API in background to ensure consistency
      fetchConversations(
        companyId: companyId,
        currentUserId: currentUserId,
        silent: true,
      );
    }
  }

  /// Clear unread count for a conversation
  ///
  /// Called when user opens a conversation
  void clearUnreadCount(int conversationId) {
    if (state is ChatLoaded) {
      final currentState = state as ChatLoaded;
      final updatedConversations = currentState.conversations.map((conv) {
        if (conv.id == conversationId) {
          return conv.copyWith(unreadCount: 0);
        }
        return conv;
      }).toList();

      emit(ChatLoaded(updatedConversations));
    }
  }

  /// Get total unread count
  int get totalUnreadCount {
    if (state is ChatLoaded) {
      return (state as ChatLoaded).totalUnreadCount;
    }
    return 0;
  }

  /// Delete Conversation
  ///
  /// Deletes/leaves a conversation
  Future<void> deleteConversation({
    required int conversationId,
    required int companyId,
  }) async {
    try {
      // Add to deleted set to prevent it from coming back on refresh
      _deletedConversationIds.add(conversationId);
      print('🗑️ Added $conversationId to deleted set. Current deleted IDs: $_deletedConversationIds');

      // Optimistically remove from UI
      if (state is ChatLoaded) {
        final currentState = state as ChatLoaded;
        final updatedConversations = currentState.conversations
            .where((c) => c.id != conversationId)
            .toList();
        emit(ChatLoaded(updatedConversations));
      }

      // Delete from server
      await _repository.deleteConversation(
        conversationId: conversationId,
        companyId: companyId,
      );

      // Clear messages cache for this conversation
      MessagesCubit.clearCache(conversationId);

      print('✅ Conversation $conversationId deleted successfully');
    } catch (e) {
      print('❌ ChatCubit - Delete Conversation Error: $e');
      // On error, remove from deleted set so it can come back
      _deletedConversationIds.remove(conversationId);
    }
  }

  /// Clear deleted conversations cache (call when user logs out)
  static void clearDeletedCache() {
    _deletedConversationIds.clear();
  }
}
