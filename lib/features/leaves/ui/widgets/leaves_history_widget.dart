import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_styles.dart';
import '../../../../core/theme/cubit/theme_cubit.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../leave/logic/cubit/leave_cubit.dart';
import '../../../leave/logic/cubit/leave_state.dart';
import '../../../leave/data/models/leave_request_model.dart';
import 'leaves_skeleton.dart';

/// Leaves History Widget
///
/// Displays leave request history
class LeavesHistoryWidget extends StatefulWidget {
  const LeavesHistoryWidget({super.key});

  @override
  State<LeavesHistoryWidget> createState() => _LeavesHistoryWidgetState();
}

class _LeavesHistoryWidgetState extends State<LeavesHistoryWidget> {
  final ScrollController _scrollController = ScrollController();
  String? _statusFilter;
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();

    // Setup pagination listener
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Fetch leave history only once when widget is ready
    if (!_hasInitialized) {
      _hasInitialized = true;
      print('🟢 LeavesHistoryWidget: Initializing and fetching data...');

      final cubit = context.read<LeaveCubit>();
      final currentState = cubit.state;

      print('🟢 LeavesHistoryWidget: Current state: ${currentState.runtimeType}');

      // Only fetch if not already loading or loaded
      if (currentState is! LeaveHistoryLoading &&
          currentState is! LeaveHistoryLoaded &&
          currentState is! LeaveHistoryLoadingMore) {
        print('🟢 LeavesHistoryWidget: Calling fetchLeaveHistory()');
        cubit.fetchLeaveHistory();
      } else {
        print('🟡 LeavesHistoryWidget: Data already loading or loaded, skipping fetch');
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // Load more when reached bottom
      context.read<LeaveCubit>().loadMoreLeaveHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().isDarkMode;
    final cardColor = isDark ? AppColors.darkCard : AppColors.surface;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return BlocBuilder<LeaveCubit, LeaveState>(
      builder: (context, state) {
        // Show loading skeleton for initial state and loading state
        if (state is LeaveHistoryLoading || state is LeaveInitial) {
          return const LeavesSkeleton();
        }

        if (state is LeaveHistoryLoaded || state is LeaveHistoryLoadingMore || state is LeaveHistoryRefreshing) {
          final List<LeaveRequestModel> leaves = state is LeaveHistoryLoaded
              ? state.leaveRequests
              : state is LeaveHistoryLoadingMore
                  ? state.currentRequests
                  : state is LeaveHistoryRefreshing
                      ? state.currentRequests
                      : [];

          final bool hasMore = state is LeaveHistoryLoaded ? state.hasMore : false;
          final bool isLoadingMore = state is LeaveHistoryLoadingMore;

          if (leaves.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_busy,
                    size: 80,
                    color: secondaryTextColor.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No leave requests found',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => context.read<LeaveCubit>().refreshLeaveHistory(),
            color: AppColors.primary,
            child: Column(
              children: [
                // Filter chips
                Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _FilterChip(
                        label: 'All',
                        isSelected: _statusFilter == null,
                        isDark: isDark,
                        cardColor: cardColor,
                        onTap: () {
                          setState(() => _statusFilter = null);
                          context.read<LeaveCubit>().fetchLeaveHistory();
                        },
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Pending',
                        isSelected: _statusFilter == 'pending',
                        isDark: isDark,
                        cardColor: cardColor,
                        onTap: () {
                          setState(() => _statusFilter = 'pending');
                          context.read<LeaveCubit>().fetchLeaveHistory(status: 'pending');
                        },
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Approved',
                        isSelected: _statusFilter == 'approved',
                        isDark: isDark,
                        cardColor: cardColor,
                        onTap: () {
                          setState(() => _statusFilter = 'approved');
                          context.read<LeaveCubit>().fetchLeaveHistory(status: 'approved');
                        },
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Rejected',
                        isSelected: _statusFilter == 'rejected',
                        isDark: isDark,
                        cardColor: cardColor,
                        onTap: () {
                          setState(() => _statusFilter = 'rejected');
                          context.read<LeaveCubit>().fetchLeaveHistory(status: 'rejected');
                        },
                      ),
                    ],
                  ),
                ),

                // Leave list
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(20),
                    itemCount: leaves.length + (hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == leaves.length) {
                        // Loading more indicator
                        return isLoadingMore
                            ? const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : const SizedBox.shrink();
                      }

                      final leave = leaves[index];
                      return _LeaveHistoryItem(
                        leave: leave,
                        isDark: isDark,
                        cardColor: cardColor,
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }

        if (state is LeaveError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 80,
                  color: AppColors.error,
                ),
                const SizedBox(height: 16),
                Text(
                  state.message,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.error,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<LeaveCubit>().fetchLeaveHistory(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

/// Filter Chip
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;
  final Color cardColor;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isDark = false,
    this.cardColor = AppColors.white,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
              ? AppColors.primary
              : (isDark ? AppColors.darkBorder : AppColors.border.withOpacity(0.3)),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: isSelected
              ? AppColors.white
              : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

/// Leave History Item
class _LeaveHistoryItem extends StatelessWidget {
  final LeaveRequestModel leave;
  final bool isDark;
  final Color cardColor;
  final Color textColor;
  final Color secondaryTextColor;

  const _LeaveHistoryItem({
    required this.leave,
    required this.isDark,
    required this.cardColor,
    required this.textColor,
    required this.secondaryTextColor,
  });

  IconData _getTypeIcon() {
    final name = leave.vacationTypeName?.toLowerCase() ?? '';
    if (name.contains('sick')) return Icons.local_hospital;
    if (name.contains('annual') || name.contains('vacation')) return Icons.beach_access;
    if (name.contains('casual')) return Icons.calendar_today;
    if (name.contains('emergency')) return Icons.emergency;
    return Icons.event_busy;
  }

  Color _getStatusColor() {
    switch (leave.statusColor) {
      case 'success':
        return AppColors.success;
      case 'warning':
        return AppColors.warning;
      case 'error':
        return AppColors.error;
      default:
        return AppColors.info;
    }
  }

  IconData _getStatusIcon() {
    switch (leave.statusIcon) {
      case 'check_circle':
        return Icons.check_circle;
      case 'access_time':
        return Icons.access_time;
      case 'cancel':
        return Icons.cancel;
      case 'block':
        return Icons.block;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : statusColor.withOpacity(0.3),
        ),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // Show leave details
          _showLeaveDetails(context);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  // Type Icon
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(isDark ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getTypeIcon(),
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Type & Duration
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          leave.vacationTypeName ?? 'Leave',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          leave.durationFormatted,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(isDark ? 0.2 : 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(),
                          color: statusColor,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          leave.statusText.toUpperCase(),
                          style: AppTextStyles.labelSmall.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Divider
              Divider(
                height: 1,
                color: isDark ? AppColors.darkDivider : AppColors.border.withOpacity(0.3),
              ),

              const SizedBox(height: 12),

              // Date Range
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: secondaryTextColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    leave.dateRangeFormatted,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Reason
              if (leave.reason != null && leave.reason!.isNotEmpty)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.description,
                      size: 16,
                      color: secondaryTextColor,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        leave.reason!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: secondaryTextColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLeaveDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        title: Text(
          leave.vacationTypeName ?? 'Leave Details',
          style: TextStyle(color: textColor),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailRow(label: 'Status', value: leave.statusText),
            _DetailRow(label: 'Start Date', value: leave.startDate ?? '-'),
            _DetailRow(label: 'End Date', value: leave.endDate ?? '-'),
            _DetailRow(label: 'Duration', value: leave.durationFormatted),
            if (leave.reason != null && leave.reason!.isNotEmpty)
              _DetailRow(label: 'Reason', value: leave.reason!),
            if (leave.notes != null && leave.notes!.isNotEmpty)
              _DetailRow(label: 'Notes', value: leave.notes!),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: AppColors.primary)),
          ),
          if (leave.isPending)
            TextButton(
              onPressed: () {
                // Cancel leave
                Navigator.pop(context);
                context.read<LeaveCubit>().cancelLeave(leave.id);
              },
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: const Text('Cancel Request'),
            ),
        ],
      ),
    );
  }
}

/// Detail Row
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? labelColor;
  final Color? valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    this.labelColor,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().isDarkMode;
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: labelColor ?? secondaryTextColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: valueColor ?? textColor,
            ),
          ),
        ],
      ),
    );
  }
}
