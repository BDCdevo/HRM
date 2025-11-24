import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_styles.dart';
import '../../data/repo/chat_repository.dart';
import '../../logic/cubit/employees_cubit.dart';
import '../../logic/cubit/employees_state.dart';

/// Recent Contacts Section Widget
///
/// Displays horizontal scrollable list of all employees in the company
/// Clicking on a contact navigates directly to chat with that person
class RecentContactsSection extends StatelessWidget {
  final int companyId;
  final int currentUserId;
  final Function(int userId, String userName, String? userAvatar) onContactTap;

  const RecentContactsSection({
    super.key,
    required this.companyId,
    required this.currentUserId,
    required this.onContactTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider(
      create: (context) => EmployeesCubit(ChatRepository())
        ..fetchEmployees(companyId),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "RECENT" Label
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text(
              'RECENT',
              style: AppTextStyles.labelSmall.copyWith(
                color: isDark ? const Color(0xFF8F92A1) : const Color(0xFF6B7280),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
          ),

          // Horizontal Scrollable Contacts
          SizedBox(
            height: 100,
            child: BlocBuilder<EmployeesCubit, EmployeesState>(
              builder: (context, state) {
                if (state is EmployeesLoading) {
                  return _buildLoadingState();
                }

                if (state is EmployeesLoaded) {
                  // Filter out current user
                  final employees = state.employees
                      .where((emp) => emp['id'] != currentUserId)
                      .toList();

                  if (employees.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: employees.length,
                    itemBuilder: (context, index) {
                      final employee = employees[index];
                      return _buildContactAvatar(
                        context,
                        employee['id'] as int,
                        employee['name'] as String,
                        employee['avatar'] as String?,
                      );
                    },
                  );
                }

                if (state is EmployeesError) {
                  return _buildErrorState(context);
                }

                return const SizedBox.shrink();
              },
            ),
          ),

          // Divider
          Divider(
            color: isDark ? const Color(0xFF2A2D3E) : const Color(0xFFE5E7EB),
            thickness: 1,
            height: 1,
          ),
        ],
      ),
    );
  }

  /// Build Contact Avatar
  Widget _buildContactAvatar(
    BuildContext context,
    int userId,
    String userName,
    String? userAvatar,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Get initials for avatar fallback
    final nameParts = userName.split(' ');
    final initials = nameParts.length >= 2
        ? '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase()
        : userName.substring(0, 1).toUpperCase();

    // Random gradient colors for avatar
    final colors = [
      [const Color(0xFFEF8354), const Color(0xFFD86F45)],
      [const Color(0xFF4A90E2), const Color(0xFF357ABD)],
      [const Color(0xFF50C878), const Color(0xFF3FA463)],
      [const Color(0xFFE94B3C), const Color(0xFFD43D2F)],
      [const Color(0xFF9B59B6), const Color(0xFF8E44AD)],
    ];
    final colorIndex = userId % colors.length;

    return GestureDetector(
      onTap: () => onContactTap(userId, userName, userAvatar),
      child: Container(
        width: 70,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          children: [
            // Avatar with Rounded Corners
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16), // Rounded corners
                gradient: LinearGradient(
                  colors: colors[colorIndex],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: isDark ? const Color(0xFF2A2D3E) : const Color(0xFFE5E7EB),
                  width: 2,
                ),
              ),
              child: userAvatar != null && userAvatar.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14), // Match container minus border
                      child: CachedNetworkImage(
                        imageUrl: userAvatar,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                        errorWidget: (context, url, error) => Center(
                          child: Text(
                            initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ),

            const SizedBox(height: 6),

            // Name
            Text(
              userName.split(' ').first,
              style: AppTextStyles.labelSmall.copyWith(
                color: isDark ? Colors.white : const Color(0xFF1F2937),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Build Loading State
  Widget _buildLoadingState() {
    return Center(
      child: SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          color: AppColors.accent,
          strokeWidth: 2,
        ),
      ),
    );
  }

  /// Build Empty State
  Widget _buildEmptyState() {
    return Center(
      child: Text(
        'No contacts available',
        style: AppTextStyles.bodySmall.copyWith(
          color: const Color(0xFF8F92A1),
        ),
      ),
    );
  }

  /// Build Error State
  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Text(
        'Failed to load contacts',
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.error,
        ),
      ),
    );
  }
}
