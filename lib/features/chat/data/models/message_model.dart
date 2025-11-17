import 'package:json_annotation/json_annotation.dart';

part 'message_model.g.dart';

@JsonSerializable()
class MessageModel {
  final int id;

  @JsonKey(name: 'conversation_id')
  final int conversationId;

  @JsonKey(name: 'sender_id')
  final int senderId;

  @JsonKey(name: 'sender_name')
  final String senderName;

  @JsonKey(name: 'sender_avatar')
  final String? senderAvatar;

  final String message;

  @JsonKey(name: 'message_type')
  final String messageType; // text, image, file, voice

  @JsonKey(name: 'is_read')
  final bool isRead;

  @JsonKey(name: 'created_at')
  final String createdAt;

  @JsonKey(name: 'updated_at')
  final String updatedAt;

  const MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.message,
    this.messageType = 'text',
    this.isRead = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);

  /// Factory for API response
  /// API returns: {id, body, user_id, user_name, user_avatar, created_at, is_mine, attachment_type, attachment_name, attachment_url, read_at}
  factory MessageModel.fromApiJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as int,
      conversationId: 0, // Not provided, set to 0
      senderId: json['user_id'] as int,
      senderName: json['user_name'] as String? ?? 'Unknown',
      senderAvatar: json['user_avatar'] as String?,
      message: json['body'] as String? ?? '',
      messageType: json['attachment_type'] as String? ?? 'text',
      isRead: json['read_at'] != null,
      createdAt: json['created_at'] as String? ?? DateTime.now().toIso8601String(),
      updatedAt: json['created_at'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() => _$MessageModelToJson(this);

  /// Check if this message was sent by current user
  bool isSentByMe(int currentUserId) => senderId == currentUserId;

  /// Format created at time (e.g., "10:30 AM")
  String get formattedTime {
    try {
      // Parse datetime
      final dateTime = DateTime.parse(createdAt);

      // Convert to 12-hour format
      final hour = dateTime.hour;
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

      return '$displayHour:$minute $period';
    } catch (e) {
      // Fallback: return createdAt as is
      return createdAt;
    }
  }

  /// Format created at date (e.g., "Yesterday", "12/11/2025")
  String get formattedDate {
    try {
      final dateTime = DateTime.parse(createdAt);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

      if (messageDate == today) {
        return 'Today';
      } else if (messageDate == today.subtract(const Duration(days: 1))) {
        return 'Yesterday';
      } else {
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      }
    } catch (e) {
      return '';
    }
  }
}
