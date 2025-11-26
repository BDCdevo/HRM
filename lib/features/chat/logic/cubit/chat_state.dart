import 'package:equatable/equatable.dart';
import '../../data/models/conversation_model.dart';

/// Chat State
///
/// Represents different states of chat/conversations feature
abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ChatInitial extends ChatState {
  const ChatInitial();
}

/// Loading conversations
class ChatLoading extends ChatState {
  const ChatLoading();
}

/// Conversations loaded successfully
class ChatLoaded extends ChatState {
  final List<ConversationModel> conversations;

  const ChatLoaded(this.conversations);

  /// Total unread messages count across all conversations
  int get totalUnreadCount =>
      conversations.fold(0, (sum, conv) => sum + conv.unreadCount);

  @override
  List<Object?> get props => [conversations];
}

/// Error loading conversations
class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Creating new conversation
class ConversationCreating extends ChatState {
  const ConversationCreating();
}

/// Conversation created successfully
class ConversationCreated extends ChatState {
  final int conversationId;
  final String? participantName; // Name of the other participant

  const ConversationCreated(this.conversationId, {this.participantName});

  @override
  List<Object?> get props => [conversationId, participantName];
}

/// Error creating conversation
class ConversationCreateError extends ChatState {
  final String message;

  const ConversationCreateError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Refreshing conversations
class ChatRefreshing extends ChatState {
  final List<ConversationModel> conversations;

  const ChatRefreshing(this.conversations);

  @override
  List<Object?> get props => [conversations];
}
