import 'dart:io';
import 'dart:math' as math;
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
import '../../../profile/data/models/profile_model.dart';
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
              // Refresh AuthCubit to update user image across the app
              context.read<AuthCubit>().refreshUserProfile();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white, size: 20),
                      const SizedBox(width: 12),
                      Text(state.message),
                    ],
                  ),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  margin: const EdgeInsets.all(16),
                ),
              );
            } else if (state is ProfileError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.white, size: 20),
                      const SizedBox(width: 12),
                      Expanded(child: Text(state.displayMessage)),
                    ],
                  ),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  margin: const EdgeInsets.all(16),
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
                        // Header with Profile Image & Completion Ring
                        _buildProfileHeader(
                          context: context,
                          user: user,
                          profile: profile,
                          isDarkMode: isDarkMode,
                          onImageTap: () => _showImageSourceDialog(context),
                          onEditTap: _navigateToEditProfile,
                        ),

                        // Quick Stats Cards (outside header)
                        Transform.translate(
                          offset: const Offset(0, -20),
                          child: _buildQuickStats(
                            profile,
                            isDarkMode,
                            _calculateProfileCompletion(profile, user),
                          ),
                        ),

                        // Menu Items
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
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

  /// Calculate Profile Completion Percentage
  double _calculateProfileCompletion(ProfileModel? profile, dynamic user) {
    int completedFields = 0;
    int totalFields = 8;

    // Check each field
    if (user.firstName.isNotEmpty) completedFields++;
    if (user.lastName.isNotEmpty) completedFields++;
    if (user.email.isNotEmpty) completedFields++;
    if (user.image != null && user.image!.url.isNotEmpty) completedFields++;
    if (profile?.phone != null && profile!.phone!.isNotEmpty) completedFields++;
    if (profile?.bio != null && profile!.bio!.isNotEmpty) completedFields++;
    if (profile?.dateOfBirth != null && profile!.dateOfBirth!.isNotEmpty) completedFields++;
    if (profile?.address != null && profile!.address!.isNotEmpty) completedFields++;

    return completedFields / totalFields;
  }

  /// Build Profile Header with Completion Ring
  Widget _buildProfileHeader({
    required BuildContext context,
    required dynamic user,
    required ProfileModel? profile,
    required bool isDarkMode,
    required VoidCallback onImageTap,
    required VoidCallback onEditTap,
  }) {
    final completionPercentage = _calculateProfileCompletion(profile, user);
    final completionPercent = (completionPercentage * 100).toInt();

    return Stack(
      children: [
        // Main Header Container
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDarkMode
                  ? [
                      const Color(0xFF1A1A2E),
                      const Color(0xFF16213E),
                      const Color(0xFF0F3460),
                    ]
                  : [
                      AppColors.primary,
                      AppColors.primary.withBlue(160),
                      AppColors.primary.withBlue(200),
                    ],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Column(
                    children: [
                      // Top Row - Edit Button
                      Align(
                        alignment: Alignment.centerRight,
                        child: _buildGlassButton(
                          icon: Icons.edit_outlined,
                          onTap: onEditTap,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Profile Image with Animated Ring
                      _buildProfileAvatar(
                        user: user,
                        completionPercentage: completionPercentage,
                        completionPercent: completionPercent,
                        onTap: onImageTap,
                      ),

                      const SizedBox(height: 20),

                      // Name with Verified Badge
                      _buildNameSection(user, completionPercentage),

                      const SizedBox(height: 6),

                      // Email with icon
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.email_outlined,
                            size: 14,
                            color: Colors.white.withOpacity(0.7),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            user.email,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white.withOpacity(0.85),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Role & Department Chips
                      _buildRoleChips(user, profile, isDarkMode),

                      const SizedBox(height: 40), // Space for overlapping stats card
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Decorative circles
        Positioned(
          top: -50,
          right: -50,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.05),
            ),
          ),
        ),
        Positioned(
          top: 100,
          left: -30,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.03),
            ),
          ),
        ),
      ],
    );
  }

  /// Build Glass Button
  Widget _buildGlassButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  /// Build Profile Avatar with Ring
  Widget _buildProfileAvatar({
    required dynamic user,
    required double completionPercentage,
    required int completionPercent,
    required VoidCallback onTap,
  }) {
    final bool isComplete = completionPercentage == 1.0;
    final Color ringColor = isComplete ? AppColors.success : AppColors.accent;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 150,
        height: 150,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Animated Gradient Ring
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: [
                    ringColor.withOpacity(0.1),
                    ringColor,
                    ringColor.withOpacity(0.1),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: ringColor.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),

            // Inner dark circle
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF16213E),
              ),
            ),

            // Progress Ring
            SizedBox(
              width: 135,
              height: 135,
              child: CustomPaint(
                painter: _ProfileCompletionPainter(
                  progress: completionPercentage,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  progressColor: ringColor,
                  strokeWidth: 5,
                ),
              ),
            ),

            // Profile Image
            Container(
              width: 115,
              height: 115,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipOval(
                child: user.image != null && user.image!.url.isNotEmpty
                    ? Image.network(
                        '${user.image!.url}?v=${DateTime.now().millisecondsSinceEpoch}',
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withOpacity(0.2),
                                  Colors.white.withOpacity(0.05),
                                ],
                              ),
                            ),
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                color: ringColor,
                                strokeWidth: 2,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return _buildAvatarPlaceholder(user.firstName);
                        },
                      )
                    : _buildAvatarPlaceholder(user.firstName),
              ),
            ),

            // Camera Button
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ),

            // Completion Badge
            if (!isComplete)
              Positioned(
                top: 5,
                right: 15,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.warning,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.warning.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '$completionPercent%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Build Name Section
  Widget _buildNameSection(dynamic user, double completionPercentage) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            user.fullName,
            style: AppTextStyles.headlineMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (completionPercentage == 1.0) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.success, AppColors.success.withGreen(200)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.success.withOpacity(0.4),
                  blurRadius: 8,
                ),
              ],
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 14,
            ),
          ),
        ],
      ],
    );
  }

  /// Build Role Chips
  Widget _buildRoleChips(dynamic user, ProfileModel? profile, bool isDarkMode) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        _buildChip(
          icon: Icons.person_outline,
          text: user.isAdmin ? 'Administrator' : 'Employee',
          color: AppColors.accent,
        ),
        if (profile?.department != null)
          _buildChip(
            icon: Icons.business_outlined,
            text: profile!.department!,
            color: AppColors.info,
          ),
        if (profile?.position != null)
          _buildChip(
            icon: Icons.work_outline,
            text: profile!.position!,
            color: AppColors.success,
          ),
      ],
    );
  }

  /// Build Chip
  Widget _buildChip({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: color.withOpacity(0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: AppTextStyles.labelSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Build Quick Stats
  Widget _buildQuickStats(ProfileModel? profile, bool isDarkMode, double completionPercentage) {
    final completionPercent = (completionPercentage * 100).toInt();
    final hasPhone = profile?.phone != null && profile!.phone!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: isDarkMode
            ? AppColors.darkCard
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDarkMode
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Row(
        children: [
          // Profile Completion
          Expanded(
            child: _buildStatItem(
              icon: Icons.pie_chart_rounded,
              value: '$completionPercent%',
              label: 'Profile',
              color: completionPercentage == 1.0
                  ? AppColors.success
                  : AppColors.warning,
              isDarkMode: isDarkMode,
            ),
          ),
          _buildStatDivider(isDarkMode),
          // Phone Status
          Expanded(
            child: _buildStatItem(
              icon: hasPhone ? Icons.verified_rounded : Icons.phone_android,
              value: hasPhone ? 'Verified' : 'Not Set',
              label: 'Phone',
              color: hasPhone ? AppColors.success : AppColors.textSecondary,
              isDarkMode: isDarkMode,
            ),
          ),
          _buildStatDivider(isDarkMode),
          // Position
          Expanded(
            child: _buildStatItem(
              icon: Icons.work_outline_rounded,
              value: profile?.position ?? 'N/A',
              label: 'Position',
              color: AppColors.primary,
              isDarkMode: isDarkMode,
              isLongText: true,
            ),
          ),
        ],
      ),
    );
  }

  /// Build Stat Divider
  Widget _buildStatDivider(bool isDarkMode) {
    return Container(
      width: 1,
      height: 45,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: isDarkMode
          ? Colors.white.withOpacity(0.1)
          : Colors.grey.withOpacity(0.2),
    );
  }

  /// Build Stat Item
  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required bool isDarkMode,
    bool isLongText = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(isDarkMode ? 0.2 : 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isLongText && value.length > 10 ? '${value.substring(0, 8)}...' : value,
          style: AppTextStyles.labelMedium.copyWith(
            color: isDarkMode ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: isDarkMode
                ? Colors.white.withOpacity(0.5)
                : AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  /// Build Avatar Placeholder
  Widget _buildAvatarPlaceholder(String firstName) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0F3460),
            const Color(0xFF16213E),
          ],
        ),
      ),
      child: Center(
        child: Text(
          firstName.isNotEmpty ? firstName[0].toUpperCase() : 'U',
          style: AppTextStyles.displayLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 42,
          ),
        ),
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

/// Profile Completion Ring Painter
class _ProfileCompletionPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;
  final double strokeWidth;

  _ProfileCompletionPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start from top
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ProfileCompletionPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.backgroundColor != backgroundColor;
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
