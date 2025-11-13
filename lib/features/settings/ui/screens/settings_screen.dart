import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_colors_extension.dart';  // ✅ النظام الموحد الجديد
import '../../../../core/styles/app_text_styles.dart';
import '../../../../core/theme/cubit/theme_cubit.dart';
import '../../../../core/theme/cubit/theme_state.dart';
import '../../../../core/widgets/theme_toggle.dart';
import '../../../auth/logic/cubit/auth_cubit.dart';
import '../../../auth/ui/screens/login_screen.dart';

/// Settings Screen
///
/// Displays app settings and preferences
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _biometricEnabled = false;
  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Account Section
            _buildSectionHeader('Account'),
            _buildSettingsList([
              _buildSettingsTile(
                icon: Icons.person_outline,
                title: 'Profile',
                subtitle: 'Edit your profile information',
                onTap: () {
                  // TODO: Navigate to profile
                },
              ),
              _buildSettingsTile(
                icon: Icons.lock_outline,
                title: 'Change Password',
                subtitle: 'Update your password',
                onTap: () {
                  // TODO: Navigate to change password
                },
              ),
            ]),

            const SizedBox(height: 16),

            // Notifications Section
            _buildSectionHeader('Notifications'),
            _buildSettingsList([
              _buildSwitchTile(
                icon: Icons.notifications_outlined,
                title: 'Push Notifications',
                subtitle: 'Receive push notifications',
                value: _pushNotifications,
                onChanged: (value) {
                  setState(() {
                    _pushNotifications = value;
                  });
                },
              ),
              _buildSwitchTile(
                icon: Icons.email_outlined,
                title: 'Email Notifications',
                subtitle: 'Receive email notifications',
                value: _emailNotifications,
                onChanged: (value) {
                  setState(() {
                    _emailNotifications = value;
                  });
                },
              ),
            ]),

            const SizedBox(height: 16),

            // Security Section
            _buildSectionHeader('Security'),
            _buildSettingsList([
              _buildSwitchTile(
                icon: Icons.fingerprint,
                title: 'Biometric Authentication',
                subtitle: 'Use fingerprint or face to login',
                value: _biometricEnabled,
                onChanged: (value) {
                  setState(() {
                    _biometricEnabled = value;
                  });
                },
              ),
            ]),

            const SizedBox(height: 16),

            // Preferences Section
            _buildSectionHeader('Preferences'),
            _buildSettingsList([
              _buildSettingsTile(
                icon: Icons.language,
                title: 'Language',
                subtitle: _selectedLanguage,
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  _showLanguageDialog();
                },
              ),
            ]),

            const SizedBox(height: 16),

            // Theme Section
            _buildSectionHeader('Appearance'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: BlocBuilder<ThemeCubit, ThemeState>(
                builder: (context, state) {
                  return ThemeModeSelector();
                },
              ),
            ),

            const SizedBox(height: 16),

            // About Section
            _buildSectionHeader('About'),
            _buildSettingsList([
              _buildSettingsTile(
                icon: Icons.info_outline,
                title: 'About App',
                subtitle: 'Version 1.0.0',
                onTap: () {
                  // TODO: Navigate to about screen
                },
              ),
              _buildSettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                subtitle: 'Read our privacy policy',
                onTap: () {
                  // TODO: Navigate to privacy policy
                },
              ),
              _buildSettingsTile(
                icon: Icons.description_outlined,
                title: 'Terms of Service',
                subtitle: 'Read terms of service',
                onTap: () {
                  // TODO: Navigate to terms
                },
              ),
            ]),

            const SizedBox(height: 16),

            // Danger Zone
            _buildSectionHeader('Danger Zone'),
            _buildSettingsList([
              _buildSettingsTile(
                icon: Icons.logout,
                title: 'Logout',
                subtitle: 'Sign out of your account',
                titleColor: AppColors.error,
                onTap: () {
                  _showLogoutDialog();
                },
              ),
              _buildSettingsTile(
                icon: Icons.delete_outline,
                title: 'Delete Account',
                subtitle: 'Permanently delete your account',
                titleColor: AppColors.error,
                onTap: () {
                  _showDeleteAccountDialog();
                },
              ),
            ]),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: AppTextStyles.titleSmall.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingsList(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Color? titleColor,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (titleColor ?? AppColors.primary).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: titleColor ?? AppColors.primary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
          color: titleColor ?? AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      trailing: trailing ??
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: AppColors.textSecondary,
          ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: AppColors.primary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      activeColor: AppColors.primary,
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageOption('English'),
              _buildLanguageOption('العربية'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(String language) {
    return RadioListTile<String>(
      title: Text(language),
      value: language,
      groupValue: _selectedLanguage,
      onChanged: (value) {
        setState(() {
          _selectedLanguage = value!;
        });
        Navigator.pop(context);
      },
      activeColor: AppColors.primary,
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<AuthCubit>().logout();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                  (route) => false,
                );
              },
              child: Text(
                'Logout',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text(
            'Are you sure you want to delete your account? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                // TODO: Implement account deletion
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Account deletion is not yet implemented'),
                  ),
                );
              },
              child: Text(
                'Delete',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );
  }
}
