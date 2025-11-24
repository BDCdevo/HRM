import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_styles.dart';
import '../../../../core/theme/cubit/theme_cubit.dart';
import '../../../auth/logic/cubit/auth_cubit.dart';
import '../../../auth/logic/cubit/auth_state.dart';
import '../../../auth/ui/screens/login_screen.dart';
import '../../../profile/ui/screens/change_password_screen.dart';
import '../../../profile/ui/screens/edit_profile_screen.dart';
import '../../../profile/logic/cubit/profile_cubit.dart';
import '../../../profile/logic/cubit/profile_state.dart';
import '../../../holidays/ui/screens/holidays_screen.dart';
import '../../../work_schedule/ui/screens/work_schedule_screen.dart';
import '../../../requests/ui/screens/requests_main_screen.dart';

/// More Main Screen - With Full Profile
///
/// Hub for Profile, Reports, Work Schedule, and Settings
/// Now shows complete profile information with image upload
class MoreMainScreen extends StatefulWidget {
  const MoreMainScreen({super.key});

  @override
  State<MoreMainScreen> createState() => _MoreMainScreenState();
}

class _MoreMainScreenState extends State<MoreMainScreen> {
  late final ProfileCubit _profileCubit;

  @override
  void initState() {
    super.initState();
    _profileCubit = ProfileCubit();
    _profileCubit.fetchProfile();
  }

  @override
  void dispose() {
    _profileCubit.close();
    super.dispose();
  }

  /// Navigate to Edit Profile Screen (In-App)
  void _navigateToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EditProfileScreen(),
      ),
    ).then((_) {
      // Refresh profile when returning from edit screen
      _profileCubit.fetchProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeCubit>().isDarkMode;
    final backgroundColor = isDarkMode ? AppColors.darkBackground : AppColors.background;
    final cardColor = isDarkMode ? AppColors.darkCard : AppColors.surface;
    final textColor = isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final secondaryTextColor = isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return BlocProvider(
      create: (context) => _profileCubit,
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: BlocConsumer<ProfileCubit, ProfileState>(
          listener: (context, state) {
            if (state is ProfileImageUploaded) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.success,
                ),
              );
            } else if (state is ProfileError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.displayMessage),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, profileState) {
            return BlocBuilder<AuthCubit, AuthState>(
              builder: (context, authState) {
                if (authState is! AuthAuthenticated) {
                  return const Center(child: CircularProgressIndicator());
                }

                final user = authState.user;

                // Get profile from ProfileCubit if loaded
                final profile = profileState is ProfileLoaded
                    ? profileState.profile
                    : null;

                return RefreshIndicator(
                  onRefresh: () async {
                    await _profileCubit.fetchProfile();
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        // Header with Profile Image
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
                                // Profile Avatar with Upload Button
                                Stack(
                                  children: [
                                    Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color: AppColors.white.withOpacity(0.2),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.white.withOpacity(0.3),
                                          width: 3,
                                        ),
                                      ),
                                      child: ClipOval(
                                        child: user.image != null && user.image!.url.isNotEmpty
                                            ? Image.network(
                                                // Add timestamp to bypass cache
                                                '${user.image!.url}?v=${DateTime.now().millisecondsSinceEpoch}',
                                                fit: BoxFit.cover,
                                                loadingBuilder: (context, child, loadingProgress) {
                                                  if (loadingProgress == null) return child;
                                                  return Center(
                                                    child: CircularProgressIndicator(
                                                      value: loadingProgress.expectedTotalBytes != null
                                                          ? loadingProgress.cumulativeBytesLoaded /
                                                              loadingProgress.expectedTotalBytes!
                                                          : null,
                                                      color: AppColors.white,
                                                    ),
                                                  );
                                                },
                                                errorBuilder: (context, error, stackTrace) {
                                                  print('❌ Image load error: $error');
                                                  return Center(
                                                    child: Text(
                                                      user.firstName.isNotEmpty
                                                          ? user.firstName[0].toUpperCase()
                                                          : 'U',
                                                      style: AppTextStyles.displayLarge.copyWith(
                                                        color: AppColors.white,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              )
                                            : Center(
                                                child: Text(
                                                  user.firstName.isNotEmpty
                                                      ? user.firstName[0].toUpperCase()
                                                      : 'U',
                                                  style: AppTextStyles.displayLarge.copyWith(
                                                    color: AppColors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                      ),
                                    ),
                                    // Upload Button
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: GestureDetector(
                                        onTap: () => _showImageSourceDialog(context),
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: AppColors.accent,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: AppColors.white,
                                              width: 2,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.2),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.camera_alt,
                                            size: 20,
                                            color: AppColors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                // Name
                                Text(
                                  user.fullName,
                                  style: AppTextStyles.headlineMedium.copyWith(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
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

                                // Bio if available
                                if (profile?.bio != null && profile!.bio!.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      profile.bio!,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.white.withOpacity(0.9),
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),

                        // Menu Items
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              // Account Section
                              _SectionHeader(title: 'Account', textColor: secondaryTextColor),
                              const SizedBox(height: 12),
                              _MenuItem(
                                svgIcon: 'assets/svgs/profile_icon.svg',
                                title: 'Edit Profile',
                                subtitle: 'Update your personal information',
                                color: AppColors.secondary,
                                cardColor: cardColor,
                                textColor: textColor,
                                secondaryTextColor: secondaryTextColor,
                                onTap: _navigateToEditProfile,
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

                              // Requests Section
                              _SectionHeader(title: 'Requests', textColor: secondaryTextColor),
                              const SizedBox(height: 12),
                              _MenuItem(
                                icon: Icons.assignment,
                                title: 'Requests',
                                subtitle: 'Submit and manage various requests',
                                color: AppColors.accent,
                                cardColor: cardColor,
                                textColor: textColor,
                                secondaryTextColor: secondaryTextColor,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const RequestsMainScreen(),
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(height: 24),

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
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const WorkScheduleScreen(),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 8),
                              _MenuItem(
                                icon: Icons.event_note,
                                title: 'Official Holidays',
                                subtitle: 'View official holidays and vacations',
                                color: AppColors.accent,
                                cardColor: cardColor,
                                textColor: textColor,
                                secondaryTextColor: secondaryTextColor,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const HolidaysScreen(),
                                    ),
                                  );
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
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const ChangePasswordScreen(),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 8),
                              _MenuItem(
                                icon: isDarkMode ? Icons.light_mode : Icons.dark_mode,
                                title: 'Theme',
                                subtitle: isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                                color: AppColors.info,
                                cardColor: cardColor,
                                textColor: textColor,
                                secondaryTextColor: secondaryTextColor,
                                onTap: () {
                                  context.read<ThemeCubit>().toggleTheme();
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
                                subtitle: 'Version 1.1.0+10',
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
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  /// Show Image Source Dialog (Camera or Gallery)
  void _showImageSourceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bottomSheetContext) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                'Upload Profile Picture',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              // Camera Option
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: AppColors.accent,
                  ),
                ),
                title: Text(
                  'Take Photo',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _pickImage(ImageSource.camera);
                },
              ),
              const SizedBox(height: 8),
              // Gallery Option
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.photo_library,
                    color: AppColors.primary,
                  ),
                ),
                title: Text(
                  'Choose from Gallery',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _pickImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  /// Pick Image from Camera or Gallery
  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        // Upload the image
        _profileCubit.uploadProfileImage(File(image.path));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: ${e.toString()}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
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
                  builder: (context) => const LoginScreen(),
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
  final IconData? icon;
  final String? svgIcon;
  final String title;
  final String subtitle;
  final Color color;
  final Color cardColor;
  final Color textColor;
  final Color secondaryTextColor;
  final String? badge;
  final VoidCallback onTap;

  const _MenuItem({
    this.icon,
    this.svgIcon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.cardColor,
    required this.textColor,
    required this.secondaryTextColor,
    this.badge,
    required this.onTap,
  }) : assert(icon != null || svgIcon != null, 'Either icon or svgIcon must be provided');

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
                child: svgIcon != null
                    ? SvgPicture.asset(
                        svgIcon!,
                        width: 24,
                        height: 24,
                        colorFilter: ColorFilter.mode(
                          color,
                          BlendMode.srcIn,
                        ),
                      )
                    : Icon(
                        icon!,
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
