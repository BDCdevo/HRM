import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_styles.dart';
import '../../data/models/employee_attendance_model.dart';

/// Employee Details Bottom Sheet
///
/// Shows employee attendance details including location and late reason
class EmployeeDetailsBottomSheet extends StatelessWidget {
  final EmployeeAttendanceModel employee;

  const EmployeeDetailsBottomSheet({
    super.key,
    required this.employee,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 40,
                  backgroundColor: _getAvatarColor(employee.employeeName),
                  child: Text(
                    employee.avatarInitial ?? employee.employeeName[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Employee Name
                Text(
                  employee.employeeName,
                  style: AppTextStyles.headlineMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),

                // Role & Department
                Text(
                  '${employee.role ?? 'No Role'} • ${employee.department ?? 'No Department'}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isDark ? Colors.grey.shade400 : AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Details Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Badge
                _buildStatusBadge(context),

                const SizedBox(height: 16),

                // Check-in Time
                if (employee.checkInTime != null)
                  _buildDetailRow(
                    context: context,
                    icon: Icons.login,
                    label: 'Check-In Time',
                    value: employee.checkInTime!,
                    color: AppColors.success,
                  ),

                if (employee.checkInTime != null) const SizedBox(height: 12),

                // Duration
                if (employee.duration != null)
                  _buildDetailRow(
                    context: context,
                    icon: Icons.timer_outlined,
                    label: 'Duration',
                    value: employee.duration!,
                    color: AppColors.info,
                  ),

                if (employee.duration != null) const SizedBox(height: 12),

                // Check-out Time
                if (employee.checkOutTime != null)
                  _buildDetailRow(
                    context: context,
                    icon: Icons.logout,
                    label: 'Check-Out Time',
                    value: employee.checkOutTime!,
                    color: AppColors.error,
                  ),

                if (employee.checkOutTime != null) const SizedBox(height: 16),

                // Late Reason Section
                if (employee.lateReason != null && employee.lateReason!.isNotEmpty) ...[
                  const Divider(),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(isDark ? 0.2 : 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.info_outline,
                          color: AppColors.warning,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Late Reason',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: isDark ? Colors.grey.shade400 : AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              employee.lateReason!,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: isDark ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                // Location Section
                if (employee.hasLocation &&
                    employee.checkInLatitude != null &&
                    employee.checkInLongitude != null) ...[
                  const Divider(),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(isDark ? 0.2 : 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Check-In Location',
                              style: AppTextStyles.labelMedium.copyWith(
                                color: isDark ? Colors.grey.shade400 : AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    employee.formattedLocation ?? 'N/A',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: isDark ? Colors.white : AppColors.textPrimary,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.copy, size: 18),
                                  color: AppColors.primary,
                                  onPressed: () {
                                    Clipboard.setData(
                                      ClipboardData(text: employee.formattedLocation ?? ''),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Location copied to clipboard'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  try {
                                    final url = Uri.parse(
                                      'https://www.google.com/maps/search/?api=1&query=${employee.checkInLatitude},${employee.checkInLongitude}',
                                    );

                                    print('🗺️ Opening map: $url');

                                    if (await canLaunchUrl(url)) {
                                      await launchUrl(
                                        url,
                                        mode: LaunchMode.externalApplication,
                                      );
                                    } else {
                                      throw Exception('Could not open maps application');
                                    }
                                  } catch (e) {
                                    print('❌ Error opening map: $e');
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Could not open map: $e'),
                                          backgroundColor: AppColors.error,
                                        ),
                                      );
                                    }
                                  }
                                },
                                icon: const Icon(Icons.map, size: 16),
                                label: const Text('View on Map'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  side: const BorderSide(color: AppColors.primary),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// Build Status Badge
  Widget _buildStatusBadge(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color statusColor;
    String statusText;
    Color statusBgColor;
    IconData statusIcon;

    switch (employee.status.toLowerCase()) {
      case 'present':
        statusColor = AppColors.success;
        statusText = 'PRESENT';
        statusBgColor = isDark ? AppColors.success.withOpacity(0.2) : const Color(0xFFD4EDDA);
        statusIcon = Icons.check_circle;
        break;
      case 'late':
        statusColor = const Color(0xFFFF9800);
        statusText = 'LATE';
        statusBgColor = isDark ? const Color(0xFFFF9800).withOpacity(0.2) : const Color(0xFFFFE5D0);
        statusIcon = Icons.access_time;
        break;
      case 'absent':
        statusColor = AppColors.error;
        statusText = 'ABSENT';
        statusBgColor = isDark ? AppColors.error.withOpacity(0.2) : const Color(0xFFF8D7DA);
        statusIcon = Icons.cancel;
        break;
      case 'checked_out':
        statusColor = AppColors.info;
        statusText = 'CHECKED OUT';
        statusBgColor = isDark ? AppColors.info.withOpacity(0.2) : const Color(0xFFD1ECF1);
        statusIcon = Icons.exit_to_app;
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'UNKNOWN';
        statusBgColor = isDark ? Colors.grey.withOpacity(0.2) : const Color(0xFFE0E0E0);
        statusIcon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: statusBgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            color: statusColor,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Build Detail Row
  Widget _buildDetailRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(isDark ? 0.2 : 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: isDark ? Colors.grey.shade400 : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Get avatar color based on employee name
  Color _getAvatarColor(String name) {
    final colors = [
      const Color(0xFFE91E63), // Pink
      const Color(0xFFFF9800), // Orange
      const Color(0xFF2196F3), // Blue
      const Color(0xFF4CAF50), // Green
      const Color(0xFF9C27B0), // Purple
      const Color(0xFF00BCD4), // Cyan
      const Color(0xFFFF5722), // Deep Orange
      const Color(0xFF607D8B), // Blue Grey
    ];
    final index = name.hashCode % colors.length;
    return colors[index.abs()];
  }
}

/// Helper function to show employee details bottom sheet
void showEmployeeDetailsBottomSheet(
  BuildContext context,
  EmployeeAttendanceModel employee,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: EmployeeDetailsBottomSheet(employee: employee),
    ),
  );
}
