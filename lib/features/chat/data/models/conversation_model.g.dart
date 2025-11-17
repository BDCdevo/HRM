// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConversationModel _$ConversationModelFromJson(Map<String, dynamic> json) =>
    ConversationModel(
      id: (json['id'] as num).toInt(),
      type: json['type'] as String? ?? 'private',
      participantId: (json['participant_id'] as num).toInt(),
      participantName: json['participant_name'] as String,
      participantAvatar: json['participant_avatar'] as String?,
      participantDepartment: json['participant_department'] as String?,
      lastMessage: json['last_message'] == null
          ? null
          : MessageModel.fromJson(json['last_message'] as Map<String, dynamic>),
      unreadCount: (json['unread_count'] as num?)?.toInt() ?? 0,
      updatedAt: json['updated_at'] as String,
      isOnline: json['is_online'] as bool? ?? false,
      participantsCount: (json['participants_count'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ConversationModelToJson(ConversationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'participant_id': instance.participantId,
      'participant_name': instance.participantName,
      'participant_avatar': instance.participantAvatar,
      'participant_department': instance.participantDepartment,
      'last_message': instance.lastMessage,
      'unread_count': instance.unreadCount,
      'updated_at': instance.updatedAt,
      'is_online': instance.isOnline,
      'participants_count': instance.participantsCount,
    };
