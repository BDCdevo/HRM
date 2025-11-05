import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../logic/cubit/leave_cubit.dart';
import '../../logic/cubit/leave_state.dart';
import '../../data/models/leave_request_model.dart';

/// Leave History Screen
///
/// Displays paginated list of leave requests with filtering
class LeaveHistoryScreen extends StatefulWidget {
  const LeaveHistoryScreen({super.key});

  @override
  State<LeaveHistoryScreen> createState() => _LeaveHistoryScreenState();
}

class _LeaveHistoryScreenState extends State<LeaveHistoryScreen> {
  late final LeaveCubit _leaveCubit;
  late final ScrollController _scrollController;
  String? _selectedStatusFilter;

  @override
  void initState() {
    super.initState();
    _leaveCubit = LeaveCubit();
    _scrollController = ScrollController();

    // Add scroll listener for pagination
    _scrollController.addListener(_onScroll);

    // Fetch initial data
    _leaveCubit.fetchLeaveHistory();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _leaveCubit.close();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      // When user scrolls to 90% of the list, load more
      _leaveCubit.loadMoreLeaveHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _leaveCubit,
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
            'Leave History',
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.white,
            ),
          ),
        ),
        body: BlocConsumer<LeaveCubit, LeaveState>(
          listener: (context, state) {
            if (state is LeaveCancelled) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.success,
                ),
              );
            } else if (state is LeaveError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.displayMessage),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, state) {
            // Show loading state
            if (state is LeaveHistoryLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            // Show error state
            if (state is LeaveError && state is! LeaveHistoryLoaded) {
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
                        'Error Loading Leave History',
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
                          _leaveCubit.fetchLeaveHistory();
                        },
                      ),
                    ],
                  ),
                ),
              );
            }

            // Get leave requests from loaded state
            final leaveRequests = state is LeaveHistoryLoaded
                ? state.leaveRequests
                : (state is LeaveHistoryLoadingMore
                    ? state.currentRequests
                    : (state is LeaveHistoryRefreshing
                        ? state.currentRequests
                        : <LeaveRequestModel>[]));

            final hasMore = state is LeaveHistoryLoaded ? state.hasMore : false;
            final isLoadingMore = state is LeaveHistoryLoadingMore;
            final isRefreshing = state is LeaveHistoryRefreshing;

            // Show empty state
            if (leaveRequests.isEmpty && !isRefreshing) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_busy,
                        size: 64,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No Leave Requests',
                        style: AppTextStyles.titleLarge.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You haven\'t applied for any leave yet',
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

            return Column(
              children: [
                // Status Filter
                _buildStatusFilter(state),

                // Leave Requests List
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => _leaveCubit.refreshLeaveHistory(),
                    child: ListView.builder(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: leaveRequests.length + (hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        // Show loading indicator at the end if there are more items
                        if (index >= leaveRequests.length) {
                          return Padding(
                            padding: const EdgeInsets.all(16),
                            child: Center(
                              child: isLoadingMore
                                  ? const CircularProgressIndicator()
                                  : const SizedBox.shrink(),
                            ),
                          );
                        }

                        final leaveRequest = leaveRequests[index];
                        return _buildLeaveRequestCard(leaveRequest);
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatusFilter(LeaveState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.textSecondary.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('All', null),
            const SizedBox(width: 8),
            _buildFilterChip('Pending', 'pending'),
            const SizedBox(width: 8),
            _buildFilterChip('Approved', 'approved'),
            const SizedBox(width: 8),
            _buildFilterChip('Rejected', 'rejected'),
            const SizedBox(width: 8),
            _buildFilterChip('Cancelled', 'cancelled'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String? status) {
    final isSelected = _selectedStatusFilter == status;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedStatusFilter = status;
        });
        _leaveCubit.changeStatusFilter(status);
      },
      backgroundColor: AppColors.white,
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: AppTextStyles.labelMedium.copyWith(
        color: isSelected ? AppColors.primary : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.border,
      ),
    );
  }

  Widget _buildLeaveRequestCard(LeaveRequestModel leaveRequest) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _getStatusColor(leaveRequest.status).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => _showLeaveDetails(leaveRequest),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Type and Status
              Row(
                children: [
                  Expanded(
                    child: Text(
                      leaveRequest.vacationType?.name ?? 'Leave Request',
                      style: AppTextStyles.titleSmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildStatusChip(leaveRequest.status),
                ],
              ),

              const SizedBox(height: 12),

              // Date Range
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      leaveRequest.dateRangeFormatted,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Duration
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    leaveRequest.durationFormatted,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),

              if (leaveRequest.reason != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Reason:',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  leaveRequest.reason!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // Cancel button for pending/approved requests
              if (leaveRequest.canCancel) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => _cancelLeaveRequest(leaveRequest),
                    icon: Icon(Icons.cancel, size: 16, color: AppColors.error),
                    label: Text(
                      'Cancel Request',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final color = _getStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        _getStatusLabel(status),
        style: AppTextStyles.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return AppColors.warning;
      case 'approved':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      case 'cancelled':
        return AppColors.textSecondary;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  void _showLeaveDetails(LeaveRequestModel leaveRequest) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Leave Request Details',
                          style: AppTextStyles.titleLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Vacation Type
                  _buildDetailRow('Type', leaveRequest.vacationType?.name ?? '-'),
                  const SizedBox(height: 16),

                  // Date Range
                  _buildDetailRow('Period', leaveRequest.dateRangeFormatted),
                  const SizedBox(height: 16),

                  // Duration
                  _buildDetailRow('Duration', leaveRequest.durationFormatted),
                  const SizedBox(height: 16),

                  // Status
                  _buildDetailRow('Status', leaveRequest.statusLabel),
                  const SizedBox(height: 16),

                  // Reason
                  if (leaveRequest.reason != null) ...[
                    Text(
                      'Reason',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      leaveRequest.reason!,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Admin Notes
                  if (leaveRequest.adminNotes != null) ...[
                    Text(
                      'Admin Notes',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      leaveRequest.adminNotes!,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Approver Info
                  if (leaveRequest.approverName != null) ...[
                    _buildDetailRow('Approver', leaveRequest.approverName!),
                    const SizedBox(height: 16),
                  ],

                  if (leaveRequest.approvedAt != null) ...[
                    _buildDetailRow(
                      'Approved At',
                      leaveRequest.approvedAt!.substring(0, 16),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  void _cancelLeaveRequest(LeaveRequestModel leaveRequest) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Cancel Leave Request'),
          content: const Text(
            'Are you sure you want to cancel this leave request? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'No',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _leaveCubit.cancelLeave(leaveRequest.id);
              },
              child: Text(
                'Yes, Cancel',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );
  }
}
