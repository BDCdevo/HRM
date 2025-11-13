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

  const MessageBubble({
    super.key,
    required this.message,
    required this.isSentByMe,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          left: isSentByMe ? 64 : 8,
          right: isSentByMe ? 8 : 64,
          top: 4,
          bottom: 4,
        ),
        child: Column(
          crossAxisAlignment: isSentByMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            // Message bubble
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSentByMe
                    ? (isDark
                          ? const Color(
                              0xFF005C4B,
                            ) // Darker green for dark mode
                          : const Color(
                              0xFFDCF8C6,
                            )) // WhatsApp green for light mode
                    : (isDark
                          ? AppColors
                                .darkCard // Dark card for dark mode
                          : AppColors.white), // White for light mode
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft: isSentByMe
                      ? const Radius.circular(12)
                      : const Radius.circular(0),
                  bottomRight: isSentByMe
                      ? const Radius.circular(0)
                      : const Radius.circular(12),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.15 : 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sender name (only for received messages)
                  if (!isSentByMe) ...[
                    Text(
                      message.senderName,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark ? AppColors.darkAccent : AppColors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],

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
                                    ? AppColors.darkTextSecondary.withOpacity(
                                        0.8,
                                      )
                                    : AppColors.textSecondary)
                              : (isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary),
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
        return Text(
          message.message,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isSentByMe
                ? (isDark ? AppColors.white : AppColors.textPrimary)
                : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
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

  /// Build Message Status Icon
  Widget _buildMessageStatus() {
    if (message.isRead) {
      // Double check (read)
      return Icon(
        Icons.done_all,
        size: 16,
        color: const Color(0xFF34B7F1), // WhatsApp blue for read
      );
    } else {
      // Single check (delivered) or double check (not read)
      return Icon(Icons.done, size: 16, color: AppColors.textSecondary);
    }
  }
}
