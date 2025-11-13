import 'package:flutter/material.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_styles.dart';
import '../../data/models/conversation_model.dart';
import '../../data/models/message_model.dart';
import '../widgets/conversation_card.dart';
import 'employee_selection_screen.dart';
import 'chat_room_screen.dart';

/// Chat List Screen - WhatsApp Style
///
/// Displays list of conversations
class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildNewChatButton(),
    );
  }

  /// Build App Bar
  PreferredSizeWidget _buildAppBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      backgroundColor: isDark ? AppColors.darkAppBar : AppColors.primary,
      elevation: 0,
      title: Text(
        'Chats',
        style: AppTextStyles.titleLarge.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        // Search button
        IconButton(
          icon: const Icon(Icons.search, color: AppColors.white),
          onPressed: () {
            // TODO: Navigate to search screen
          },
        ),
        // More options
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: AppColors.white),
          onSelected: (value) {
            // TODO: Handle menu selection
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'new_group', child: Text('New group')),
            const PopupMenuItem(value: 'settings', child: Text('Settings')),
          ],
        ),
      ],
    );
  }

  /// Build Body
  Widget _buildBody() {
    // TODO: Replace with BlocBuilder when cubit is ready
    final mockConversations = _getMockConversations();

    if (mockConversations.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      itemCount: mockConversations.length,
      itemBuilder: (context, index) {
        final conversation = mockConversations[index];
        return ConversationCard(
          conversation: conversation,
          currentUserId: 34, // Mock current user ID
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatRoomScreen(
                  conversationId: conversation.id,
                  participantName: conversation.participantName,
                  participantAvatar: conversation.participantAvatar,
                ),
              ),
            );
          },
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
            size: 100,
            color:
                (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)
                    .withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'No conversations yet',
            style: AppTextStyles.titleMedium.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Start chatting with your colleagues!',
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

  /// Build New Chat Button (FAB)
  Widget _buildNewChatButton() {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const EmployeeSelectionScreen(),
          ),
        );
      },
      backgroundColor: AppColors.accent,
      child: const Icon(Icons.chat, color: AppColors.white),
    );
  }

  /// Get Mock Conversations (for testing UI)
  List<ConversationModel> _getMockConversations() {
    return [
      ConversationModel(
        id: 1,
        participantId: 32,
        participantName: 'Ahmed Abbas',
        participantDepartment: 'Development',
        lastMessage: MessageModel(
          id: 1,
          conversationId: 1,
          senderId: 32,
          senderName: 'Ahmed Abbas',
          message: 'Hey! How are you?',
          messageType: 'text',
          isRead: false,
          createdAt: DateTime.now()
              .subtract(const Duration(minutes: 5))
              .toIso8601String(),
          updatedAt: DateTime.now()
              .subtract(const Duration(minutes: 5))
              .toIso8601String(),
        ),
        unreadCount: 2,
        updatedAt: DateTime.now()
            .subtract(const Duration(minutes: 5))
            .toIso8601String(),
      ),
      ConversationModel(
        id: 2,
        participantId: 35,
        participantName: 'Mohamed Ali',
        participantDepartment: 'HR',
        lastMessage: MessageModel(
          id: 2,
          conversationId: 2,
          senderId: 34,
          senderName: 'You',
          message: 'Thanks for your help!',
          messageType: 'text',
          isRead: true,
          createdAt: DateTime.now()
              .subtract(const Duration(hours: 2))
              .toIso8601String(),
          updatedAt: DateTime.now()
              .subtract(const Duration(hours: 2))
              .toIso8601String(),
        ),
        unreadCount: 0,
        updatedAt: DateTime.now()
            .subtract(const Duration(hours: 2))
            .toIso8601String(),
      ),
      ConversationModel(
        id: 3,
        participantId: 36,
        participantName: 'Sara Ahmed',
        participantDepartment: 'Sales',
        lastMessage: MessageModel(
          id: 3,
          conversationId: 3,
          senderId: 36,
          senderName: 'Sara Ahmed',
          message: 'Can we meet tomorrow?',
          messageType: 'text',
          isRead: false,
          createdAt: DateTime.now()
              .subtract(const Duration(days: 1))
              .toIso8601String(),
          updatedAt: DateTime.now()
              .subtract(const Duration(days: 1))
              .toIso8601String(),
        ),
        unreadCount: 1,
        updatedAt: DateTime.now()
            .subtract(const Duration(days: 1))
            .toIso8601String(),
      ),
    ];
  }
}
