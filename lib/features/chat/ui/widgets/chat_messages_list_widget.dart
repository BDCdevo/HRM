import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_styles.dart';
import '../../data/models/message_model.dart';
import '../../logic/cubit/messages_state.dart';
import 'message_bubble.dart';

/// Chat Messages List Widget
///
/// Displays the list of messages with loading, error, and empty states
class ChatMessagesListWidget extends StatelessWidget {
  final MessagesState state;
  final ScrollController scrollController;
  final bool isDark;
  final int conversationId;
  final int companyId;
  final bool isGroupChat;
  final VoidCallback onRefresh;

  const ChatMessagesListWidget({
    super.key,
    required this.state,
    required this.scrollController,
    required this.isDark,
    required this.conversationId,
    required this.companyId,
    this.isGroupChat = false,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    // Loading state
    if (state is MessagesLoading) {
      return _buildLoadingState();
    }

    // Error state (with no cached messages)
    if (state is MessagesError && (state as MessagesError).messages == null) {
      return _buildErrorState(context, (state as MessagesError).message);
    }

    // Get messages from state
    final messages = _getMessagesFromState(state);

    // Empty state
    if (messages.isEmpty) {
      return _buildEmptyState();
    }

    // Messages list (reversed to show latest at bottom like WhatsApp)
    return RefreshIndicator(
      color: isDark ? AppColors.darkAccent : AppColors.accent,
      onRefresh: () async {
        onRefresh();
        // Wait a bit for refresh to complete
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.all(8),
        reverse: true, // Start from bottom (latest messages)
        itemCount: messages.length,
        itemBuilder: (context, index) {
          // Reverse the index to show newest at bottom
          final reversedIndex = messages.length - 1 - index;
          final message = messages[reversedIndex];

          // Check if we need to show date separator
          bool showDateSeparator = false;
          if (reversedIndex == messages.length - 1) {
            // First message (oldest)
            showDateSeparator = true;
          } else {
            final nextMessage = messages[reversedIndex + 1];
            showDateSeparator = _shouldShowDateSeparator(
              nextMessage.createdAt,
              message.createdAt,
            );
          }

          return Column(
            children: [
              // Message bubble
              MessageBubble(
                message: message,
                isSentByMe: message.isMine,
                isGroupChat: isGroupChat,
              ),

              // Date separator (shown after message in reversed list)
              if (showDateSeparator)
                _buildDateSeparator(message.createdAt),
            ],
          );
        },
      ),
    );
  }

  /// Get messages from state
  List<MessageModel> _getMessagesFromState(MessagesState state) {
    if (state is MessagesLoaded) return state.messages;
    if (state is MessageSending) return state.messages;
    if (state is MessageSent) return state.messages;
    if (state is MessagesRefreshing) return state.messages;
    if (state is MessagesError) return state.messages ?? [];
    return [];
  }

  /// Build Loading State
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: isDark ? AppColors.darkAccent : AppColors.accent,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading messages...',
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
  Widget _buildErrorState(BuildContext context, String errorMessage) {
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
              'Failed to load messages',
              style: AppTextStyles.titleMedium.copyWith(
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRefresh,
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
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (isDark ? AppColors.darkAccent : AppColors.accent)
                    .withOpacity(0.1),
              ),
              child: Icon(
                Icons.chat_bubble_outline,
                size: 64,
                color: isDark ? AppColors.darkAccent : AppColors.accent,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No messages yet',
              style: AppTextStyles.titleLarge.copyWith(
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start the conversation by sending a message',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Build Date Separator
  Widget _buildDateSeparator(String dateTimeString) {
    try {
      final messageDate = DateTime.parse(dateTimeString);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final messageDateOnly =
          DateTime(messageDate.year, messageDate.month, messageDate.day);

      String dateText;
      if (messageDateOnly == today) {
        dateText = 'Today';
      } else if (messageDateOnly == yesterday) {
        dateText = 'Yesterday';
      } else {
        dateText = DateFormat('MMM dd, yyyy').format(messageDate);
      }

      return Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1F2C34)
              : const Color(0xFFE1F5FE),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          dateText,
          style: AppTextStyles.bodySmall.copyWith(
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    } catch (e) {
      return const SizedBox.shrink();
    }
  }

  /// Check if we should show date separator
  bool _shouldShowDateSeparator(String previousDateTime, String currentDateTime) {
    try {
      final previous = DateTime.parse(previousDateTime);
      final current = DateTime.parse(currentDateTime);

      final previousDate = DateTime(previous.year, previous.month, previous.day);
      final currentDate = DateTime(current.year, current.month, current.day);

      return previousDate != currentDate;
    } catch (e) {
      return false;
    }
  }
}
