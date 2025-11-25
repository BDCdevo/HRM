import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_styles.dart';
import '../../../../core/widgets/error_widgets.dart';
import '../../logic/cubit/leave_cubit.dart';
import '../../logic/cubit/leave_state.dart';
import '../../data/models/leave_balance_model.dart';

/// Leave Balance Screen
///
/// Displays detailed leave balance information for all vacation types
class LeaveBalanceScreen extends StatefulWidget {
  const LeaveBalanceScreen({super.key});

  @override
  State<LeaveBalanceScreen> createState() => _LeaveBalanceScreenState();
}

class _LeaveBalanceScreenState extends State<LeaveBalanceScreen> {
  late final LeaveCubit _leaveCubit;

  @override
  void initState() {
    super.initState();
    _leaveCubit = LeaveCubit();
    _leaveCubit.fetchLeaveBalance();
  }

  @override
  void dispose() {
    _leaveCubit.close();
    super.dispose();
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
            'Leave Balance',
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.white,
            ),
          ),
        ),
        body: BlocBuilder<LeaveCubit, LeaveState>(
          builder: (context, state) {
            // Show loading state
            if (state is LeaveBalanceLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            // Show error state
            if (state is LeaveError) {
              return CompactErrorWidget(
                message: ErrorSnackBar.getArabicMessage(state.displayMessage),
                onRetry: () => _leaveCubit.fetchLeaveBalance(),
              );
            }

            // Show balance data
            if (state is LeaveBalanceLoaded) {
              return RefreshIndicator(
                onRefresh: () => _leaveCubit.fetchLeaveBalance(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      // Summary Card
                      _buildSummaryCard(state),

                      const SizedBox(height: 24),

                      // Balance Details
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Leave Types',
                              style: AppTextStyles.titleMedium.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ...state.balances.map((balance) {
                              return _buildBalanceCard(balance);
                            }),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildSummaryCard(LeaveBalanceLoaded state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.beach_access,
            size: 48,
            color: AppColors.white,
          ),
          const SizedBox(height: 16),
          Text(
            'Total Remaining',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${state.totalRemaining}',
            style: AppTextStyles.headlineLarge.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
              fontSize: 48,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'days available',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Year ${state.year}',
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(LeaveBalanceModel balance) {
    final usagePercentage = balance.usagePercentage;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: balance.isAvailable
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.textSecondary.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.textSecondary.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (balance.isAvailable
                          ? AppColors.success
                          : AppColors.textSecondary)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getLeaveIcon(balance.name),
                  color: balance.isAvailable
                      ? AppColors.success
                      : AppColors.textSecondary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      balance.name,
                      style: AppTextStyles.titleSmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      balance.isAvailable ? 'Available' : 'Not Available',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: balance.isAvailable
                            ? AppColors.success
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Remaining days badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${balance.remainingDays} left',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Usage',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '${usagePercentage.toStringAsFixed(0)}%',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: usagePercentage / 100,
                  minHeight: 8,
                  backgroundColor: AppColors.border,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getProgressColor(usagePercentage),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Details
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  'Total',
                  '${balance.totalBalance}',
                  Icons.event_available,
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  'Used',
                  '${balance.usedDays}',
                  Icons.event_busy,
                ),
              ),
              Expanded(
                child: _buildDetailItem(
                  'Remaining',
                  '${balance.remainingDays}',
                  Icons.event_note,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  IconData _getLeaveIcon(String leaveName) {
    final name = leaveName.toLowerCase();
    if (name.contains('annual')) return Icons.beach_access;
    if (name.contains('sick')) return Icons.local_hospital;
    if (name.contains('casual')) return Icons.event_note;
    if (name.contains('emergency')) return Icons.emergency;
    if (name.contains('maternity') || name.contains('paternity')) {
      return Icons.child_care;
    }
    return Icons.event_available;
  }

  Color _getProgressColor(double percentage) {
    if (percentage <= 50) return AppColors.success;
    if (percentage <= 80) return AppColors.warning;
    return AppColors.error;
  }
}
