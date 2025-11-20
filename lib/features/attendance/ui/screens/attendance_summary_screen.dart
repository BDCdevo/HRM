import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/theme/cubit/theme_cubit.dart';
import '../../data/models/employee_attendance_model.dart';
import '../../logic/cubit/attendance_summary_cubit.dart';
import '../../logic/cubit/attendance_summary_state.dart';
import '../widgets/employee_details_bottom_sheet.dart';

/// Attendance Summary Screen
///
/// Shows all employees' attendance for today with detailed information
/// Fetches real data from API
class AttendanceSummaryScreen extends StatefulWidget {
  const AttendanceSummaryScreen({super.key});

  @override
  State<AttendanceSummaryScreen> createState() => _AttendanceSummaryScreenState();
}

class _AttendanceSummaryScreenState extends State<AttendanceSummaryScreen> {
  late final AttendanceSummaryCubit _cubit;
  String selectedFilter = 'Today';
  DateTime selectedDate = DateTime.now();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _cubit = AttendanceSummaryCubit();
    // Fetch today's summary on init
    _cubit.fetchTodaySummary();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('E, MMM dd, yyyy').format(DateTime.now());

    // Theme colors
    final isDark = context.watch<ThemeCubit>().isDarkMode;
    final backgroundColor = isDark ? AppColors.darkBackground : AppColors.background;
    final cardColor = isDark ? AppColors.darkCard : AppColors.surface;
    final appBarColor = isDark ? AppColors.darkAppBar : AppColors.primary;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: appBarColor,
        appBar: AppBar(
          backgroundColor: appBarColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Attendance Summary',
            style: TextStyle(
              color: AppColors.white.withOpacity(0.7),
              fontSize: 16,
              fontWeight: FontWeight.normal,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: AppColors.white),
              onPressed: _showSearchDialog,
            ),
          ],
        ),
        body: BlocBuilder<AttendanceSummaryCubit, AttendanceSummaryState>(
          builder: (context, state) {
            if (state is AttendanceSummaryLoading) {
              return _buildSkeletonLoading(isDark, backgroundColor, cardColor);
            }

            if (state is AttendanceSummaryError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.white, size: 64),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading data',
                      style: const TextStyle(color: AppColors.white, fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: TextStyle(color: AppColors.white.withOpacity(0.7), fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => _cubit.fetchTodaySummary(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final summary = state is AttendanceSummaryLoaded ? state.summary : null;
            final allEmployees = summary?.employees ?? [];

            // Filter employees based on search query
            final employees = searchQuery.isEmpty
                ? allEmployees
                : allEmployees.where((employee) {
                    final nameLower = employee.employeeName.toLowerCase();
                    final roleLower = (employee.role ?? '').toLowerCase();
                    final deptLower = (employee.department ?? '').toLowerCase();
                    final query = searchQuery.toLowerCase();

                    return nameLower.contains(query) ||
                           roleLower.contains(query) ||
                           deptLower.contains(query);
                  }).toList();

            return RefreshIndicator(
              onRefresh: () async {
                _cubit.fetchTodaySummary();
                await Future.delayed(const Duration(seconds: 1));
              },
              color: AppColors.primary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section with Gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                          ? [
                              appBarColor,
                              appBarColor.withOpacity(0.85),
                              appBarColor,
                            ]
                          : [
                              appBarColor,
                              appBarColor.withOpacity(0.85),
                              appBarColor,
                            ],
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Attendance",
                          style: TextStyle(
                            color: AppColors.white.withOpacity(0.7),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Track Your Team",
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.accent.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.calendar_today,
                                    color: AppColors.accent,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    selectedFilter,
                                    style: const TextStyle(
                                      color: AppColors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                // Content Section - Overlapping Card Design
                Expanded(
                  child: Stack(
                    clipBehavior: Clip.none, // Allow overflow
                    children: [
                      // Background (Light Color)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                          ),
                        ),
                      ),

                      // Summary Card - Positioned to overlap
                      Positioned(
                        top: -80,
                        left: 20,
                        right: 20,
                        child: _buildSummaryCard(today, summary, isDark, cardColor, textColor, secondaryTextColor),
                      ),

                      // Employee List - Below the card
                      Positioned(
                        top: 140, // Adjust based on card height
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: employees.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        searchQuery.isEmpty
                                            ? Icons.people_outline_rounded
                                            : Icons.search_off_rounded,
                                        size: 64,
                                        color: AppColors.primary.withOpacity(0.5),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      searchQuery.isEmpty
                                          ? 'No Employees Yet'
                                          : 'No Results Found',
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      searchQuery.isEmpty
                                          ? 'There are no employees in the system'
                                          : 'Try searching with different keywords',
                                      style: TextStyle(
                                        color: secondaryTextColor,
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                itemCount: employees.length,
                                itemBuilder: (context, index) {
                                  final employee = employees[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _buildEmployeeCard(employee, isDark, cardColor, textColor, secondaryTextColor),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            );
          },
        ),
      ),
    );
  }

  /// Build Summary Card - Half in dark background
  Widget _buildSummaryCard(String date, AttendanceSummaryModel? summary, bool isDark, Color cardColor, Color textColor, Color secondaryTextColor) {
    final totalEmployees = summary?.totalEmployees ?? 0;
    final checkedIn = summary?.checkedIn ?? 0;
    final absent = summary?.absent ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Summary',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),

              // Filter Dropdown
              GestureDetector(
                onTap: _showFilterOptions,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        selectedFilter,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_drop_down,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Stats Row with Enhanced Design
          Row(
            children: [
              // Employee Count
              Expanded(
                child: _buildEnhancedStatCard(
                  icon: Icons.people_rounded,
                  label: 'Total',
                  value: totalEmployees.toString(),
                  color: AppColors.primary,
                  bgColor: AppColors.primary.withOpacity(isDark ? 0.15 : 0.1),
                ),
              ),

              const SizedBox(width: 12),

              // Checked In Count
              Expanded(
                child: _buildEnhancedStatCard(
                  icon: Icons.check_circle_rounded,
                  label: 'Present',
                  value: checkedIn.toString(),
                  color: AppColors.success,
                  bgColor: AppColors.success.withOpacity(isDark ? 0.15 : 0.1),
                ),
              ),

              const SizedBox(width: 12),

              // Absent Count
              Expanded(
                child: _buildEnhancedStatCard(
                  icon: Icons.remove_circle_rounded,
                  label: 'Absent',
                  value: absent.toString(),
                  color: secondaryTextColor,
                  bgColor: secondaryTextColor.withOpacity(isDark ? 0.15 : 0.1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build Enhanced Stat Card
  Widget _buildEnhancedStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Build Stat Column (Legacy - keeping for compatibility)
  Widget _buildStatColumn({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Build Employee Card with Enhanced Status Display
  Widget _buildEmployeeCard(EmployeeAttendanceModel employee, bool isDark, Color cardColor, Color textColor, Color secondaryTextColor) {
    // Determine avatar color based on name
    final colors = [
      const Color(0xFFE91E63), // Pink
      const Color(0xFFFF9800), // Orange
      const Color(0xFF2196F3), // Blue
      const Color(0xFF4CAF50), // Green
      const Color(0xFF9C27B0), // Purple
    ];
    final colorIndex = employee.employeeName.hashCode % colors.length;
    final avatarColor = colors[colorIndex.abs()];

    // Determine status color and text - Simplified colors
    Color statusColor;
    String statusText;
    Color statusBgColor;
    IconData statusIcon;

    switch (employee.status.toLowerCase()) {
      case 'present':
        statusColor = AppColors.success;
        statusText = 'PRESENT';
        statusBgColor = AppColors.success.withOpacity(isDark ? 0.2 : 0.15);
        statusIcon = Icons.check_circle;
        break;
      case 'late':
        statusColor = AppColors.primary;
        statusText = 'LATE';
        statusBgColor = AppColors.primary.withOpacity(isDark ? 0.2 : 0.15);
        statusIcon = Icons.access_time;
        break;
      case 'absent':
        statusColor = secondaryTextColor;
        statusText = 'ABSENT';
        statusBgColor = secondaryTextColor.withOpacity(isDark ? 0.2 : 0.15);
        statusIcon = Icons.remove_circle_outline;
        break;
      case 'checked_out':
        statusColor = AppColors.info;
        statusText = 'CHECKED OUT';
        statusBgColor = AppColors.info.withOpacity(isDark ? 0.2 : 0.15);
        statusIcon = Icons.exit_to_app;
        break;
      default:
        statusColor = secondaryTextColor;
        statusText = 'UNKNOWN';
        statusBgColor = secondaryTextColor.withOpacity(isDark ? 0.2 : 0.15);
        statusIcon = Icons.help_outline;
    }

    return GestureDetector(
      onTap: () {
        // Show employee details bottom sheet
        showEmployeeDetailsBottomSheet(context, employee);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border,
            width: 1,
          ),
          boxShadow: isDark ? [] : [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      child: Column(
        children: [
          // Top Row: Avatar, Info, Status Badge
          Row(
            children: [
              // Location Icon
              if (employee.hasLocation)
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),

              SizedBox(width: employee.hasLocation ? 12 : 0),

              // Avatar with Online Status
              Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: avatarColor,
                    child: Text(
                      employee.avatarInitial ?? employee.employeeName[0].toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (employee.isOnline)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(width: 12),

              // Employee Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employee.employeeName,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      employee.role ?? 'No Role',
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      employee.department ?? 'No Department',
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              // Simplified Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      statusIcon,
                      color: statusColor,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Divider
          if (employee.checkInTime != null || employee.checkOutTime != null) ...[
            const SizedBox(height: 12),
            Divider(color: isDark ? AppColors.darkDivider : Colors.grey.shade200, height: 1),
            const SizedBox(height: 12),
          ],

          // Bottom Row: Time Info
          if (employee.checkInTime != null || employee.checkOutTime != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Check In Time
                if (employee.checkInTime != null)
                  Expanded(
                    child: _buildTimeInfo(
                      icon: Icons.login,
                      label: 'Check In',
                      time: employee.checkInTime!,
                      color: AppColors.success,
                      secondaryTextColor: secondaryTextColor,
                    ),
                  ),

                // Duration
                if (employee.duration != null)
                  Expanded(
                    child: _buildTimeInfo(
                      icon: Icons.timer_outlined,
                      label: 'Duration',
                      time: employee.duration!,
                      color: AppColors.primary,
                      secondaryTextColor: secondaryTextColor,
                    ),
                  ),

                // Check Out Time
                if (employee.checkOutTime != null)
                  Expanded(
                    child: _buildTimeInfo(
                      icon: Icons.logout,
                      label: 'Check Out',
                      time: employee.checkOutTime!,
                      color: AppColors.info,
                      secondaryTextColor: secondaryTextColor,
                    ),
                  ),
              ],
            ),
        ],
      ),
      ),
    );
  }

  /// Build Time Info Widget
  Widget _buildTimeInfo({
    required IconData icon,
    required String label,
    required String time,
    required Color color,
    required Color secondaryTextColor,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: secondaryTextColor,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Show Filter Options Bottom Sheet
  void _showFilterOptions() {
    final isDark = context.read<ThemeCubit>().isDarkMode;
    final cardColor = isDark ? AppColors.darkCard : AppColors.surface;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final dividerColor = isDark ? AppColors.darkDivider : Colors.grey[300];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              'Filter Attendance',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 20),

            // Filter options
            _buildFilterOption('Today', Icons.today),
            _buildFilterOption('This Week', Icons.date_range),
            _buildFilterOption('This Month', Icons.calendar_month),
            _buildFilterOption('Custom Date', Icons.calendar_today),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Build Filter Option
  Widget _buildFilterOption(String label, IconData icon) {
    final isSelected = selectedFilter == label;
    final isDark = context.read<ThemeCubit>().isDarkMode;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return InkWell(
      onTap: () {
        Navigator.pop(context);
        _applyFilter(label);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 4,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : secondaryTextColor,
              size: 24,
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppColors.primary : textColor,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  /// Apply Filter
  void _applyFilter(String filter) async {
    setState(() {
      selectedFilter = filter;
    });

    DateTime targetDate;

    switch (filter) {
      case 'Today':
        targetDate = DateTime.now();
        _cubit.fetchTodaySummary();
        break;

      case 'This Week':
        // Get the first day of this week (Monday)
        final now = DateTime.now();
        final firstDayOfWeek = now.subtract(Duration(days: now.weekday - 1));
        targetDate = firstDayOfWeek;
        _cubit.fetchSummaryByDate(targetDate);
        break;

      case 'This Month':
        // Get the first day of this month
        final now = DateTime.now();
        targetDate = DateTime(now.year, now.month, 1);
        _cubit.fetchSummaryByDate(targetDate);
        break;

      case 'Custom Date':
        // Show date picker
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: AppColors.primary,
                  onPrimary: AppColors.white,
                  surface: AppColors.white,
                  onSurface: Colors.black,
                ),
              ),
              child: child!,
            );
          },
        );

        if (pickedDate != null) {
          setState(() {
            selectedDate = pickedDate;
          });
          _cubit.fetchSummaryByDate(pickedDate);
        }
        break;

      default:
        _cubit.fetchTodaySummary();
    }
  }

  /// Show Search Dialog
  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Employees'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter name, role, or department...',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            setState(() {
              searchQuery = value;
            });
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                searchQuery = '';
              });
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Search', style: TextStyle(color: AppColors.white)),
          ),
        ],
      ),
    );
  }

  /// Build Skeleton Loading
  Widget _buildSkeletonLoading(bool isDark, Color backgroundColor, Color cardColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Section
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                ? [
                    AppColors.darkAppBar,
                    AppColors.darkAppBar.withOpacity(0.85),
                    AppColors.darkAppBar,
                  ]
                : [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.85),
                    AppColors.primary,
                  ],
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildShimmer(
                width: 100,
                height: 16,
                isDark: isDark,
              ),
              const SizedBox(height: 8),
              _buildShimmer(
                width: 200,
                height: 32,
                isDark: isDark,
              ),
              const SizedBox(height: 4),
              _buildShimmer(
                width: 80,
                height: 32,
                isDark: isDark,
                borderRadius: 20,
              ),
            ],
          ),
        ),

        // Content Section
        Expanded(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Background
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                ),
              ),

              // Skeleton Summary Card
              Positioned(
                top: -80,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: isDark ? [] : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildShimmer(width: 100, height: 18, isDark: isDark),
                              const SizedBox(height: 4),
                              _buildShimmer(width: 150, height: 13, isDark: isDark),
                            ],
                          ),
                          _buildShimmer(width: 80, height: 32, isDark: isDark, borderRadius: 8),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Stats Row
                      Row(
                        children: [
                          Expanded(child: _buildSkeletonStatCard(isDark)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildSkeletonStatCard(isDark)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildSkeletonStatCard(isDark)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Skeleton Employee List
              Positioned(
                top: 140,
                left: 0,
                right: 0,
                bottom: 0,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildSkeletonEmployeeCard(isDark, cardColor),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build Skeleton Stat Card
  Widget _buildSkeletonStatCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark
          ? AppColors.darkInput.withOpacity(0.3)
          : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildShimmer(width: 24, height: 24, isDark: isDark, isCircle: true),
          const SizedBox(height: 8),
          _buildShimmer(width: 40, height: 24, isDark: isDark),
          const SizedBox(height: 4),
          _buildShimmer(width: 50, height: 11, isDark: isDark),
        ],
      ),
    );
  }

  /// Build Skeleton Employee Card
  Widget _buildSkeletonEmployeeCard(bool isDark, Color cardColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              _buildShimmer(width: 56, height: 56, isDark: isDark, isCircle: true),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildShimmer(width: 120, height: 16, isDark: isDark),
                    const SizedBox(height: 4),
                    _buildShimmer(width: 80, height: 13, isDark: isDark),
                    const SizedBox(height: 2),
                    _buildShimmer(width: 100, height: 13, isDark: isDark),
                  ],
                ),
              ),

              // Status badge
              _buildShimmer(width: 70, height: 26, isDark: isDark, borderRadius: 8),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: isDark ? AppColors.darkDivider : Colors.grey.shade200, height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildShimmer(width: 60, height: 40, isDark: isDark),
              _buildShimmer(width: 60, height: 40, isDark: isDark),
              _buildShimmer(width: 60, height: 40, isDark: isDark),
            ],
          ),
        ],
      ),
    );
  }

  /// Build Shimmer Effect
  Widget _buildShimmer({
    required double width,
    required double height,
    required bool isDark,
    double borderRadius = 4,
    bool isCircle = false,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: isDark
                ? AppColors.darkInput.withOpacity(0.5)
                : Colors.grey.shade300,
              borderRadius: isCircle
                ? BorderRadius.circular(width / 2)
                : BorderRadius.circular(borderRadius),
            ),
          ),
        );
      },
      onEnd: () {
        // Reverse animation
        setState(() {});
      },
    );
  }
}
