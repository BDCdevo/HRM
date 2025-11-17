import 'package:json_annotation/json_annotation.dart';
import 'message_model.dart';

part 'conversation_model.g.dart';

@JsonSerializable()
class ConversationModel {
  final int id;

  /// Type of conversation: 'private' or 'group'
  final String type;

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

  @JsonKey(name: 'is_online')
  final bool isOnline;

  /// Number of participants (for groups)
  @JsonKey(name: 'participants_count')
  final int? participantsCount;

  const ConversationModel({
    required this.id,
    this.type = 'private',
    required this.participantId,
    required this.participantName,
    this.participantAvatar,
    this.participantDepartment,
    this.lastMessage,
    this.unreadCount = 0,
    required this.updatedAt,
    this.isOnline = false,
    this.participantsCount,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) =>
      _$ConversationModelFromJson(json);

  /// Factory for API response
  /// API returns: {id, type, name, avatar, last_message, unread_count, is_online, last_seen_at, participants}
  ///
  /// Important: Pass currentUserId to extract the OTHER participant's info correctly
  factory ConversationModel.fromApiJson(
    Map<String, dynamic> json, {
    required int currentUserId,
  }) {
    final String conversationType = json['type'] as String? ?? 'private';

    // Extract participant info based on conversation type
    int participantId = 0;
    String participantName = 'Unknown';
    String? participantAvatar;
    String? participantDepartment;
    int? participantsCount;

    if (conversationType == 'group') {
      // For groups: use conversation name and count participants
      participantName = json['name'] as String? ?? 'Group Chat';
      participantAvatar = json['avatar'] as String?;

      // Count participants
      if (json['participants'] != null && json['participants'] is List) {
        participantsCount = (json['participants'] as List).length;
      }
    } else {
      // For private chats: find the OTHER participant
      if (json['participants'] != null && json['participants'] is List) {
        final participants = json['participants'] as List;

        // Find the OTHER participant (not current user)
        final otherParticipant = participants.firstWhere(
          (p) => p['id'] != currentUserId,
          orElse: () => null,
        );

        if (otherParticipant != null) {
          participantId = otherParticipant['id'] as int;
          participantName = otherParticipant['name'] ??
                           otherParticipant['email'] ??
                           'Unknown';
          participantAvatar = otherParticipant['avatar'] as String?;
          participantDepartment = otherParticipant['department'] as String?;
        }
      }

      // Fallback to conversation name if no participant found
      // (Backend returns participant name as conversation name for private chats)
      if (participantId == 0) {
        participantName = json['name'] as String? ?? 'Unknown';
        participantAvatar = json['avatar'] as String?;
      }
    }

    return ConversationModel(
      id: json['id'] as int,
      type: conversationType,
      participantId: participantId,
      participantName: participantName,
      participantAvatar: participantAvatar,
      participantDepartment: participantDepartment,
      lastMessage: json['last_message'] != null && json['last_message'] is String
          ? MessageModel(
              id: 0,
              conversationId: json['id'] as int,
              senderId: 0,
              senderName: '',
              message: json['last_message'] as String,
              messageType: 'text',
              isRead: true,
              isMine: false,
              createdAt: json['last_message_at'] as String? ?? DateTime.now().toIso8601String(),
              updatedAt: json['last_message_at'] as String? ?? DateTime.now().toIso8601String(),
            )
          : null,
      unreadCount: json['unread_count'] as int? ?? 0,
      updatedAt: json['last_message_at'] as String? ?? DateTime.now().toIso8601String(),
      isOnline: conversationType == 'private' ? (json['is_online'] as bool? ?? false) : false,
      participantsCount: participantsCount,
    );
  }

  Map<String, dynamic> toJson() => _$ConversationModelToJson(this);

  /// Check if conversation has unread messages
  bool get hasUnreadMessages => unreadCount > 0;

  /// Check if conversation is a group
  bool get isGroup => type == 'group';

  /// Check if conversation is private
  bool get isPrivate => type == 'private';

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
