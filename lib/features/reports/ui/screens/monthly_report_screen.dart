import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_styles.dart';
import '../../../../core/widgets/error_widgets.dart';
import '../../logic/cubit/monthly_report_cubit.dart';
import '../../logic/cubit/monthly_report_state.dart';

/// Monthly Report Screen
///
/// Displays monthly attendance report with statistics
class MonthlyReportScreen extends StatefulWidget {
  const MonthlyReportScreen({super.key});

  @override
  State<MonthlyReportScreen> createState() => _MonthlyReportScreenState();
}

class _MonthlyReportScreenState extends State<MonthlyReportScreen> {
  late final MonthlyReportCubit _monthlyReportCubit;
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _monthlyReportCubit = MonthlyReportCubit();
    _fetchReport();
  }

  @override
  void dispose() {
    _monthlyReportCubit.close();
    super.dispose();
  }

  void _fetchReport() {
    _monthlyReportCubit.fetchMonthlyReport(
      year: _selectedMonth.year,
      month: _selectedMonth.month,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          'Monthly Report',
          style: AppTextStyles.titleLarge.copyWith(
            color: AppColors.white,
          ),
        ),
      ),
      body: BlocBuilder<MonthlyReportCubit, MonthlyReportState>(
        bloc: _monthlyReportCubit,
        builder: (context, state) {
          if (state is MonthlyReportLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MonthlyReportError) {
            return CompactErrorWidget(
              message: ErrorSnackBar.getArabicMessage(state.message),
              onRetry: _fetchReport,
            );
          }

          if (state is! MonthlyReportLoaded) {
            return const SizedBox.shrink();
          }

          final report = state.report;

          return RefreshIndicator(
            onRefresh: () => _monthlyReportCubit.fetchMonthlyReport(
              year: _selectedMonth.year,
              month: _selectedMonth.month,
            ),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Month Selector
                  _buildMonthSelector(),

                  const SizedBox(height: 24),

                  // Summary Cards
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Overview',
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildSummaryGrid(report),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Attendance Chart
                  _buildAttendanceChart(report),

                  const SizedBox(height: 24),

                  // Details Section
                  _buildDetailsSection(report),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Select Month',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: _selectMonth,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.white.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_month,
                    color: AppColors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('MMMM yyyy').format(_selectedMonth),
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_drop_down,
                    color: AppColors.white,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryGrid(dynamic report) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Present Days',
          '${report.presentDays}/${report.totalDays}',
          Icons.check_circle,
          AppColors.success,
        ),
        _buildStatCard(
          'Absent Days',
          '${report.absentDays}',
          Icons.cancel,
          AppColors.error,
        ),
        _buildStatCard(
          'Late Arrivals',
          '${report.lateDays}',
          Icons.access_time,
          AppColors.warning,
        ),
        _buildStatCard(
          'Early Leaves',
          '${report.earlyLeaveDays}',
          Icons.logout,
          AppColors.info,
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textSecondary.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceChart(dynamic report) {
    final attendancePercentage = report.attendancePercentage;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Text(
              'Attendance Rate',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 150,
                  height: 150,
                  child: CircularProgressIndicator(
                    value: attendancePercentage / 100,
                    strokeWidth: 12,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getPercentageColor(attendancePercentage),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Text(
                      '${attendancePercentage.toStringAsFixed(1)}%',
                      style: AppTextStyles.headlineLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Attendance',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsSection(dynamic report) {
    final avgPerDay = report.presentDays > 0
        ? (report.totalHours / report.presentDays).toStringAsFixed(1)
        : '0.0';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Work Hours',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(
              'Total Hours',
              '${report.totalHours.toStringAsFixed(1)} hrs',
              Icons.access_time,
              AppColors.primary,
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              'Overtime Hours',
              '${report.overtimeHours.toStringAsFixed(1)} hrs',
              Icons.schedule,
              AppColors.warning,
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              'Average per Day',
              '$avgPerDay hrs',
              Icons.trending_up,
              AppColors.success,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.titleSmall.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Color _getPercentageColor(double percentage) {
    if (percentage >= 90) return AppColors.success;
    if (percentage >= 70) return AppColors.warning;
    return AppColors.error;
  }

  Future<void> _selectMonth() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selected != null) {
      setState(() {
        _selectedMonth = selected;
      });
      _fetchReport();
    }
  }
}
