import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_styles.dart';

/// Chat App Bar Widget - WhatsApp Style
///
/// Displays the participant name, avatar, and actions
/// Used in ChatRoomScreen
class ChatAppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String participantName;
  final String? participantAvatar;
  final bool isGroupChat;
  final bool isOnline;
  final VoidCallback? onTap;
  final bool isDark;

  const ChatAppBarWidget({
    super.key,
    required this.participantName,
    this.participantAvatar,
    this.isGroupChat = false,
    this.isOnline = false,
    this.onTap,
    required this.isDark,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: isDark ? AppColors.darkAppBar : AppColors.primary,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              // Avatar (Group icon or User initial)
              _buildAvatar(),
              const SizedBox(width: 12),

              // Name and subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      participantName,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      isGroupChat
                          ? 'Tap for group info'
                          : (isOnline ? 'Online' : 'Tap to view profile'),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isOnline
                            ? const Color(0xFF4ADE80) // Green for online
                            : AppColors.white.withOpacity(0.8),
                        fontSize: 12,
                        fontWeight: isOnline ? FontWeight.w500 : FontWeight.normal,
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
        // Video call button (optional - can be enabled later)
        // IconButton(
        //   icon: const Icon(Icons.videocam, color: AppColors.white),
        //   onPressed: () {},
        // ),

        // Voice call button (optional - can be enabled later)
        // IconButton(
        //   icon: const Icon(Icons.call, color: AppColors.white),
        //   onPressed: () {},
        // ),

        // More options
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: AppColors.white),
          onSelected: (value) {
            // Handle menu actions
            switch (value) {
              case 'view_profile':
                if (onTap != null) onTap!();
                break;
              case 'mute':
                // TODO: Implement mute
                break;
              case 'clear_chat':
                // TODO: Implement clear chat
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'view_profile',
              child: Row(
                children: [
                  Icon(
                    isGroupChat ? Icons.info : Icons.person,
                    size: 20,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isGroupChat ? 'Group info' : 'View profile',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'mute',
              child: Row(
                children: [
                  Icon(
                    Icons.notifications_off,
                    size: 20,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Mute notifications',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'clear_chat',
              child: Row(
                children: [
                  Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Clear chat',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build Avatar Widget
  Widget _buildAvatar() {
    // For groups: show group icon
    if (isGroupChat) {
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.white.withOpacity(0.2),
        ),
        child: const Icon(Icons.group, color: AppColors.white, size: 20),
      );
    }

    // For private chats: show user avatar with online indicator
    return Stack(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _getAvatarColor(participantName),
            border: Border.all(color: AppColors.white.withOpacity(0.3), width: 1.5),
          ),
          child: participantAvatar != null && participantAvatar!.isNotEmpty
              ? ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: participantAvatar!,
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
        ),
        // Online indicator dot
        if (isOnline)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E), // Green
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? AppColors.darkAppBar : AppColors.primary,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Build Avatar Placeholder (Initials)
  Widget _buildAvatarPlaceholder() {
    final initials = participantName
        .split(' ')
        .take(2)
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() : '')
        .join();

    return Center(
      child: Text(
        initials.isEmpty ? '?' : initials,
        style: AppTextStyles.titleSmall.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Get Avatar Color based on name (consistent with message bubbles)
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
}
