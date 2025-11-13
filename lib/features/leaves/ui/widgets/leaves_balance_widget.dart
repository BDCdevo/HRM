import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_styles.dart';
import '../../../../core/theme/cubit/theme_cubit.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../leave/logic/cubit/leave_cubit.dart';
import '../../../leave/logic/cubit/leave_state.dart';
import '../../../leave/data/models/leave_balance_model.dart';

/// Leaves Balance Widget
///
/// Displays leave balance for different leave types
class LeavesBalanceWidget extends StatefulWidget {
  const LeavesBalanceWidget({super.key});

  @override
  State<LeavesBalanceWidget> createState() => _LeavesBalanceWidgetState();
}

class _LeavesBalanceWidgetState extends State<LeavesBalanceWidget> {
  bool _hasInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Fetch leave balance only once when widget is ready
    if (!_hasInitialized) {
      _hasInitialized = true;
      print('🟢 LeavesBalanceWidget: Initializing and fetching data...');

      final cubit = context.read<LeaveCubit>();
      final currentState = cubit.state;

      print('🟢 LeavesBalanceWidget: Current state: ${currentState.runtimeType}');

      // Only fetch if not already loading or loaded
      if (currentState is! LeaveBalanceLoading &&
          currentState is! LeaveBalanceLoaded) {
        print('🟢 LeavesBalanceWidget: Calling fetchLeaveBalance()');
        cubit.fetchLeaveBalance();
      } else {
        print('🟡 LeavesBalanceWidget: Data already loading or loaded, skipping fetch');
      }
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
        if (state is LeaveBalanceLoading || state is LeaveInitial) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: List.generate(
                3,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: CardSkeleton(height: 120),
                ),
              ),
            ),
          );
        }

        if (state is LeaveBalanceLoaded) {
          final balances = state.balances;
          final totalRemaining = state.totalRemaining;
          final year = state.year;

          if (balances.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    size: 80,
                    color: secondaryTextColor.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No leave balance information available',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: secondaryTextColor,
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                        ? [
                            AppColors.darkCard,
                            AppColors.darkCardElevated,
                          ]
                        : [
                            AppColors.primary,
                            AppColors.primary.withOpacity(0.85),
                          ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: isDark ? [] : [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.account_balance_wallet,
                        color: AppColors.white,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Total Available',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$totalRemaining Days',
                        style: AppTextStyles.displaySmall.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Year $year',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Leave Types Balance
                Text(
                  'Leave Balance by Type',
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),

                const SizedBox(height: 16),

                // Balance Cards
                ...balances.map((balance) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: _LeaveBalanceCard(
                      balance: balance,
                      isDark: isDark,
                      cardColor: cardColor,
                      textColor: textColor,
                      secondaryTextColor: secondaryTextColor,
                    ),
                  );
                }),
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
                  onPressed: () => context.read<LeaveCubit>().fetchLeaveBalance(),
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

/// Leave Balance Card
class _LeaveBalanceCard extends StatelessWidget {
  final LeaveBalanceModel balance;
  final bool? isDark;
  final Color? cardColor;
  final Color? textColor;
  final Color? secondaryTextColor;

  const _LeaveBalanceCard({
    required this.balance,
    this.isDark,
    this.cardColor,
    this.textColor,
    this.secondaryTextColor,
  });

  IconData _getIcon() {
    final name = balance.vacationTypeName.toLowerCase();
    if (name.contains('sick')) return Icons.local_hospital;
    if (name.contains('annual') || name.contains('vacation')) return Icons.beach_access;
    if (name.contains('casual')) return Icons.calendar_today;
    if (name.contains('emergency')) return Icons.emergency;
    return Icons.event_available;
  }

  Color _getColor() {
    final name = balance.vacationTypeName.toLowerCase();
    if (name.contains('sick')) return AppColors.info;
    if (name.contains('annual') || name.contains('vacation')) return AppColors.success;
    if (name.contains('casual')) return AppColors.primary;
    if (name.contains('emergency')) return AppColors.accent;
    return AppColors.info;
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    final percentage = balance.remainingPercentage;
    final effectiveIsDark = isDark ?? false;
    final effectiveCardColor = cardColor ?? AppColors.white;
    final effectiveTextColor = textColor ?? AppColors.textPrimary;
    final effectiveSecondaryTextColor = secondaryTextColor ?? AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: effectiveCardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: effectiveIsDark ? [] : [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(effectiveIsDark ? 0.2 : 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getIcon(),
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),

              // Type
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      balance.vacationTypeName,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: effectiveTextColor,
                      ),
                    ),
                    if (balance.description != null && balance.description!.isNotEmpty)
                      Text(
                        balance.description!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: effectiveSecondaryTextColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),

              // Remaining Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(effectiveIsDark ? 0.2 : 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${balance.remaining} left',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: color.withOpacity(effectiveIsDark ? 0.2 : 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),

          const SizedBox(height: 8),

          // Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total: ${balance.total} days',
                style: AppTextStyles.bodySmall.copyWith(
                  color: effectiveSecondaryTextColor,
                ),
              ),
              Text(
                'Used: ${balance.used} days',
                style: AppTextStyles.bodySmall.copyWith(
                  color: effectiveSecondaryTextColor,
                ),
              ),
              Text(
                '$percentage% left',
                style: AppTextStyles.bodySmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          // Availability Info
          if (!balance.isAvailable) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(effectiveIsDark ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppColors.info,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      balance.availabilityInfo,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.info,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
