import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_styles.dart';
import '../../../../core/theme/cubit/theme_cubit.dart';
import '../../logic/cubit/attendance_cubit.dart';
import '../widgets/attendance_check_in_widget.dart';
import '../widgets/attendance_history_widget.dart';

/// Attendance Main Screen
///
/// Main screen with tabs for Check-in and History
class AttendanceMainScreen extends StatefulWidget {
  const AttendanceMainScreen({super.key});

  @override
  State<AttendanceMainScreen> createState() => _AttendanceMainScreenState();
}

class _AttendanceMainScreenState extends State<AttendanceMainScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<ThemeCubit>().isDarkMode;
    final backgroundColor = isDarkMode ? AppColors.darkBackground : AppColors.background;
    final cardColor = isDarkMode ? AppColors.darkCard : AppColors.surface;
    final appBarColor = isDarkMode ? AppColors.darkAppBar : AppColors.primary;

    return BlocProvider(
      create: (context) => AttendanceCubit(),
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // App Bar
            SliverAppBar(
              expandedHeight: 140,
              floating: false,
              pinned: true,
              backgroundColor: appBarColor,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDarkMode
                        ? [
                            AppColors.darkAppBar,
                            AppColors.darkCard,
                            AppColors.darkCard.withOpacity(0.8),
                          ]
                        : [
                            AppColors.primary,
                            AppColors.primary.withOpacity(0.85),
                            AppColors.accent.withOpacity(0.3),
                          ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Icon and Title
                          Row(
                            children: [
                              // Icon with glow effect
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppColors.white.withOpacity(0.25),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.accent.withOpacity(0.2),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.fingerprint_rounded,
                                  color: AppColors.white,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Title and subtitle
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Attendance',
                                      style: AppTextStyles.headlineMedium.copyWith(
                                        color: AppColors.white,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.schedule_rounded,
                                          size: 16,
                                          color: AppColors.white.withOpacity(0.85),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Track your work hours & history',
                                          style: AppTextStyles.bodySmall.copyWith(
                                            color: AppColors.white.withOpacity(0.85),
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Tab Bar
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: isDarkMode ? AppColors.white : AppColors.primary,
                  unselectedLabelColor: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  indicatorColor: AppColors.accent,
                  indicatorWeight: 3,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.accent,
                        width: 3,
                      ),
                    ),
                  ),
                  labelStyle: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  unselectedLabelStyle: AppTextStyles.labelLarge.copyWith(
                    fontSize: 14,
                  ),
                  tabs: const [
                    Tab(
                      height: 60,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.fingerprint_rounded, size: 24),
                          SizedBox(height: 4),
                          Text('Check-in'),
                        ],
                      ),
                    ),
                    Tab(
                      height: 60,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history_rounded, size: 24),
                          SizedBox(height: 4),
                          Text('History'),
                        ],
                      ),
                    ),
                  ],
                ),
                backgroundColor: cardColor,
                isDark: isDarkMode,
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // Check-in Tab
            AttendanceCheckInWidget(),

            // History Tab
            const AttendanceHistoryWidget(),
          ],
        ),
      ),
    ),
    );
  }
}

/// Sliver Tab Bar Delegate
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  final Color backgroundColor;
  final bool isDark;

  _SliverTabBarDelegate(
    this._tabBar, {
    required this.backgroundColor,
    required this.isDark,
  });

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return backgroundColor != oldDelegate.backgroundColor || isDark != oldDelegate.isDark;
  }
}
