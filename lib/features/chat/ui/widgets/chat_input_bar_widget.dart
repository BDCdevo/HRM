import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_styles.dart';
import 'voice_recording_widget.dart';

/// Chat Input Bar Widget - WhatsApp Style
///
/// Handles message input, attachments, voice recording
class ChatInputBarWidget extends StatelessWidget {
  final TextEditingController messageController;
  final FocusNode? messageFocusNode;
  final bool isSending;
  final bool isRecording;
  final bool isDark;
  final VoidCallback onSendMessage;
  final VoidCallback onPickImage;
  final VoidCallback onPickFile;
  final VoidCallback onStartRecording;
  final Future<void> Function() onStopRecording;
  final Future<void> Function(String path) onSendRecording;
  final VoidCallback onCancelRecording;

  const ChatInputBarWidget({
    super.key,
    required this.messageController,
    this.messageFocusNode,
    this.isSending = false,
    this.isRecording = false,
    required this.isDark,
    required this.onSendMessage,
    required this.onPickImage,
    required this.onPickFile,
    required this.onStartRecording,
    required this.onStopRecording,
    required this.onSendRecording,
    required this.onCancelRecording,
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

    final hasText = messageController.text.isNotEmpty;

    return Container(
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
          // Emoji button
          IconButton(
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
            icon: Icon(
              Icons.emoji_emotions_outlined,
              color: isDark
                  ? const Color(0xFF8696A0) // WhatsApp dark gray
                  : const Color(0xFF54656F), // WhatsApp gray
              size: 26,
            ),
            onPressed: isSending
                ? null
                : () {
                    // TODO: Show emoji picker
                  },
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
