import 'package:flutter/material.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_styles.dart';
import '../../data/models/message_model.dart';

/// Message Bubble Widget - WhatsApp Style
///
/// Displays a message bubble
class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isSentByMe;
  final bool isGroupChat;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isSentByMe,
    this.isGroupChat = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          left: isSentByMe ? 60 : 12,
          right: isSentByMe ? 12 : 60,
          top: 2,
          bottom: 2,
        ),
        child: Column(
          crossAxisAlignment: isSentByMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            // Sender name (for group chats only, received messages only)
            if (isGroupChat && !isSentByMe)
              Padding(
                padding: const EdgeInsets.only(left: 12, bottom: 4),
                child: Text(
                  message.senderName,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: _getColorForUser(message.senderId),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

            // Message bubble
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSentByMe
                    ? (isDark
                          ? const Color(0xFF005C4B) // WhatsApp dark green
                          : const Color(0xFFDCF8C6)) // WhatsApp light green
                    : (isDark
                          ? const Color(0xFF1F2C34) // Dark grey for received
                          : Colors.white), // White for light mode
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(8),
                  topRight: const Radius.circular(8),
                  bottomLeft: isSentByMe
                      ? const Radius.circular(8)
                      : const Radius.circular(0),
                  bottomRight: isSentByMe
                      ? const Radius.circular(0)
                      : const Radius.circular(8),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
                border: isSentByMe
                    ? null
                    : Border.all(
                        color: isDark
                            ? Colors.transparent
                            : Colors.grey.shade200,
                        width: 1,
                      ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Message content
                  _buildMessageContent(isDark),

                  const SizedBox(height: 4),

                  // Time and status
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message.formattedTime,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isSentByMe
                              ? (isDark
                                    ? Colors.white.withOpacity(0.7)
                                    : const Color(0xFF667781)) // WhatsApp grey
                              : (isDark
                                    ? Colors.white.withOpacity(0.6)
                                    : const Color(0xFF667781)),
                          fontSize: 11,
                        ),
                      ),
                      if (isSentByMe) ...[
                        const SizedBox(width: 4),
                        _buildMessageStatus(),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build Message Content
  Widget _buildMessageContent(bool isDark) {
    switch (message.messageType) {
      case 'image':
        return _buildImageMessage(isDark);
      case 'file':
        return _buildFileMessage(isDark);
      case 'voice':
        return _buildVoiceMessage(isDark);
      default:
        // Text message
        return Text(
          message.message,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isSentByMe
                ? (isDark
                      ? Colors.white
                      : const Color(0xFF111B21)) // Dark text for light green
                : (isDark
                      ? Colors.white
                      : const Color(0xFF111B21)), // Dark text
            height: 1.4,
            fontSize: 15,
          ),
        );
    }
  }

  /// Build Image Message
  Widget _buildImageMessage(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 200,
          height: 150,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkInput : AppColors.background,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Icon(
              Icons.image,
              size: 48,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
        ),
        if (message.message.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            message.message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isSentByMe
                  ? (isDark ? AppColors.white : AppColors.textPrimary)
                  : (isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary),
            ),
          ),
        ],
      ],
    );
  }

  /// Build File Message
  Widget _buildFileMessage(bool isDark) {
    final accentColor = isDark ? AppColors.darkAccent : AppColors.accent;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.insert_drive_file, color: accentColor),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            message.message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isSentByMe
                  ? (isDark ? AppColors.white : AppColors.textPrimary)
                  : (isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary),
            ),
          ),
        ),
      ],
    );
  }

  /// Build Voice Message
  Widget _buildVoiceMessage(bool isDark) {
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;
    final accentColor = isDark ? AppColors.darkAccent : AppColors.accent;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.play_circle_filled,
          color: isSentByMe ? accentColor : primaryColor,
          size: 32,
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Container(
            height: 32,
            width: 150,
            decoration: BoxDecoration(
              color: isSentByMe
                  ? accentColor.withOpacity(0.2)
                  : primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Icon(
                Icons.graphic_eq,
                size: 20,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Build Message Status Icon (WhatsApp Style)
  Widget _buildMessageStatus() {
    // ✓✓ Blue = Read (رسالة مقروءة)
    if (message.isRead) {
      return Icon(
        Icons.done_all,
        size: 16,
        color: const Color(0xFF53BDEB), // WhatsApp blue
      );
    }

    // ✓✓ Grey = Delivered (تم التوصيل)
    // Note: Backend should send 'delivered_at' field
    // For now, we assume if not read, it's delivered
    return Icon(
      Icons.done_all,
      size: 16,
      color: Colors.grey[600],
    );

    // ✓ Grey = Sent (تم الإرسال)
    // This would be shown if message just sent but not delivered yet
    // return Icon(Icons.done, size: 16, color: Colors.grey[600]);
  }

  /// Get unique color for each user in group (WhatsApp Style)
  Color _getColorForUser(int userId) {
    // WhatsApp-style colors for group member names
    final colors = [
      const Color(0xFF00A884), // WhatsApp Green
      const Color(0xFF0088CC), // Telegram Blue
      const Color(0xFFFF8800), // Orange
      const Color(0xFF9C27B0), // Purple
      const Color(0xFFE91E63), // Pink
      const Color(0xFF009688), // Teal
      const Color(0xFFFF5722), // Deep Orange
      const Color(0xFF795548), // Brown
      const Color(0xFF607D8B), // Blue Grey
      const Color(0xFF4CAF50), // Green
    ];

    return colors[userId % colors.length];
  }
}
