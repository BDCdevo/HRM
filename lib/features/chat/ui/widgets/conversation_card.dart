import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_styles.dart';
import '../../data/models/conversation_model.dart';

/// Conversation Card Widget - WhatsApp Style
///
/// Displays a conversation item in the chat list
class ConversationCard extends StatelessWidget {
  final ConversationModel conversation;
  final int currentUserId;
  final VoidCallback onTap;

  const ConversationCard({
    super.key,
    required this.conversation,
    required this.currentUserId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.white,
          border: Border(
            bottom: BorderSide(
              color: (isDark ? AppColors.darkBorder : AppColors.border)
                  .withOpacity(0.2),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            // Avatar
            _buildAvatar(),

            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and Time
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.participantName,
                          style: AppTextStyles.titleMedium.copyWith(
                            color: isDark ? AppColors.darkTextPrimary : null,
                            fontWeight: conversation.hasUnreadMessages
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        conversation.formattedTime,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: conversation.hasUnreadMessages
                              ? (isDark
                                    ? AppColors.darkAccent
                                    : AppColors.accent)
                              : (isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary),
                          fontSize: 12,
                          fontWeight: conversation.hasUnreadMessages
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Last Message and Badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation.lastMessagePreview,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: conversation.hasUnreadMessages
                                ? (isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.textPrimary)
                                : (isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.textSecondary),
                            fontWeight: conversation.hasUnreadMessages
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (conversation.hasUnreadMessages) ...[
                        const SizedBox(width: 8),
                        _buildUnreadBadge(isDark),
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

  /// Build Avatar
  Widget _buildAvatar() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withOpacity(0.1),
      ),
      child: conversation.participantAvatar != null
          ? ClipOval(
              child: CachedNetworkImage(
                imageUrl: conversation.participantAvatar!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
                errorWidget: (context, url, error) => _buildAvatarPlaceholder(),
              ),
            )
          : _buildAvatarPlaceholder(),
    );
  }

  /// Build Avatar Placeholder
  Widget _buildAvatarPlaceholder() {
    final initials = conversation.participantName
        .split(' ')
        .take(2)
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() : '')
        .join();

    return Center(
      child: Text(
        initials,
        style: AppTextStyles.titleLarge.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Build Unread Badge
  Widget _buildUnreadBadge(bool isDark) {
    return Container(
      constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkAccent : AppColors.accent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          conversation.unreadCount > 99 ? '99+' : '${conversation.unreadCount}',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
