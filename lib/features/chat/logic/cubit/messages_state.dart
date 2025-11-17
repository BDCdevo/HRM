import 'package:equatable/equatable.dart';
import '../../data/models/message_model.dart';

/// Messages State
///
/// Represents different states of messages in a conversation
abstract class MessagesState extends Equatable {
  const MessagesState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class MessagesInitial extends MessagesState {
  const MessagesInitial();
}

/// Loading messages
class MessagesLoading extends MessagesState {
  const MessagesLoading();
}

/// Messages loaded successfully
class MessagesLoaded extends MessagesState {
  final List<MessageModel> messages;

  const MessagesLoaded(this.messages);

  @override
  List<Object?> get props => [messages];
}

/// Error loading messages
class MessagesError extends MessagesState {
  final String message;
  final List<MessageModel>? messages; // Keep existing messages on error

  const MessagesError(this.message, {this.messages});

  @override
  List<Object?> get props => [message, messages];
}

/// Sending a message
class MessageSending extends MessagesState {
  final List<MessageModel> messages; // Current messages

  const MessageSending(this.messages);

  @override
  List<Object?> get props => [messages];
}

/// Message sent successfully
class MessageSent extends MessagesState {
  final List<MessageModel> messages; // Updated messages list

  const MessageSent(this.messages);

  @override
  List<Object?> get props => [messages];
}

/// Error sending message
class MessageSendError extends MessagesState {
  final String message;
  final List<MessageModel> messages; // Keep existing messages

  const MessageSendError(this.message, this.messages);

  @override
  List<Object?> get props => [message, messages];
}

/// Refreshing messages
class MessagesRefreshing extends MessagesState {
  final List<MessageModel> messages;

  const MessagesRefreshing(this.messages);

  @override
  List<Object?> get props => [messages];
}
