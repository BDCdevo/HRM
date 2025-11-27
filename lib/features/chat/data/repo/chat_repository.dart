import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/networking/dio_client.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

/// Chat Repository
///
/// Handles all chat-related API calls
/// Uses DioClient for HTTP requests
class ChatRepository {
  final DioClient _dioClient;

  ChatRepository({DioClient? dioClient})
      : _dioClient = dioClient ?? DioClient.getInstance();

  /// Get Conversations
  ///
  /// Fetches all conversations for the current user in a specific company
  /// Returns list of ConversationModel
  /// Throws DioException on failure
  ///
  /// Important: Pass currentUserId to extract participant info correctly
  Future<List<ConversationModel>> getConversations({
    required int companyId,
    required int currentUserId,
  }) async {
    try {
      final response = await _dioClient.get(
        ApiConfig.conversations,
        queryParameters: {'company_id': companyId},
      );

      print('✅ Get Conversations Response Status: ${response.statusCode}');
      print('📦 Get Conversations Response: ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> conversationsJson =
            response.data['conversations'] ?? [];

        return conversationsJson
            .map((json) => ConversationModel.fromApiJson(
                  json,
                  currentUserId: currentUserId,
                ))
            .toList();
      }

      throw Exception(response.data['message'] ?? 'Failed to get conversations');
    } on DioException catch (e) {
      print('❌ Get Conversations Error: ${e.message}');
      print('⚠️ Error Response: ${e.response?.data}');
      rethrow;
    }
  }

  /// Create Conversation
  ///
  /// Creates a new conversation (private or group)
  /// Returns conversation ID on success
  /// Throws DioException on failure
  Future<int> createConversation({
    required int companyId,
    required List<int> userIds,
    String? type, // 'private' or 'group'
    String? name, // Required for group conversations
  }) async {
    try {
      final response = await _dioClient.post(
        ApiConfig.createConversation,
        data: {
          'company_id': companyId,
          'user_ids': userIds,
          if (type != null) 'type': type,
          if (name != null) 'name': name,
        },
      );

      print('✅ Create Conversation Response Status: ${response.statusCode}');
      print('📦 Create Conversation Response: ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['conversation']['id'] as int;
      }

      throw Exception(
          response.data['message'] ?? 'Failed to create conversation');
    } on DioException catch (e) {
      print('❌ Create Conversation Error: ${e.message}');
      print('⚠️ Error Response: ${e.response?.data}');
      rethrow;
    }
  }

  /// Get Messages
  ///
  /// Fetches all messages for a specific conversation
  /// Returns list of MessageModel
  /// Throws DioException on failure
  Future<List<MessageModel>> getMessages({
    required int conversationId,
    required int companyId,
  }) async {
    try {
      final response = await _dioClient.get(
        ApiConfig.conversationMessages(conversationId),
        queryParameters: {'company_id': companyId},
      );

      print('✅ Get Messages Response Status: ${response.statusCode}');
      print('📦 Get Messages Response: ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> messagesJson = response.data['messages'] ?? [];

        print('📊 Total messages in response: ${messagesJson.length}');
        if (messagesJson.isNotEmpty) {
          print('📊 First message ID: ${messagesJson.first['id']}');
          print('📊 Last message ID: ${messagesJson.last['id']}');
        }

        final parsedMessages = messagesJson
            .map((json) => MessageModel.fromApiJson(json))
            .toList();

        print('📊 Parsed messages count: ${parsedMessages.length}');
        if (parsedMessages.isNotEmpty) {
          print('📊 Parsed first ID: ${parsedMessages.first.id}');
          print('📊 Parsed last ID: ${parsedMessages.last.id}');
        }

        return parsedMessages;
      }

      throw Exception(response.data['message'] ?? 'Failed to get messages');
    } on DioException catch (e) {
      print('❌ Get Messages Error: ${e.message}');
      print('⚠️ Error Response: ${e.response?.data}');
      rethrow;
    }
  }

  /// Send Message
  ///
  /// Sends a text message or message with attachment
  /// Returns sent MessageModel on success
  /// Throws DioException on failure
  Future<MessageModel> sendMessage({
    required int conversationId,
    required int companyId,
    String? message,
    File? attachment,
    String? attachmentType, // 'image', 'file', 'voice'
    int? replyToMessageId, // Optional: ID of message being replied to
  }) async {
    try {
      // Prepare form data for multipart request (if attachment exists)
      dynamic requestData;

      if (attachment != null) {
        // Multipart request for file upload
        final formData = FormData.fromMap({
          if (message != null && message.isNotEmpty) 'message': message,
          if (attachmentType != null) 'attachment_type': attachmentType,
          if (replyToMessageId != null) 'reply_to_message_id': replyToMessageId,
          'attachment': await MultipartFile.fromFile(
            attachment.path,
            filename: attachment.path.split('/').last,
          ),
        });
        requestData = formData;
      } else {
        // Simple JSON request for text-only message
        requestData = {
          if (message != null && message.isNotEmpty) 'message': message,
          if (replyToMessageId != null) 'reply_to_message_id': replyToMessageId,
        };
      }

      final response = await _dioClient.post(
        '${ApiConfig.sendMessage(conversationId)}?company_id=$companyId',
        data: requestData,
      );

      print('✅ Send Message Response Status: ${response.statusCode}');
      print('📦 Send Message Response: ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        return MessageModel.fromApiJson(response.data['message']);
      }

      throw Exception(response.data['message'] ?? 'Failed to send message');
    } on DioException catch (e) {
      print('❌ Send Message Error: ${e.message}');
      print('⚠️ Error Response: ${e.response?.data}');
      rethrow;
    }
  }

  /// Send Typing Indicator
  ///
  /// Notifies other participants that user is typing
  Future<void> sendTypingIndicator({
    required int conversationId,
    required int companyId,
    bool isTyping = true,
  }) async {
    try {
      await _dioClient.post(
        ApiConfig.sendTypingIndicator(conversationId),
        data: {
          'company_id': companyId,
          'is_typing': isTyping,
        },
      );
    } on DioException catch (e) {
      // Silently fail - typing indicator is not critical
      print('❌ Typing Indicator Error: ${e.message}');
    }
  }

  /// Delete Message
  ///
  /// Deletes a message (soft delete - marks as deleted)
  /// Only the sender can delete their own messages
  Future<bool> deleteMessage({
    required int conversationId,
    required int messageId,
    required int companyId,
  }) async {
    try {
      final response = await _dioClient.delete(
        '${ApiConfig.deleteMessage(conversationId, messageId)}?company_id=$companyId',
      );

      print('✅ Delete Message Response Status: ${response.statusCode}');
      print('📦 Delete Message Response: ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        return true;
      }

      throw Exception(response.data['message'] ?? 'Failed to delete message');
    } on DioException catch (e) {
      print('❌ Delete Message Error: ${e.message}');
      print('⚠️ Error Response: ${e.response?.data}');
      rethrow;
    }
  }

  /// Delete Conversation
  ///
  /// Deletes entire conversation (for current user only)
  Future<bool> deleteConversation({
    required int conversationId,
    required int companyId,
  }) async {
    try {
      print('🗑️ Deleting conversation: $conversationId, company: $companyId');

      final response = await _dioClient.delete(
        '/conversations/$conversationId?company_id=$companyId',
      );

      print('✅ Delete Conversation Response Status: ${response.statusCode}');
      print('✅ Delete Conversation Response Data: ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        print('✅ Conversation $conversationId deleted successfully from server');
        return true;
      }

      throw Exception(response.data['message'] ?? 'Failed to delete conversation');
    } on DioException catch (e) {
      print('❌ Delete Conversation Error: ${e.message}');
      print('❌ Delete Conversation Error Response: ${e.response?.data}');
      rethrow;
    }
  }

  /// Get Users
  ///
  /// Fetches all users in a specific company (for starting new conversations)
  /// Returns list of user maps with id, name, email
  /// Throws DioException on failure
  Future<List<Map<String, dynamic>>> getUsers(int companyId) async {
    try {
      final response = await _dioClient.get(
        ApiConfig.users,
        queryParameters: {'company_id': companyId},
      );

      print('✅ Get Users Response Status: ${response.statusCode}');
      print('📦 Get Users Response: ${response.data}');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> usersJson = response.data['users'] ?? [];
        return List<Map<String, dynamic>>.from(usersJson);
      }

      throw Exception(response.data['message'] ?? 'Failed to get users');
    } on DioException catch (e) {
      print('❌ Get Users Error: ${e.message}');
      print('⚠️ Error Response: ${e.response?.data}');
      rethrow;
    }
  }
}
