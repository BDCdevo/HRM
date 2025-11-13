import 'package:flutter/material.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_styles.dart';
import '../../data/models/message_model.dart';
import '../widgets/message_bubble.dart';

/// Chat Room Screen - WhatsApp Style
///
/// Displays messages between two users
class ChatRoomScreen extends StatefulWidget {
  final int conversationId;
  final String participantName;
  final String? participantAvatar;

  const ChatRoomScreen({
    super.key,
    required this.conversationId,
    required this.participantName,
    this.participantAvatar,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : const Color(0xFFECE5DD), // WhatsApp background color
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Messages List
          Expanded(child: _buildMessagesList()),

          // Message Input
          _buildMessageInput(),
        ],
      ),
    );
  }

  /// Build App Bar
  PreferredSizeWidget _buildAppBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      backgroundColor: isDark ? AppColors.darkAppBar : AppColors.primary,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: InkWell(
        onTap: _openEmployeeProfile,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white.withOpacity(0.2),
                ),
                child: Center(
                  child: Text(
                    widget.participantName.isNotEmpty
                        ? widget.participantName[0].toUpperCase()
                        : '?',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.participantName,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Tap to view profile',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: AppColors.white),
          onSelected: (value) {
            if (value == 'view_profile') {
              _openEmployeeProfile();
            } else if (value == 'clear_chat') {
              _showClearChatDialog();
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view_profile',
              child: Text('View profile'),
            ),
            const PopupMenuItem(value: 'clear_chat', child: Text('Clear chat')),
          ],
        ),
      ],
    );
  }

  /// Build Messages List
  Widget _buildMessagesList() {
    // TODO: Replace with BlocBuilder when cubit is ready
    final mockMessages = _getMockMessages();

    if (mockMessages.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(8),
      itemCount: mockMessages.length,
      itemBuilder: (context, index) {
        final message = mockMessages[index];
        return MessageBubble(
          message: message,
          isSentByMe: message.senderId == 34, // Current user ID
        );
      },
    );
  }

  /// Build Empty State
  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color:
                (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)
                    .withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: AppTextStyles.titleMedium.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Send a message to start the conversation',
            style: AppTextStyles.bodyMedium.copyWith(
              color:
                  (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary)
                      .withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  /// Build Message Input
  Widget _buildMessageInput() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
        children: [
          // Emoji button
          IconButton(
            icon: Icon(
              Icons.emoji_emotions_outlined,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
            onPressed: () {
              // TODO: Show emoji picker
            },
          ),

          // Text field
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkInput : AppColors.background,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Type a message',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
          ),

          const SizedBox(width: 4),

          // Attachment button
          IconButton(
            icon: Icon(
              Icons.attach_file,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
            onPressed: () {
              // TODO: Show attachment options
            },
          ),

          // Camera button
          IconButton(
            icon: Icon(
              Icons.camera_alt,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
            onPressed: () {
              // TODO: Open camera
            },
          ),

          // Send button
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkAccent : AppColors.accent,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: AppColors.white, size: 20),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  /// Send Message
  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    // TODO: Send message via cubit

    _messageController.clear();
  }

  /// Open Employee Profile
  void _openEmployeeProfile() {
    // TODO: Navigate to employee profile screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening ${widget.participantName}\'s profile...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Show Clear Chat Dialog
  void _showClearChatDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear chat'),
        content: const Text(
          'Are you sure you want to clear this chat? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Clear chat via cubit
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Chat cleared successfully')),
              );
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  /// Get Mock Messages (for testing UI)
  List<MessageModel> _getMockMessages() {
    return [
      MessageModel(
        id: 1,
        conversationId: widget.conversationId,
        senderId: 32,
        senderName: widget.participantName,
        message: 'Hey! How are you doing?',
        messageType: 'text',
        isRead: true,
        createdAt: DateTime.now()
            .subtract(const Duration(hours: 2))
            .toIso8601String(),
        updatedAt: DateTime.now()
            .subtract(const Duration(hours: 2))
            .toIso8601String(),
      ),
      MessageModel(
        id: 2,
        conversationId: widget.conversationId,
        senderId: 34,
        senderName: 'You',
        message: 'I\'m good, thanks! How about you?',
        messageType: 'text',
        isRead: true,
        createdAt: DateTime.now()
            .subtract(const Duration(hours: 2, minutes: -5))
            .toIso8601String(),
        updatedAt: DateTime.now()
            .subtract(const Duration(hours: 2, minutes: -5))
            .toIso8601String(),
      ),
      MessageModel(
        id: 3,
        conversationId: widget.conversationId,
        senderId: 32,
        senderName: widget.participantName,
        message: 'Pretty good! Working on the new project.',
        messageType: 'text',
        isRead: true,
        createdAt: DateTime.now()
            .subtract(const Duration(hours: 1, minutes: 50))
            .toIso8601String(),
        updatedAt: DateTime.now()
            .subtract(const Duration(hours: 1, minutes: 50))
            .toIso8601String(),
      ),
      MessageModel(
        id: 4,
        conversationId: widget.conversationId,
        senderId: 34,
        senderName: 'You',
        message: 'That sounds great! Need any help?',
        messageType: 'text',
        isRead: false,
        createdAt: DateTime.now()
            .subtract(const Duration(minutes: 30))
            .toIso8601String(),
        updatedAt: DateTime.now()
            .subtract(const Duration(minutes: 30))
            .toIso8601String(),
      ),
      MessageModel(
        id: 5,
        conversationId: widget.conversationId,
        senderId: 32,
        senderName: widget.participantName,
        message: 'Actually yes! Can we discuss this later?',
        messageType: 'text',
        isRead: false,
        createdAt: DateTime.now()
            .subtract(const Duration(minutes: 5))
            .toIso8601String(),
        updatedAt: DateTime.now()
            .subtract(const Duration(minutes: 5))
            .toIso8601String(),
      ),
    ];
  }
}
