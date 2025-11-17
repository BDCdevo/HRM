import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_styles.dart';
import '../../data/repo/chat_repository.dart';
import '../../logic/cubit/chat_cubit.dart';
import '../../logic/cubit/chat_state.dart';
import 'chat_room_screen.dart';

/// Group Creation Screen
///
/// Step 2 of group creation: Enter group name and optional avatar
class GroupCreationScreen extends StatelessWidget {
  final int companyId;
  final int currentUserId;
  final List<int> selectedEmployeeIds;
  final Map<int, String> selectedEmployeeNames;

  const GroupCreationScreen({
    super.key,
    required this.companyId,
    required this.currentUserId,
    required this.selectedEmployeeIds,
    required this.selectedEmployeeNames,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatCubit(ChatRepository()),
      child: _GroupCreationView(
        companyId: companyId,
        currentUserId: currentUserId,
        selectedEmployeeIds: selectedEmployeeIds,
        selectedEmployeeNames: selectedEmployeeNames,
      ),
    );
  }
}

class _GroupCreationView extends StatefulWidget {
  final int companyId;
  final int currentUserId;
  final List<int> selectedEmployeeIds;
  final Map<int, String> selectedEmployeeNames;

  const _GroupCreationView({
    required this.companyId,
    required this.currentUserId,
    required this.selectedEmployeeIds,
    required this.selectedEmployeeNames,
  });

  @override
  State<_GroupCreationView> createState() => _GroupCreationViewState();
}

class _GroupCreationViewState extends State<_GroupCreationView>
    with SingleTickerProviderStateMixin {
  final TextEditingController _groupNameController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  File? _groupAvatar;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// Pick group avatar from gallery
  Future<void> _pickGroupAvatar() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _groupAvatar = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Remove group avatar
  void _removeGroupAvatar() {
    setState(() {
      _groupAvatar = null;
    });
  }

  /// Create group
  void _createGroup() {
    final groupName = _groupNameController.text.trim();

    if (groupName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a group name'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Create group conversation
    context.read<ChatCubit>().createConversation(
          companyId: widget.companyId,
          userIds: widget.selectedEmployeeIds,
          type: 'group',
          name: groupName,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: _buildAppBar(isDark),
      body: BlocConsumer<ChatCubit, ChatState>(
        listener: (context, state) {
          if (state is ConversationCreated) {
            // Navigate to chat room after creating group
            Navigator.of(context).popUntil((route) => route.isFirst);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ChatRoomScreen(
                  conversationId: state.conversationId,
                  participantName: _groupNameController.text.trim(),
                  companyId: widget.companyId,
                  currentUserId: widget.currentUserId,
                ),
              ),
            );
          }

          if (state is ConversationCreateError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is ConversationCreating;

          return FadeTransition(
            opacity: _animationController,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Group Avatar Section
                        _buildGroupAvatarSection(isDark),

                        const SizedBox(height: 24),

                        // Group Name Section
                        _buildGroupNameSection(isDark),

                        const SizedBox(height: 24),

                        // Selected Members Section
                        _buildSelectedMembersSection(isDark),
                      ],
                    ),
                  ),
                ),

                // Create Group Button
                _buildCreateButton(isDark, isLoading),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Build App Bar
  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      backgroundColor: isDark ? AppColors.darkAppBar : AppColors.primary,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'New Group',
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'Add subject',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// Build Group Avatar Section
  Widget _buildGroupAvatarSection(bool isDark) {
    return Center(
      child: Stack(
        children: [
          // Avatar
          GestureDetector(
            onTap: _pickGroupAvatar,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (isDark ? AppColors.darkCard : AppColors.white),
                border: Border.all(
                  color: (isDark ? AppColors.darkBorder : AppColors.border)
                      .withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _groupAvatar != null
                  ? ClipOval(
                      child: Image.file(
                        _groupAvatar!,
                        fit: BoxFit.cover,
                        width: 120,
                        height: 120,
                      ),
                    )
                  : Icon(
                      Icons.group,
                      size: 50,
                      color: (isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary)
                          .withOpacity(0.5),
                    ),
            ),
          ),

          // Camera button
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _groupAvatar != null ? _removeGroupAvatar : _pickGroupAvatar,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? AppColors.darkAccent : AppColors.accent,
                  border: Border.all(
                    color: isDark ? AppColors.darkBackground : AppColors.background,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  _groupAvatar != null ? Icons.close : Icons.camera_alt,
                  color: AppColors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build Group Name Section
  Widget _buildGroupNameSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Group Name',
          style: AppTextStyles.titleMedium.copyWith(
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: (isDark ? AppColors.darkBorder : AppColors.border)
                  .withOpacity(0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _groupNameController,
            style: TextStyle(
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: 'Enter group name',
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
              prefixIcon: Icon(
                Icons.edit,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            maxLength: 50,
            textCapitalization: TextCapitalization.words,
          ),
        ),
      ],
    );
  }

  /// Build Selected Members Section
  Widget _buildSelectedMembersSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Members',
              style: AppTextStyles.titleMedium.copyWith(
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.darkAccent : AppColors.accent)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${widget.selectedEmployeeIds.length}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: isDark ? AppColors.darkAccent : AppColors.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: (isDark ? AppColors.darkBorder : AppColors.border)
                  .withOpacity(0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.selectedEmployeeNames.entries
                .map((entry) => _buildMemberChip(entry.value, isDark))
                .toList(),
          ),
        ),
      ],
    );
  }

  /// Build Member Chip
  Widget _buildMemberChip(String name, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.darkAccent : AppColors.accent)
            .withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (isDark ? AppColors.darkAccent : AppColors.accent)
              .withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? AppColors.darkAccent : AppColors.accent,
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            name,
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Build Create Button
  Widget _buildCreateButton(bool isDark, bool isLoading) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : _createGroup,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? AppColors.darkAccent : AppColors.accent,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Create Group',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
