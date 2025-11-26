import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_styles.dart';
import '../../data/models/conversation_model.dart';

/// Conversation Card Widget - Enhanced WhatsApp Style
///
/// Displays a conversation item in the chat list with slide actions
class ConversationCard extends StatefulWidget {
  final ConversationModel conversation;
  final int currentUserId;
  final VoidCallback onTap;
  final VoidCallback? onArchive;
  final VoidCallback? onDelete;
  final VoidCallback? onPin;
  final int index;

  const ConversationCard({
    super.key,
    required this.conversation,
    required this.currentUserId,
    required this.onTap,
    this.onArchive,
    this.onDelete,
    this.onPin,
    this.index = 0,
  });

  @override
  State<ConversationCard> createState() => _ConversationCardState();
}

class _ConversationCardState extends State<ConversationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300 + (widget.index * 50)),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Dismissible(
          key: Key('conversation_${widget.conversation.id}'),
          direction: DismissDirection.endToStart,
          background: _buildDismissBackground(isDark),
          confirmDismiss: (direction) async {
            return await _showActionSheet(context, isDark);
          },
          child: InkWell(
            onTap: widget.onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2A2D3E) : Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? const Color(0xFF1C1E2B) : const Color(0xFFE5E7EB),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Avatar with Online Status
                  _buildAvatarWithStatus(isDark),

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
                                widget.conversation.participantName,
                                style: AppTextStyles.titleMedium.copyWith(
                                  color: isDark ? Colors.white : const Color(0xFF1F2937),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.conversation.formattedTime,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: widget.conversation.hasUnreadMessages
                                    ? (isDark ? AppColors.darkAccent : AppColors.accent)
                                    : (isDark ? const Color(0xFF8F92A1) : const Color(0xFF6B7280)),
                                fontSize: 13,
                                fontWeight: widget.conversation.hasUnreadMessages
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),

                        // Last Message and Badge
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // For groups: show participants count
                                  if (widget.conversation.isGroup &&
                                      widget.conversation.participantsCount != null) ...[
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Icon(
                                        Icons.people,
                                        size: 14,
                                        color: isDark
                                            ? AppColors.darkTextSecondary
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${widget.conversation.participantsCount} • ',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: isDark
                                            ? AppColors.darkTextSecondary
                                            : AppColors.textSecondary,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                  // Last message preview - show 2 lines for unread
                                  Expanded(
                                    child: Text(
                                      widget.conversation.lastMessagePreview,
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: widget.conversation.hasUnreadMessages
                                            ? (isDark ? Colors.white : const Color(0xFF1F2937))
                                            : (isDark ? const Color(0xFF8F92A1) : const Color(0xFF6B7280)),
                                        fontSize: 14,
                                        fontWeight: widget.conversation.hasUnreadMessages
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                      ),
                                      maxLines: widget.conversation.hasUnreadMessages ? 2 : 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (widget.conversation.hasUnreadMessages) ...[
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
          ),
        ),
      ),
    );
  }

  /// Build Dismiss Background (Swipe Actions)
  Widget _buildDismissBackground(bool isDark) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.red.withValues(alpha: 0.8),
            Colors.red,
          ],
        ),
      ),
      child: const Icon(
        Icons.delete_outline,
        color: Colors.white,
        size: 28,
      ),
    );
  }

  /// Show Action Sheet
  Future<bool?> _showActionSheet(BuildContext context, bool isDark) async {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Conversation Options',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: isDark ? AppColors.darkTextPrimary : null,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const Divider(height: 1),

              // Actions
              ListTile(
                leading: Icon(
                  Icons.push_pin_outlined,
                  color: isDark ? AppColors.darkAccent : AppColors.accent,
                ),
                title: Text(
                  'Pin Conversation',
                  style: TextStyle(
                    color:
                        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context, false);
                  widget.onPin?.call();
                },
              ),

              ListTile(
                leading: Icon(
                  Icons.archive_outlined,
                  color: isDark ? AppColors.darkAccent : AppColors.accent,
                ),
                title: Text(
                  'Archive',
                  style: TextStyle(
                    color:
                        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context, false);
                  widget.onArchive?.call();
                },
              ),

              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text(
                  'Delete Conversation',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context, true);
                  widget.onDelete?.call();
                },
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  /// Build Avatar with Online Status
  Widget _buildAvatarWithStatus(bool isDark) {
    // For groups: show group icon
    if (widget.conversation.isGroup) {
      return Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _getAvatarColor(widget.conversation.participantName),
        ),
        child: Icon(
          Icons.group,
          color: AppColors.white,
          size: 28,
        ),
      );
    }

    // For private chats: show user avatar with online status
    return Stack(
      children: [
        // Avatar
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _getAvatarColor(widget.conversation.participantName),
          ),
          child: widget.conversation.participantAvatar != null
              ? ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: widget.conversation.participantAvatar!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    ),
                    errorWidget: (context, url, error) =>
                        _buildAvatarPlaceholder(),
                  ),
                )
              : _buildAvatarPlaceholder(),
        ),

        // Online Status Indicator (only for private chats)
        if (widget.conversation.isOnline)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? AppColors.darkCard : AppColors.white,
                  width: 2.5,
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Build Avatar Placeholder
  Widget _buildAvatarPlaceholder() {
    final initials = widget.conversation.participantName
        .split(' ')
        .take(2)
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() : '')
        .join();

    return Center(
      child: Text(
        initials,
        style: AppTextStyles.titleLarge.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Get Avatar Color based on name (WhatsApp Style - Simple solid colors)
  Color _getAvatarColor(String name) {
    // WhatsApp-style simple colors
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
          widget.conversation.unreadCount > 99
              ? '99+'
              : '${widget.conversation.unreadCount}',
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
