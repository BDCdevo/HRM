// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageModel _$MessageModelFromJson(Map<String, dynamic> json) => MessageModel(
  id: (json['id'] as num).toInt(),
  conversationId: (json['conversation_id'] as num).toInt(),
  senderId: (json['sender_id'] as num).toInt(),
  senderName: json['sender_name'] as String,
  senderAvatar: json['sender_avatar'] as String?,
  message: json['message'] as String,
  messageType: json['message_type'] as String? ?? 'text',
  attachmentUrl: json['attachment_url'] as String?,
  attachmentName: json['attachment_name'] as String?,
  attachmentSize: (json['attachment_size'] as num?)?.toInt(),
  isRead: json['is_read'] as bool? ?? false,
  isMine: json['is_mine'] as bool,
  createdAt: json['created_at'] as String,
  updatedAt: json['updated_at'] as String,
);

Map<String, dynamic> _$MessageModelToJson(MessageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'conversation_id': instance.conversationId,
      'sender_id': instance.senderId,
      'sender_name': instance.senderName,
      'sender_avatar': instance.senderAvatar,
      'message': instance.message,
      'message_type': instance.messageType,
      'attachment_url': instance.attachmentUrl,
      'attachment_name': instance.attachmentName,
      'attachment_size': instance.attachmentSize,
      'is_read': instance.isRead,
      'is_mine': instance.isMine,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
