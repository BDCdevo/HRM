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

  Map<String, dynamic> toJson() => _$MessageModelToJson(this);

  /// Check if this message was sent by current user
  bool isSentByMe(int currentUserId) => senderId == currentUserId;

  /// Format created at time (e.g., "10:30 AM")
  String get formattedTime {
    try {
      final dateTime = DateTime.parse(createdAt);
      final hour = dateTime.hour;
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$displayHour:$minute $period';
    } catch (e) {
      return '';
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
