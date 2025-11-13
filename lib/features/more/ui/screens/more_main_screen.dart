import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_styles.dart';
import '../../../../core/theme/cubit/theme_cubit.dart';
import '../../../auth/logic/cubit/auth_cubit.dart';
import '../../../auth/logic/cubit/auth_state.dart';
import '../../../auth/ui/screens/user_type_selection_screen.dart';

/// More Main Screen
///
/// Hub for Reports, Work Schedule, Profile, and Settings
class MoreMainScreen extends StatelessWidget {
  const MoreMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeCubit>().isDarkMode;
    final backgroundColor = isDarkMode ? AppColors.darkBackground : AppColors.background;
    final cardColor = isDarkMode ? AppColors.darkCard : AppColors.surface;
    final textColor = isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final secondaryTextColor = isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is! AuthAuthenticated) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = state.user;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Header with Profile
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDarkMode
                        ? [
                            AppColors.darkAppBar,
                            AppColors.darkCard,
                          ]
                        : [
                            AppColors.primary,
                            AppColors.primaryLight,
                          ],
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        // Profile Avatar
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.white.withOpacity(0.3),
                              width: 3,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              user.firstName.isNotEmpty
                                  ? user.firstName[0].toUpperCase()
                                  : 'U',
                              style: AppTextStyles.displaySmall.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Name
                        Text(
                          user.fullName,
                          style: AppTextStyles.headlineMedium.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 4),

                        // Email
                        Text(
                          user.email,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.white.withOpacity(0.9),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // User Type Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            user.isAdmin ? 'Administrator' : 'Employee',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Menu Items
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Reports & Analytics Section
                      _SectionHeader(title: 'Reports & Analytics', textColor: secondaryTextColor),
                      const SizedBox(height: 12),
                      _MenuItem(
                        icon: Icons.assessment,
                        title: 'Monthly Report',
                        subtitle: 'View your monthly work report',
                        color: AppColors.info,
                        cardColor: cardColor,
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                        onTap: () {
                          // TODO: Navigate to monthly report
                        },
                      ),
                      const SizedBox(height: 8),
                      _MenuItem(
                        icon: Icons.calendar_today,
                        title: 'Work Schedule',
                        subtitle: 'View your work schedule',
                        color: AppColors.primary,
                        cardColor: cardColor,
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                        onTap: () {
                          // TODO: Navigate to work schedule
                        },
                      ),

                      const SizedBox(height: 24),

                      // Account Section
                      _SectionHeader(title: 'Account', textColor: secondaryTextColor),
                      const SizedBox(height: 12),
                      _MenuItem(
                        icon: Icons.person,
                        title: 'My Profile',
                        subtitle: 'View and edit your profile',
                        color: AppColors.secondary,
                        cardColor: cardColor,
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                        onTap: () {
                          // TODO: Navigate to profile
                        },
                      ),
                      const SizedBox(height: 8),
                      _MenuItem(
                        icon: Icons.notifications,
                        title: 'Notifications',
                        subtitle: 'Manage your notifications',
                        color: AppColors.warning,
                        cardColor: cardColor,
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                        badge: '3',
                        onTap: () {
                          // TODO: Navigate to notifications
                        },
                      ),

                      const SizedBox(height: 24),

                      // Settings Section
                      _SectionHeader(title: 'Settings', textColor: secondaryTextColor),
                      const SizedBox(height: 12),
                      _MenuItem(
                        icon: Icons.lock,
                        title: 'Change Password',
                        subtitle: 'Update your password',
                        color: AppColors.textSecondary,
                        cardColor: cardColor,
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                        onTap: () {
                          // TODO: Navigate to change password
                        },
                      ),
                      const SizedBox(height: 8),
                      _MenuItem(
                        icon: Icons.language,
                        title: 'Language',
                        subtitle: 'English',
                        color: AppColors.info,
                        cardColor: cardColor,
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                        onTap: () {
                          // TODO: Show language selector
                        },
                      ),
                      const SizedBox(height: 8),
                      _MenuItem(
                        icon: Icons.help_outline,
                        title: 'Help & Support',
                        subtitle: 'Get help and support',
                        color: AppColors.primary,
                        cardColor: cardColor,
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                        onTap: () {
                          // TODO: Navigate to help
                        },
                      ),
                      const SizedBox(height: 8),
                      _MenuItem(
                        icon: Icons.info_outline,
                        title: 'About',
                        subtitle: 'Version 1.0.0',
                        color: AppColors.textSecondary,
                        cardColor: cardColor,
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                        onTap: () {
                          // TODO: Show about dialog
                        },
                      ),

                      const SizedBox(height: 24),

                      // Logout Button
                      _MenuItem(
                        icon: Icons.logout,
                        title: 'Logout',
                        subtitle: 'Sign out from your account',
                        color: AppColors.error,
                        cardColor: cardColor,
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                        onTap: () {
                          _showLogoutDialog(context);
                        },
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Show Logout Dialog
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Logout
              context.read<AuthCubit>().logout();

              // Navigate to login
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const UserTypeSelectionScreen(),
                ),
                (route) => false,
              );
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

/// Section Header
class _SectionHeader extends StatelessWidget {
  final String title;
  final Color textColor;

  const _SectionHeader({required this.title, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: AppTextStyles.titleMedium.copyWith(
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

/// Menu Item
class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color cardColor;
  final Color textColor;
  final Color secondaryTextColor;
  final String? badge;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.cardColor,
    required this.textColor,
    required this.secondaryTextColor,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),

              const SizedBox(width: 16),

              // Title & Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),

              // Badge
              if (badge != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badge!,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],

              // Arrow
              Icon(
                Icons.chevron_right,
                color: AppColors.iconSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
