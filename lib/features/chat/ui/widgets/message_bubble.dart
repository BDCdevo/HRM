import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_styles.dart';
import '../../data/models/message_model.dart';
import 'voice_message_player.dart';

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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Avatar for received messages (left side)
            if (!isSentByMe) ...[
              _buildAvatar(isDark),
              const SizedBox(width: 8),
            ],

            // Message content
            Flexible(
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSentByMe
                          ? (isDark
                                ? AppColors.primary.withOpacity(
                                    0.85,
                                  ) // Primary color in dark mode
                                : AppColors.primary.withOpacity(
                                    0.15,
                                  )) // Light primary in light mode
                          : (isDark
                                ? AppColors
                                      .darkCard // Dark card color for received
                                : AppColors
                                      .surface), // Surface color for light mode
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(12),
                        topRight: const Radius.circular(12),
                        bottomLeft: isSentByMe
                            ? const Radius.circular(12)
                            : const Radius.circular(2),
                        bottomRight: isSentByMe
                            ? const Radius.circular(2)
                            : const Radius.circular(12),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withOpacity(0.2)
                              : Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkBorder.withOpacity(0.5)
                            : AppColors.border.withOpacity(0.3),
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
                                          : const Color(
                                              0xFF667781,
                                            )) // WhatsApp grey
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

            // Avatar for sent messages (right side) - optional, usually not shown
            // Uncomment if you want to show user's own avatar on sent messages
            // if (isSentByMe) ...[
            //   const SizedBox(width: 8),
            //   _buildAvatar(isDark),
            // ],
          ],
        ),
      ),
    );
  }

  /// Build Avatar Widget
  Widget _buildAvatar(bool isDark) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getAvatarColor(message.senderName),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
          width: 1,
        ),
      ),
      child: message.senderAvatar != null && message.senderAvatar!.isNotEmpty
          ? ClipOval(
              child: CachedNetworkImage(
                imageUrl: message.senderAvatar!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Center(
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.white,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => _buildAvatarPlaceholder(),
              ),
            )
          : _buildAvatarPlaceholder(),
    );
  }

  /// Build Avatar Placeholder (Initials)
  Widget _buildAvatarPlaceholder() {
    final initials = message.senderName
        .split(' ')
        .take(2)
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() : '')
        .join();

    return Center(
      child: Text(
        initials.isEmpty ? '?' : initials,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  /// Get Avatar Color based on sender name
  Color _getAvatarColor(String name) {
    final colors = [
      const Color(0xFF00A884), // WhatsApp Green
      const Color(0xFF0088CC), // Telegram Blue
      const Color(0xFF7B68EE), // Medium Purple
      const Color(0xFFE91E63), // Pink
      const Color(0xFFFF6F00), // Orange
      const Color(0xFF00BCD4), // Cyan
      const Color(0xFF9C27B0), // Purple
      const Color(0xFF4CAF50), // Green
      const Color(0xFFF44336), // Red
      const Color(0xFF607D8B), // Blue Grey
      const Color(0xFF795548), // Brown
      const Color(0xFF009688), // Teal
    ];

    final hash = name.hashCode.abs();
    return colors[hash % colors.length];
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
                ? (isDark ? AppColors.white : AppColors.textPrimary)
                : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
            fontSize: 15,
          ),
        );
    }
  }

  /// Build Image Message (WhatsApp Style)
  Widget _buildImageMessage(bool isDark) {
    // Check if we have a valid image URL
    if (message.attachmentUrl == null || message.attachmentUrl!.isEmpty) {
      return _buildPlaceholderImage(isDark);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image with rounded corners (WhatsApp style)
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: GestureDetector(
            onTap: () => _showImageFullScreen(),
            child: CachedNetworkImage(
              imageUrl: message.attachmentUrl!,
              width: 250,
              height: 250,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 250,
                height: 250,
                color: isDark ? AppColors.darkInput : AppColors.background,
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDark ? AppColors.darkAccent : AppColors.accent,
                    ),
                  ),
                ),
              ),
              errorWidget: (context, url, error) =>
                  _buildPlaceholderImage(isDark),
            ),
          ),
        ),

        // Caption (if exists)
        if (message.message.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            message.message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isSentByMe
                  ? (isDark ? Colors.white : const Color(0xFF111B21))
                  : (isDark ? Colors.white : const Color(0xFF111B21)),
              height: 1.4,
              fontSize: 15,
            ),
          ),
        ],
      ],
    );
  }

  /// Build Placeholder Image (when URL is missing or error)
  Widget _buildPlaceholderImage(bool isDark) {
    return Container(
      width: 250,
      height: 250,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkInput : AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image,
              size: 48,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
            const SizedBox(height: 8),
            Text(
              'Image unavailable',
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show Image in Full Screen
  void _showImageFullScreen() {
    if (message.attachmentUrl == null) return;

    // You can implement a full-screen image viewer here
    // For now, we'll just print a message
    print('📸 Opening image: ${message.attachmentUrl}');
    // TODO: Implement full-screen image viewer with PhotoView or similar package
  }

  /// Build File Message (WhatsApp Style)
  Widget _buildFileMessage(bool isDark) {
    final accentColor = isDark ? AppColors.darkAccent : AppColors.accent;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;

    // Get file info
    final fileName =
        message.attachmentName ?? message.message ?? 'Unknown file';
    final fileSize = message.attachmentSize != null
        ? _formatFileSize(message.attachmentSize!)
        : '';

    // Get file icon based on extension
    final fileIcon = _getFileIcon(fileName);
    final fileColor = _getFileColor(fileName, accentColor, primaryColor);

    return Container(
      constraints: const BoxConstraints(maxWidth: 280),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // File Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: fileColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(fileIcon, color: fileColor, size: 28),
          ),

          const SizedBox(width: 12),

          // File Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // File Name
                Text(
                  fileName,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isSentByMe
                        ? (isDark ? Colors.white : const Color(0xFF111B21))
                        : (isDark ? Colors.white : const Color(0xFF111B21)),
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                // File Size
                if (fileSize.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    fileSize,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark
                          ? Colors.white.withOpacity(0.6)
                          : const Color(0xFF667781),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Download Icon
          if (message.attachmentUrl != null &&
              message.attachmentUrl!.isNotEmpty)
            Icon(
              Icons.download_rounded,
              color: isDark
                  ? Colors.white.withOpacity(0.7)
                  : const Color(0xFF667781),
              size: 20,
            ),
        ],
      ),
    );
  }

  /// Format File Size (bytes to human-readable)
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Get File Icon based on extension
  IconData _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();

    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'zip':
      case 'rar':
      case '7z':
        return Icons.folder_zip;
      case 'txt':
        return Icons.text_snippet;
      default:
        return Icons.insert_drive_file;
    }
  }

  /// Get File Color based on type
  Color _getFileColor(String fileName, Color accent, Color primary) {
    final extension = fileName.split('.').last.toLowerCase();

    switch (extension) {
      case 'pdf':
        return const Color(0xFFE53935); // Red for PDF
      case 'doc':
      case 'docx':
        return const Color(0xFF1976D2); // Blue for Word
      case 'xls':
      case 'xlsx':
        return const Color(0xFF388E3C); // Green for Excel
      case 'ppt':
      case 'pptx':
        return const Color(0xFFD84315); // Orange for PowerPoint
      case 'zip':
      case 'rar':
      case '7z':
        return const Color(0xFF7B1FA2); // Purple for archives
      default:
        return accent;
    }
  }

  /// Build Voice Message
  Widget _buildVoiceMessage(bool isDark) {
    // Check if we have a valid audio URL
    if (message.attachmentUrl == null || message.attachmentUrl!.isEmpty) {
      return Text(
        'Voice message (no audio available)',
        style: AppTextStyles.bodyMedium.copyWith(
          color: isSentByMe
              ? (isDark ? Colors.white : AppColors.textPrimary)
              : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return VoiceMessagePlayer(
      audioUrl: message.attachmentUrl!,
      isMine: isSentByMe,
      isDark: isDark,
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
    return Icon(Icons.done_all, size: 16, color: Colors.grey[600]);

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
