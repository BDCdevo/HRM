import 'package:flutter/material.dart';
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
  final VoidCallback? onTap;
  final bool isDark;

  const ChatAppBarWidget({
    super.key,
    required this.participantName,
    this.participantAvatar,
    this.isGroupChat = false,
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
                          : 'Tap to view profile',
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
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isGroupChat ? 'Group info' : 'View profile',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
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
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Mute notifications',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
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
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Clear chat',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
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
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.white.withOpacity(0.2),
      ),
      child: Center(
        child: isGroupChat
            ? const Icon(
                Icons.group,
                color: AppColors.white,
                size: 20,
              )
            : Text(
                participantName.isNotEmpty
                    ? participantName[0].toUpperCase()
                    : '?',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
