import 'package:json_annotation/json_annotation.dart';
import 'message_model.dart';

part 'conversation_model.g.dart';

@JsonSerializable()
class ConversationModel {
  final int id;

  @JsonKey(name: 'participant_id')
  final int participantId;

  @JsonKey(name: 'participant_name')
  final String participantName;

  @JsonKey(name: 'participant_avatar')
  final String? participantAvatar;

  @JsonKey(name: 'participant_department')
  final String? participantDepartment;

  @JsonKey(name: 'last_message')
  final MessageModel? lastMessage;

  @JsonKey(name: 'unread_count')
  final int unreadCount;

  @JsonKey(name: 'updated_at')
  final String updatedAt;

  const ConversationModel({
    required this.id,
    required this.participantId,
    required this.participantName,
    this.participantAvatar,
    this.participantDepartment,
    this.lastMessage,
    this.unreadCount = 0,
    required this.updatedAt,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) =>
      _$ConversationModelFromJson(json);

  Map<String, dynamic> toJson() => _$ConversationModelToJson(this);

  /// Check if conversation has unread messages
  bool get hasUnreadMessages => unreadCount > 0;

  /// Format last message time
  String get formattedTime {
    if (lastMessage == null) return '';

    try {
      final dateTime = DateTime.parse(lastMessage!.createdAt);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

      if (messageDate == today) {
        // Show time for today's messages
        final hour = dateTime.hour;
        final minute = dateTime.minute.toString().padLeft(2, '0');
        final period = hour >= 12 ? 'PM' : 'AM';
        final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        return '$displayHour:$minute $period';
      } else if (messageDate == today.subtract(const Duration(days: 1))) {
        return 'Yesterday';
      } else if (dateTime.isAfter(today.subtract(const Duration(days: 7)))) {
        // Show day name for messages within last week
        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        return days[dateTime.weekday - 1];
      } else {
        // Show date for older messages
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      }
    } catch (e) {
      return '';
    }
  }

  /// Get last message preview
  String get lastMessagePreview {
    if (lastMessage == null) return 'No messages yet';

    switch (lastMessage!.messageType) {
      case 'image':
        return '📷 Photo';
      case 'file':
        return '📎 File';
      case 'voice':
        return '🎤 Voice message';
      default:
        return lastMessage!.message;
    }
  }
}
