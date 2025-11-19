import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_styles.dart';
import '../../data/repo/chat_repository.dart';
import '../../logic/cubit/chat_cubit.dart';
import '../../logic/cubit/chat_state.dart';
import '../widgets/conversation_card.dart';
import 'employee_selection_screen.dart';
import 'chat_room_screen.dart';

/// Chat List Screen - WhatsApp Style
///
/// Displays list of conversations
class ChatListScreen extends StatelessWidget {
  final int companyId;
  final int currentUserId;

  const ChatListScreen({
    super.key,
    required this.companyId,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatCubit(ChatRepository())
        ..fetchConversations(
          companyId: companyId,
          currentUserId: currentUserId,
        ),
      child: _ChatListView(
        companyId: companyId,
        currentUserId: currentUserId,
      ),
    );
  }
}

class _ChatListView extends StatelessWidget {
  final int companyId;
  final int currentUserId;

  const _ChatListView({
    required this.companyId,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: _buildAppBar(context, isDark),
      body: BlocConsumer<ChatCubit, ChatState>(
        listener: (context, state) {
          if (state is ChatError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                action: SnackBarAction(
                  label: 'Retry',
                  textColor: AppColors.white,
                  onPressed: () {
                    context.read<ChatCubit>().fetchConversations(
                      companyId: companyId,
                      currentUserId: currentUserId,
                    );
                  },
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ChatLoading) {
            return _buildLoadingState(isDark);
          }

          if (state is ChatError) {
            return _buildErrorState(context, state.message);
          }

          if (state is ChatLoaded) {
            if (state.conversations.isEmpty) {
              return _buildEmptyState(context, isDark);
            }
            return _buildConversationsList(context, state, isDark);
          }

          if (state is ChatRefreshing) {
            return _buildConversationsList(
              context,
              ChatLoaded(state.conversations),
              isDark,
              isRefreshing: true,
            );
          }

          return _buildEmptyState(context, isDark);
        },
      ),
      floatingActionButton: _buildNewChatButton(context),
    );
  }

  /// Build App Bar
  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDark) {
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
            if (value == 'refresh') {
              context.read<ChatCubit>().refreshConversations(
                companyId: companyId,
                currentUserId: currentUserId,
              );
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'refresh',
              child: Row(
                children: [
                  Icon(Icons.refresh),
                  SizedBox(width: 8),
                  Text('Refresh'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'new_group',
              child: Row(
                children: [
                  Icon(Icons.group_add),
                  SizedBox(width: 8),
                  Text('New group'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build Loading State
  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: isDark ? AppColors.darkAccent : AppColors.accent,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading conversations...',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Build Error State
  Widget _buildErrorState(BuildContext context, String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load conversations',
              style: AppTextStyles.titleMedium.copyWith(
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<ChatCubit>().fetchConversations(
                  companyId: companyId,
                  currentUserId: currentUserId,
                );
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? AppColors.darkAccent : AppColors.accent,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build Empty State
  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lottie Animation
            SizedBox(
              width: 250,
              height: 250,
              child: Lottie.asset(
                'assets/svgs/Welcome.json',
                fit: BoxFit.contain,
                repeat: true,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              'No conversations yet',
              style: AppTextStyles.titleLarge.copyWith(
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Start chatting with your colleagues!\nTap the + button below to begin',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 32),

            // Call to action button
            ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EmployeeSelectionScreen(
                      companyId: companyId,
                      currentUserId: currentUserId,
                    ),
                  ),
                );

                // Refresh conversation list when returning from new chat
                if (context.mounted) {
                  context.read<ChatCubit>().fetchConversations(
                    companyId: companyId,
                    currentUserId: currentUserId,
                  );
                }
              },
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('Start New Chat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? AppColors.darkAccent : AppColors.accent,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build Conversations List
  Widget _buildConversationsList(
    BuildContext context,
    ChatLoaded state,
    bool isDark, {
    bool isRefreshing = false,
  }) {
    return RefreshIndicator(
      color: isDark ? AppColors.darkAccent : AppColors.accent,
      onRefresh: () async {
        await context.read<ChatCubit>().refreshConversations(
          companyId: companyId,
          currentUserId: currentUserId,
        );
      },
      child: ListView.builder(
        itemCount: state.conversations.length,
        itemBuilder: (context, index) {
          final conversation = state.conversations[index];
          return ConversationCard(
            conversation: conversation,
            currentUserId: currentUserId,
            index: index,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatRoomScreen(
                    conversationId: conversation.id,
                    participantName: conversation.participantName,
                    participantAvatar: conversation.participantAvatar,
                    companyId: companyId,
                    currentUserId: currentUserId,
                    isGroupChat: conversation.isGroup,
                  ),
                ),
              );

              // Refresh conversation list when returning
              if (context.mounted) {
                context.read<ChatCubit>().fetchConversations(
                  companyId: companyId,
                  currentUserId: currentUserId,
                );
              }
            },
            onArchive: () {
              _showSnackBar(
                context,
                '📦 Conversation archived',
                isDark,
              );
            },
            onDelete: () {
              _showSnackBar(
                context,
                '🗑️ Conversation deleted',
                isDark,
              );
            },
            onPin: () {
              _showSnackBar(
                context,
                '📌 Conversation pinned',
                isDark,
              );
            },
          );
        },
      ),
    );
  }

  /// Show SnackBar
  void _showSnackBar(BuildContext context, String message, bool isDark) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isDark ? AppColors.darkCard : AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Build New Chat Button (FAB)
  Widget _buildNewChatButton(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FloatingActionButton(
      onPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EmployeeSelectionScreen(
              companyId: companyId,
              currentUserId: currentUserId,
            ),
          ),
        );

        // Refresh conversation list when returning from new chat
        if (context.mounted) {
          context.read<ChatCubit>().fetchConversations(
            companyId: companyId,
            currentUserId: currentUserId,
          );
        }
      },
      backgroundColor: isDark ? AppColors.darkAccent : AppColors.accent,
      child: const Icon(Icons.chat, color: AppColors.white),
    );
  }
}
