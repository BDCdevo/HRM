import 'package:flutter/material.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_styles.dart';
import 'chat_list_screen.dart';

/// Chat Test Screen
///
/// Simple screen to test chat feature with hardcoded credentials
class ChatTestScreen extends StatelessWidget {
  const ChatTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Test data from CLAUDE.md
    const int testCompanyId = 6; // BDC
    const int testUserId = 10; // Ahmed Abbas user ID

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkAppBar : AppColors.primary,
        elevation: 0,
        title: Text(
          'Chat Feature Test',
          style: AppTextStyles.titleLarge.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.chat_bubble,
                size: 100,
                color: isDark ? AppColors.darkAccent : AppColors.accent,
              ),
              const SizedBox(height: 32),
              Text(
                'Chat Feature Test',
                style: AppTextStyles.titleLarge.copyWith(
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.darkAccent : AppColors.accent)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppColors.darkAccent : AppColors.accent,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Test Configuration:',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      'Company ID:',
                      testCompanyId.toString(),
                      isDark,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      'User ID:',
                      testUserId.toString(),
                      isDark,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      'Server:',
                      'Production (erp1.bdcbiz.com)',
                      isDark,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChatListScreen(
                          companyId: testCompanyId,
                          currentUserId: testUserId,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.chat, size: 24),
                  label: const Text(
                    'Open Chat',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isDark ? AppColors.darkAccent : AppColors.accent,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Note: Make sure you are logged in with Ahmed@bdcbiz.com',
                style: AppTextStyles.bodySmall.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.info,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.info, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This will test: Fetch conversations, Create conversation, Send messages',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.info,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark) {
    return Row(
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color:
                isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
