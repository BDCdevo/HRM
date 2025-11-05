import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../logic/cubit/attendance_history_cubit.dart';
import '../../logic/cubit/attendance_history_state.dart';
import '../../data/models/attendance_history_model.dart';

/// Attendance History Screen
///
/// Displays paginated list of user's attendance records
/// Features:
/// - Pagination (load more on scroll)
/// - Pull to refresh
/// - Status badges (completed, in progress, absent)
/// - Detailed attendance information
class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  late final AttendanceHistoryCubit _historyCubit;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _historyCubit = AttendanceHistoryCubit();
    _scrollController = ScrollController();

    // Add scroll listener for pagination
    _scrollController.addListener(_onScroll);

    // Fetch initial data
    _historyCubit.fetchHistory();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _historyCubit.close();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      // When user scrolls to 90% of the list, load more
      _historyCubit.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _historyCubit,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: AppColors.white,
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Attendance History',
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.white,
            ),
          ),
        ),
        body: BlocBuilder<AttendanceHistoryCubit, AttendanceHistoryState>(
          builder: (context, state) {
            // Show loading state
            if (state is AttendanceHistoryLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            // Show error state
            if (state is AttendanceHistoryError && state is! AttendanceHistoryLoaded) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error Loading History',
                        style: AppTextStyles.titleLarge.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.displayMessage,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      CustomButton(
                        text: 'Retry',
                        onPressed: () {
                          _historyCubit.fetchHistory();
                        },
                      ),
                    ],
                  ),
                ),
              );
            }

            // Get records from loaded state
            final records = state is AttendanceHistoryLoaded
                ? state.records
                : (state is AttendanceHistoryLoadingMore
                    ? state.currentRecords
                    : (state is AttendanceHistoryRefreshing
                        ? state.currentRecords
                        : <AttendanceHistoryItemModel>[]));

            final hasMore = state is AttendanceHistoryLoaded ? state.hasMore : false;
            final isLoadingMore = state is AttendanceHistoryLoadingMore;
            final isRefreshing = state is AttendanceHistoryRefreshing;

            // Show empty state
            if (records.isEmpty && !isRefreshing) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        size: 64,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No Attendance Records',
                        style: AppTextStyles.titleLarge.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your attendance history will appear here',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => _historyCubit.refresh(),
              child: ListView.builder(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: records.length + (hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  // Show loading indicator at the end if there are more items
                  if (index >= records.length) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: isLoadingMore
                            ? const CircularProgressIndicator()
                            : const SizedBox.shrink(),
                      ),
                    );
                  }

                  final record = records[index];
                  return _buildAttendanceCard(record);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAttendanceCard(AttendanceHistoryItemModel record) {
    // Determine status color
    Color statusColor;
    switch (record.statusColor) {
      case 'success':
        statusColor = AppColors.success;
        break;
      case 'warning':
        statusColor = AppColors.warning;
        break;
      case 'error':
        statusColor = AppColors.error;
        break;
      default:
        statusColor = AppColors.textSecondary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.textSecondary.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with date and status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 20,
                      color: statusColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      record.date,
                      style: AppTextStyles.titleSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    record.statusText,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Check-in time
                if (record.checkInTime != null)
                  _buildDetailRow(
                    icon: Icons.login,
                    label: 'Check In',
                    value: record.checkInTime!,
                    color: AppColors.success,
                  ),

                if (record.checkInTime != null && record.checkOutTime != null)
                  const SizedBox(height: 12),

                // Check-out time
                if (record.checkOutTime != null)
                  _buildDetailRow(
                    icon: Icons.logout,
                    label: 'Check Out',
                    value: record.checkOutTime!,
                    color: AppColors.error,
                  ),

                if (record.workingHours > 0) ...[
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    icon: Icons.access_time,
                    label: 'Working Hours',
                    value: record.workingHoursLabel,
                    color: AppColors.primary,
                  ),
                ],

                if (record.lateMinutes > 0) ...[
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    icon: Icons.schedule,
                    label: 'Late',
                    value: record.lateLabel,
                    color: AppColors.warning,
                  ),
                ],

                if (record.notes != null && record.notes!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.note,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          record.notes!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: color,
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
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
