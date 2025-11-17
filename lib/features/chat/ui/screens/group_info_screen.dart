import 'package:flutter/material.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_styles.dart';

/// Group Info Screen
///
/// Displays group information, members list, and group actions
class GroupInfoScreen extends StatelessWidget {
  final int conversationId;
  final String groupName;
  final String? groupAvatar;
  final int participantsCount;
  final int companyId;
  final int currentUserId;

  const GroupInfoScreen({
    super.key,
    required this.conversationId,
    required this.groupName,
    this.groupAvatar,
    required this.participantsCount,
    required this.companyId,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    return _GroupInfoView(
      conversationId: conversationId,
      groupName: groupName,
      groupAvatar: groupAvatar,
      participantsCount: participantsCount,
      companyId: companyId,
      currentUserId: currentUserId,
    );
  }
}

class _GroupInfoView extends StatefulWidget {
  final int conversationId;
  final String groupName;
  final String? groupAvatar;
  final int participantsCount;
  final int companyId;
  final int currentUserId;

  const _GroupInfoView({
    required this.conversationId,
    required this.groupName,
    this.groupAvatar,
    required this.participantsCount,
    required this.companyId,
    required this.currentUserId,
  });

  @override
  State<_GroupInfoView> createState() => _GroupInfoViewState();
}

class _GroupInfoViewState extends State<_GroupInfoView> {
  bool _isMuted = false;

  // Mock participants data (في المستقبل سيتم جلبها من API)
  final List<Map<String, dynamic>> _participants = [
    {'id': 27, 'name': 'Ahmed Mohamed', 'department': 'التطوير', 'isAdmin': true},
    {'id': 30, 'name': 'Hany Youssef', 'department': 'التصميم', 'isAdmin': false},
    {'id': 35, 'name': 'Sara Ali', 'department': 'التسويق', 'isAdmin': false},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar with Group Avatar
          _buildSliverAppBar(isDark),

          // Group Info Section
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 8),
                _buildGroupNameSection(isDark),
                const SizedBox(height: 8),
                _buildMembersCountSection(isDark),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // Actions Section
          SliverToBoxAdapter(
            child: _buildActionsSection(isDark),
          ),

          // Members Section Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Row(
                children: [
                  Text(
                    '${_participants.length} participants',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Members List
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildMemberTile(_participants[index], isDark),
              childCount: _participants.length,
            ),
          ),

          // Leave Group Button
          SliverToBoxAdapter(
            child: _buildLeaveGroupButton(isDark),
          ),

          // Bottom Padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 32),
          ),
        ],
      ),
    );
  }

  /// Build Sliver App Bar with Group Avatar
  Widget _buildSliverAppBar(bool isDark) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: isDark ? AppColors.darkAppBar : AppColors.primary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                isDark ? AppColors.darkAppBar : AppColors.primary,
                (isDark ? AppColors.darkAppBar : AppColors.primary)
                    .withOpacity(0.8),
              ],
            ),
          ),
          child: Center(
            child: Hero(
              tag: 'group_avatar_${widget.conversationId}',
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white.withOpacity(0.2),
                  border: Border.all(
                    color: AppColors.white.withOpacity(0.3),
                    width: 3,
                  ),
                ),
                child: const Icon(
                  Icons.group,
                  size: 60,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build Group Name Section
  Widget _buildGroupNameSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Text(
            widget.groupName,
            style: AppTextStyles.titleLarge.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 24,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Group · ${widget.participantsCount} members',
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

  /// Build Members Count Section
  Widget _buildMembersCountSection(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: (isDark ? AppColors.darkAccent : AppColors.accent)
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.group,
              color: isDark ? AppColors.darkAccent : AppColors.accent,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Members',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.participantsCount} people in this group',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build Actions Section
  Widget _buildActionsSection(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildActionTile(
            icon: Icons.image,
            title: 'Media, Links, and Docs',
            subtitle: '${_participants.length * 5} items',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Media gallery - Coming soon')),
              );
            },
            isDark: isDark,
          ),
          Divider(
            height: 1,
            color: (isDark ? AppColors.darkBorder : AppColors.border)
                .withOpacity(0.3),
          ),
          _buildActionTile(
            icon: _isMuted ? Icons.notifications_off : Icons.notifications,
            title: 'Mute notifications',
            subtitle: _isMuted ? 'Muted' : 'Not muted',
            trailing: Switch(
              value: _isMuted,
              onChanged: (value) {
                setState(() {
                  _isMuted = value;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      value
                          ? 'Notifications muted'
                          : 'Notifications enabled',
                    ),
                  ),
                );
              },
              activeColor: isDark ? AppColors.darkAccent : AppColors.accent,
            ),
            onTap: null,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  /// Build Action Tile
  Widget _buildActionTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    required bool isDark,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (isDark ? AppColors.darkAccent : AppColors.accent)
              .withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isDark ? AppColors.darkAccent : AppColors.accent,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(
          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            )
          : null,
      trailing: trailing ??
          (onTap != null
              ? Icon(
                  Icons.chevron_right,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                )
              : null),
      onTap: onTap,
    );
  }

  /// Build Member Tile
  Widget _buildMemberTile(Map<String, dynamic> member, bool isDark) {
    final isAdmin = member['isAdmin'] as bool? ?? false;
    final name = member['name'] as String;
    final department = member['department'] as String? ?? '';

    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: (isDark ? AppColors.darkAccent : AppColors.accent)
              .withOpacity(0.1),
        ),
        child: Center(
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: AppTextStyles.titleMedium.copyWith(
              color: isDark ? AppColors.darkAccent : AppColors.accent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
      title: Row(
        children: [
          Flexible(
            child: Text(
              name,
              style: AppTextStyles.bodyLarge.copyWith(
                color:
                    isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isAdmin) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.darkAccent : AppColors.accent)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Admin',
                style: AppTextStyles.bodySmall.copyWith(
                  color: isDark ? AppColors.darkAccent : AppColors.accent,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
      subtitle: department.isNotEmpty
          ? Text(
              department,
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            )
          : null,
      trailing: member['id'] != widget.currentUserId
          ? PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
              onSelected: (value) {
                if (value == 'message') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Message $name')),
                  );
                } else if (value == 'view_profile') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('View ${name}\'s profile')),
                  );
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'message',
                  child: Row(
                    children: [
                      Icon(Icons.message),
                      SizedBox(width: 8),
                      Text('Message'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'view_profile',
                  child: Row(
                    children: [
                      Icon(Icons.person),
                      SizedBox(width: 8),
                      Text('View profile'),
                    ],
                  ),
                ),
              ],
            )
          : null,
    );
  }

  /// Build Leave Group Button
  Widget _buildLeaveGroupButton(bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: OutlinedButton.icon(
        onPressed: () {
          _showLeaveGroupDialog();
        },
        icon: const Icon(Icons.exit_to_app, color: AppColors.error),
        label: const Text(
          'Leave Group',
          style: TextStyle(
            color: AppColors.error,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: const BorderSide(color: AppColors.error, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  /// Show Leave Group Confirmation Dialog
  void _showLeaveGroupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Group?'),
        content: Text(
          'Are you sure you want to leave "${widget.groupName}"? You will no longer receive messages from this group.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close group info
              Navigator.pop(context); // Close chat room
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Left "${widget.groupName}"'),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            child: const Text(
              'Leave',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
