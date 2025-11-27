import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_styles.dart';
import '../../data/models/message_model.dart';
import 'voice_recording_widget.dart';

/// Chat Input Bar Widget - WhatsApp Style
///
/// Handles message input, attachments, voice recording, emoji picker
class ChatInputBarWidget extends StatelessWidget {
  final TextEditingController messageController;
  final FocusNode? messageFocusNode;
  final bool isSending;
  final bool isRecording;
  final bool isEmojiPickerVisible;
  final bool isDark;
  final VoidCallback onSendMessage;
  final VoidCallback onPickImage;
  final VoidCallback onPickFile;
  final VoidCallback onStartRecording;
  final Future<void> Function() onStopRecording;
  final Future<void> Function(String path) onSendRecording;
  final VoidCallback onCancelRecording;
  final VoidCallback onEmojiToggle;
  // Reply to message
  final MessageModel? replyToMessage;
  final VoidCallback? onCancelReply;

  const ChatInputBarWidget({
    super.key,
    required this.messageController,
    this.messageFocusNode,
    this.isSending = false,
    this.isRecording = false,
    this.isEmojiPickerVisible = false,
    required this.isDark,
    required this.onSendMessage,
    required this.onPickImage,
    required this.onPickFile,
    required this.onStartRecording,
    required this.onStopRecording,
    required this.onSendRecording,
    required this.onCancelRecording,
    required this.onEmojiToggle,
    this.replyToMessage,
    this.onCancelReply,
  });

  @override
  Widget build(BuildContext context) {
    // Show recording widget if recording
    if (isRecording) {
      return VoiceRecordingWidget(
        onRecordingComplete: onStopRecording,
        onSendRecording: onSendRecording,
        onCancel: onCancelRecording,
      );
    }

    // Listen to text changes for real-time icon switching
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: messageController,
      builder: (context, value, child) {
        final hasText = value.text.isNotEmpty;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Reply preview (if replying to a message)
            if (replyToMessage != null) _buildReplyPreview(),

            // Input bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.15 : 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Text field with emoji, attachment, and camera icons inside
                  Expanded(
                    child: _buildTextInputField(hasText),
                  ),

                  const SizedBox(width: 8),

                  // Send or Mic button
                  _buildActionButton(hasText),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// Build Reply Preview above input bar
  Widget _buildReplyPreview() {
    final message = replyToMessage!;
    final borderColor = isDark
        ? const Color(0xFF00A884)
        : const Color(0xFF25D366);

    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkCard.withOpacity(0.95)
            : AppColors.white.withOpacity(0.95),
        border: Border(
          left: BorderSide(
            color: borderColor,
            width: 4,
          ),
          top: BorderSide(
            color: isDark
                ? Colors.grey.withOpacity(0.2)
                : Colors.grey.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Reply info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Sender name
                Text(
                  message.isMine ? 'You' : message.senderName,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: borderColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                // Message preview
                Text(
                  message.message.isNotEmpty
                      ? message.message
                      : (message.messageType == 'image'
                          ? '📷 Photo'
                          : message.messageType == 'voice'
                              ? '🎤 Voice message'
                              : '📎 File'),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Close button
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
            icon: Icon(
              Icons.close,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
              size: 20,
            ),
            onPressed: onCancelReply,
          ),
        ],
      ),
    );
  }

  /// Build Text Input Field
  Widget _buildTextInputField(bool hasText) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkInput : AppColors.background,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Emoji button - toggles between emoji and keyboard icon
          IconButton(
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
            icon: Icon(
              isEmojiPickerVisible
                  ? Icons.keyboard_outlined
                  : Icons.emoji_emotions_outlined,
              color: isDark
                  ? const Color(0xFF8696A0) // WhatsApp dark gray
                  : const Color(0xFF54656F), // WhatsApp gray
              size: 26,
            ),
            onPressed: isSending ? null : onEmojiToggle,
          ),

          const SizedBox(width: 4),

          // Text input
          Expanded(
            child: TextField(
              controller: messageController,
              focusNode: messageFocusNode,
              enabled: !isSending,
              style: AppTextStyles.inputText.copyWith(
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Message',
                hintStyle: AppTextStyles.inputHint.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary.withOpacity(0.6)
                      : AppColors.textSecondary.withOpacity(0.6),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 4,
                ),
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              // Keep keyboard open - use newline action instead of send
              textInputAction: TextInputAction.newline,
            ),
          ),

          // Show attachment and camera only when no text
          if (!hasText) ...[
            // Attachment button
            IconButton(
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(),
              icon: Transform.rotate(
                angle: -0.785398, // -45 degrees
                child: Icon(
                  Icons.attach_file,
                  color: isDark
                      ? const Color(0xFF8696A0)
                      : const Color(0xFF54656F),
                  size: 24,
                ),
              ),
              onPressed: isSending ? null : onPickFile,
            ),

            const SizedBox(width: 4),

            // Camera button
            IconButton(
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(),
              icon: SvgPicture.asset(
                'assets/whatsapp_icons/Camera.svg',
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  isDark
                      ? const Color(0xFF8696A0)
                      : const Color(0xFF54656F),
                  BlendMode.srcIn,
                ),
              ),
              onPressed: isSending ? null : onPickImage,
            ),

            const SizedBox(width: 4),
          ],
        ],
      ),
    );
  }

  /// Build Action Button (Send or Mic)
  Widget _buildActionButton(bool hasText) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkAccent : AppColors.accent,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(
          hasText ? Icons.send : Icons.mic,
          color: AppColors.white,
          size: 24,
        ),
        onPressed: isSending
            ? null
            : () {
                if (hasText) {
                  onSendMessage();
                } else {
                  onStartRecording();
                }
              },
      ),
    );
  }
}
