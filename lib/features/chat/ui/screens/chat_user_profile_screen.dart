import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_styles.dart';
import 'package:url_launcher/url_launcher.dart';

/// Chat User Profile Screen
///
/// Displays user profile information when tapping on chat header
/// Similar to WhatsApp contact info screen
class ChatUserProfileScreen extends StatelessWidget {
  final int userId;
  final String userName;
  final String? userAvatar;
  final String? userEmail;
  final String? userPhone;
  final String? userDepartment;
  final String? userPosition;
  final bool isOnline;

  const ChatUserProfileScreen({
    super.key,
    required this.userId,
    required this.userName,
    this.userAvatar,
    this.userEmail,
    this.userPhone,
    this.userDepartment,
    this.userPosition,
    this.isOnline = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar with Avatar
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: isDark ? AppColors.darkCard : AppColors.primary,
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
                    colors: isDark
                        ? [AppColors.darkCard, AppColors.darkCardElevated]
                        : [AppColors.primary, AppColors.primaryLight],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    // Avatar
                    Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.white,
                              width: 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: userAvatar != null && userAvatar!.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: userAvatar!,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      color: AppColors.primary,
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          color: AppColors.white,
                                        ),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        _buildAvatarPlaceholder(),
                                  )
                                : _buildAvatarPlaceholder(),
                          ),
                        ),
                        // Online indicator
                        if (isOnline)
                          Positioned(
                            right: 8,
                            bottom: 8,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: AppColors.success,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.white,
                                  width: 3,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Name
                    Text(
                      userName,
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Status
                    Text(
                      isOnline ? 'Online' : 'Offline',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 8),

                // About Section
                _buildSection(
                  context,
                  isDark,
                  title: 'About',
                  children: [
                    if (userPosition != null)
                      _buildInfoTile(
                        context,
                        isDark,
                        icon: Icons.work_outline,
                        title: 'Position',
                        value: userPosition!,
                      ),
                    if (userDepartment != null)
                      _buildInfoTile(
                        context,
                        isDark,
                        icon: Icons.business_outlined,
                        title: 'Department',
                        value: userDepartment!,
                      ),
                  ],
                ),

                const SizedBox(height: 8),

                // Contact Section
                _buildSection(
                  context,
                  isDark,
                  title: 'Contact Info',
                  children: [
                    if (userEmail != null)
                      _buildInfoTile(
                        context,
                        isDark,
                        icon: Icons.email_outlined,
                        title: 'Email',
                        value: userEmail!,
                        onTap: () => _launchEmail(userEmail!),
                      ),
                    if (userPhone != null)
                      _buildInfoTile(
                        context,
                        isDark,
                        icon: Icons.phone_outlined,
                        title: 'Phone',
                        value: userPhone!,
                        onTap: () => _launchPhone(userPhone!),
                      ),
                  ],
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarPlaceholder() {
    final initials = userName
        .split(' ')
        .take(2)
        .map((e) => e.isNotEmpty ? e[0] : '')
        .join()
        .toUpperCase();

    return Container(
      color: AppColors.primary,
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    bool isDark, {
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: AppTextStyles.titleMedium.copyWith(
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoTile(
    BuildContext context,
    bool isDark, {
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
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
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.chevron_right,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _launchPhone(String phone) async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: phone,
    );
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }
}
