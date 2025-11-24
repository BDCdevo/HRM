import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_styles.dart';
import '../../../../core/widgets/app_loading_screen.dart';
import '../../data/repo/holiday_repo.dart';
import '../../logic/cubit/holiday_cubit.dart';
import '../../logic/cubit/holiday_state.dart';
import '../../data/models/holiday_model.dart';
import '../widgets/holidays_skeleton.dart';

class HolidaysScreen extends StatelessWidget {
  const HolidaysScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HolidayCubit(HolidayRepo())..fetchHolidays(),
      child: const _HolidaysScreenContent(),
    );
  }
}

class _HolidaysScreenContent extends StatelessWidget {
  const _HolidaysScreenContent();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: const Text('الإجازات الرسمية'),
        backgroundColor: isDark ? AppColors.darkAppBar : AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          BlocBuilder<HolidayCubit, HolidayState>(
            builder: (context, state) {
              if (state is HolidayLoaded) {
                return PopupMenuButton<String>(
                  icon: const Icon(Icons.filter_list),
                  onSelected: (filter) {
                    context.read<HolidayCubit>().changeFilter(filter);
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'all',
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_month,
                            color: state.filter == 'all'
                                ? AppColors.primary
                                : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'جميع الإجازات',
                            style: TextStyle(
                              color: state.filter == 'all'
                                  ? AppColors.primary
                                  : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                              fontWeight: state.filter == 'all'
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'upcoming',
                      child: Row(
                        children: [
                          Icon(
                            Icons.upcoming,
                            color: state.filter == 'upcoming'
                                ? AppColors.primary
                                : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'القادمة',
                            style: TextStyle(
                              color: state.filter == 'upcoming'
                                  ? AppColors.primary
                                  : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                              fontWeight: state.filter == 'upcoming'
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'current',
                      child: Row(
                        children: [
                          Icon(
                            Icons.event_available,
                            color: state.filter == 'current'
                                ? AppColors.primary
                                : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'الحالية',
                            style: TextStyle(
                              color: state.filter == 'current'
                                  ? AppColors.primary
                                  : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                              fontWeight: state.filter == 'current'
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'past',
                      child: Row(
                        children: [
                          Icon(
                            Icons.history,
                            color: state.filter == 'past'
                                ? AppColors.primary
                                : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'المنتهية',
                            style: TextStyle(
                              color: state.filter == 'past'
                                  ? AppColors.primary
                                  : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                              fontWeight: state.filter == 'past'
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<HolidayCubit, HolidayState>(
        builder: (context, state) {
          if (state is HolidayLoading) {
            return const HolidaysSkeleton();
          }

          if (state is HolidayError) {
            return Center(
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
                    'حدث خطأ',
                    style: AppTextStyles.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<HolidayCubit>().refresh();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('إعادة المحاولة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          if (state is HolidayLoaded) {
            if (state.holidays.isEmpty) {
              return Center(
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
                      'لا توجد إجازات',
                      style: AppTextStyles.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'لا توجد إجازات رسمية ${_getFilterLabel(state.filter)}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => context.read<HolidayCubit>().refresh(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.holidays.length,
                itemBuilder: (context, index) {
                  return _HolidayCard(holiday: state.holidays[index]);
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  String _getFilterLabel(String filter) {
    switch (filter) {
      case 'upcoming':
        return 'قادمة';
      case 'current':
        return 'حالية';
      case 'past':
        return 'منتهية';
      default:
        return '';
    }
  }
}

class _HolidayCard extends StatelessWidget {
  final HolidayModel holiday;

  const _HolidayCard({required this.holiday});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorValue = int.tryParse(
          holiday.color.replaceFirst('#', '0xFF'),
        ) ??
        0xFF6B7280;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isDark ? 4 : 2,
      color: isDark ? AppColors.darkCard : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Color(colorValue).withOpacity(isDark ? 0.5 : 0.3),
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          // Show holiday details
          _showHolidayDetails(context);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Color indicator
              Container(
                width: 4,
                height: 60,
                decoration: BoxDecoration(
                  color: Color(colorValue),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Holiday name
                    Text(
                      holiday.name,
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Date range
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _formatDateRange(),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Tags
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        _buildTag(
                          holiday.typeLabel,
                          Color(colorValue),
                        ),
                        if (holiday.duration > 1)
                          _buildTag(
                            '${holiday.duration} أيام',
                            AppColors.accent,
                          ),
                        if (holiday.isPaid)
                          _buildTag(
                            'مدفوعة',
                            AppColors.success,
                          ),
                        if (holiday.isCurrent)
                          _buildTag(
                            'جارية',
                            AppColors.warning,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              // Status icon
              if (holiday.isCurrent || holiday.isUpcoming)
                Icon(
                  holiday.isCurrent
                      ? Icons.event_available
                      : Icons.upcoming,
                  color: holiday.isCurrent
                      ? AppColors.success
                      : AppColors.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatDateRange() {
    try {
      final start = DateTime.parse(holiday.startDate);
      final end = DateTime.parse(holiday.endDate);

      final formatter = DateFormat('d MMMM yyyy', 'ar');

      if (holiday.duration == 1) {
        return formatter.format(start);
      }

      return '${formatter.format(start)} - ${formatter.format(end)}';
    } catch (e) {
      return holiday.formattedDateRange;
    }
  }

  void _showHolidayDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final colorValue = int.tryParse(
              holiday.color.replaceFirst('#', '0xFF'),
            ) ??
            0xFF6B7280;

        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(colorValue),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      holiday.name,
                      style: AppTextStyles.headlineMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Description
              if (holiday.description != null &&
                  holiday.description!.isNotEmpty) ...[
                Text(
                  'الوصف',
                  style: AppTextStyles.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  holiday.description!,
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 16),
              ],
              // Details
              _buildDetailRow(
                'التاريخ',
                _formatDateRange(),
                Icons.calendar_today,
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                'المدة',
                '${holiday.duration} ${holiday.duration == 1 ? "يوم" : "أيام"}',
                Icons.timelapse,
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                'النوع',
                holiday.typeLabel,
                Icons.category,
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                'الحالة',
                holiday.isPaid ? 'مدفوعة الأجر' : 'غير مدفوعة',
                Icons.payments,
              ),
              if (holiday.isRecurring) ...[
                const SizedBox(height: 12),
                _buildDetailRow(
                  'التكرار',
                  holiday.recurrenceType == 'yearly' ? 'سنوياً' : 'متكررة',
                  Icons.repeat,
                ),
              ],
              const SizedBox(height: 24),
              // Close button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('إغلاق'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodyMedium,
          ),
        ),
      ],
    );
  }
}
