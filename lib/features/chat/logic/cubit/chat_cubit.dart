import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repo/chat_repository.dart';
import 'chat_state.dart';

/// Chat Cubit
///
/// Manages chat/conversations list state
class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _repository;

  ChatCubit(this._repository) : super(const ChatInitial());

  /// Fetch Conversations
  ///
  /// Loads all conversations for the current user in a specific company
  ///
  /// Important: Pass currentUserId to extract participant info correctly
  Future<void> fetchConversations({
    required int companyId,
    required int currentUserId,
  }) async {
    try {
      emit(const ChatLoading());

      final conversations = await _repository.getConversations(
        companyId: companyId,
        currentUserId: currentUserId,
      );

      emit(ChatLoaded(conversations));
    } catch (e) {
      print('❌ ChatCubit - Fetch Conversations Error: $e');
      emit(ChatError(e.toString()));
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

      emit(ChatLoaded(conversations));
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
  Future<void> createConversation({
    required int companyId,
    required List<int> userIds,
    String? type,
    String? name,
  }) async {
    try {
      emit(const ConversationCreating());

      final conversationId = await _repository.createConversation(
        companyId: companyId,
        userIds: userIds,
        type: type,
        name: name,
      );

      emit(ConversationCreated(conversationId));

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
}
